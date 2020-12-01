+++
Description = "Setup a Linux backup server for daily and de-duplicated backups using Borg. Store a copy of the Borg archive off-site in archive cloud storage"
Tags = []
date = "2020-11-10T22:49:00"
title = "Backup system with Borg with off-site storage"
+++

Setup a Linux backup server for daily and de-duplicated backups using Borg. Store a copy of the Borg archive off-site in archive cloud storage.<!--more-->

## Background

I needed a solid backup system for our home network. Up until now, I have been using the `dar` utility and making DVD copies of the backup for safe keeping. This lacked features:

* no data de-duplication
* no off-site storage

I evaluated many of the open-source solutions for backup, but did not find any suitable. They were either way too complex, too opaque, or too unstable. I was hoping for a solution with a GUI interface, but found none to my liking. The issue with GUI seems to be that in a client/server system like this, the client being backed up needs elevated permissions, which conflicts with the safety of a normal GUI workspace. Likewise, the server needs to be run as a non-elevated user so that it isn't exposed to undue risk, yet it needs to be accessable to the clients and be able to push archives off-site.

It is simply a complex problem and no GUI solution seemed to handle all the use cases as I wished.

## Features

 * Automated backups of Linux clients to a Linux backup server
 * Efficient de-duplicated storage of data
 * Off-site storage of latest backup to S3 type Oracle Cloud based archive storage (semi-automated)
 * Off-site backups encrypted using gpg encryption
 * Off-site backups uploaded incrementally

## Server Setup (part 1):

Use any x86_64 based PC, running Devuan Linux. During installation of Devuan, configure the server with a static IP address and/or configure your local DNS server with the address of this server. I will refer to this as `backup_server`, but substitute as needed to address the backup server from each client. Alternatively, use any Linux distribution of choice, so long as the software listed below is available.

### Hard drives and partitions:
First hard drive, /dev/sda, 500 GB SATA
```nohighlight
#gdisk -l /dev/sda

Number  Start (sector)    End (sector)  Size       Code  Name
   1            2048            6143   2.0 MiB     EF02  BIOS boot partition
   2            6144          620543   300.0 MiB   8300  Linux filesystem
   3          620544         4814847   2.0 GiB     8200  Linux swap
   4         4814848        88700927   40.0 GiB    8300  Linux filesystem
   5        88700928       976773134   423.5 GiB   FD00  Linux RAID
```
Second hard drive, /dev/sdb, 1 TB SATA
```nohighlight
#gdisk -l /dev/sdb

Number  Start (sector)    End (sector)  Size       Code  Name
   1            2048      1953525134   931.5 GiB   FD00  Linux RAID
```
Partition detail

  * /dev/sda2 is /boot
  * /dev/sda4 is /
  * /dev/sda5 and /dev/sdb1 is combined into a RAID-0 array /dev/md0, and mounted to /mnt/raid:
```nohighlight
#cat /proc/mdstat

md0 : active raid0 sda5[0] sdb1[1]
      1420533248 blocks super 1.2 512k chunks
```
### Kernel configuration:
  * For this machine I needed to add `noapic` to get the time clock to be stable.
  * Because the two partitions for the RAID array are different sizes, I needed to add `raid0.default_layout=1`.
```nohighlight
Within /etc/default/grub:

GRUB_CMDLINE_LINUX="raid0.default_layout=1 noapic"
```
### Software
Install all of these using the Devuan repository.

Disk partitioning

* parted
* gdisk

RAID utility

* mdadm

NTP Time server (client)

* ntp
* ntpstat

Utilities

* sudo
* sysfsutils
* cpufrequtils

Backup system related

* borgbackup (a.k.a. borg)
* gpg
* tmux
* signing-party  (provides gpgdir)
* rclone

### Verify system date/time
Verify that NTP is operational
```nohighlight
ntpstat
```
The output should indicate "synchronized" and the current accuracy.

### Create backup user
Create the `borgbackup` user, assigning it a strong password. This is the user that will run the borg service process and handle client requests for creating backups.
```nohighlight
adduser borgbackup
```
Logging in using the password will be needed only for configuring clients, not for normal operation.

### Create repository folders for each client
```nohighlight
mkdir /mnt/raid/client_machine_repository
chown borgbackup:borgbackup /mnt/raid/client_machine_repository
mkdir /mnt/raid/client_machine_repository_gpg
chown borgbackup:borgbackup /mnt/raid/client_machine_repository_gpg
```
Repeat as needed, now or later for each client connection. The _gpg directories will be used later on for off-site backups.

## Client Setup (part 1)
Normally it is the root user on the client that interacts with the borg server, as the root user has access to the complete filesystem of the client. This could also be done as a specific user to backup only files for that user. In the examples, I will use `root@client_machine` as the user and host name; adjust as needed.

Install borg, `apt install borgbackup`.

Create a ssh key-pair, or identify one already created which has no passphrase associated with it. To create one:
```nohighlight
ssh-keygen -t ed25519
```
Press enter when prompted for a passphrase. This creates
```nohighlight
~/.ssh/id_ed25519        - the private key
~/.ssh/id_ed25519.pub    - the public key
```

----

*Note*: Running an agent is not required, as the key has no passphrase. Should you wish to use a ssh key with a passphrase, then the follow procedure is needed.

 Configure the user account to start the ssh agent and load their ssh key(s) into the ssh agent as they log in. This enables the client to log into the backup server unattended. Add this bit of script to the end of the user's `~/.bashrc`, or in some other way configure a ssh agent to run with they key just created:

```nohighlight
if [ ! -S ~/.ssh/ssh_auth_sock ]; then
  eval `ssh-agent`
  ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
ssh-add -l > /dev/null || ssh-add
```

----

Copy the public key of the client user to the backup server:
```nohighlight
ssh-copy-id -i ~/.ssh/id_ed25519.pub borgbackup@backup-server
```
Use the borgbackup password when prompted.

## Server Setup (part 2)
When `borg` is run as `borg serve` it operates in server mode. This is initiated by the ssh service configuration. A client connects to the backup server as the `borgbackup` user using their ssh public key, which is configured on the server to allow them access. The key-pair is created without a passphrase so that it can be used from an automated (cron) process on the client without user interaction. The login only allows the client to interact with the borg service, and the repository it is connected to is configured to only allow updates. This facilities security as well as making the repository grow in a way that its contents can be copied offsite incrementally.

### ssh configuration to run borg service

Log in to the server as `borgbackup`.  Edit the ssh configuration to dedicate the ssh public key authentication just added to a borg server process. Edit `~/.ssh/authorized_keys`, locate the new public key just added and edit that one line as so. Note the structure of this line has to be exact to the space, or it simply won't work and with very little feedback as to why.
```nohighlight
command="borg serve --restrict-to-path /mnt/raid/client_machine_repository",restrict ssh-ed25519 AAAA... root@client_machine
```
## Client setup (part 2)

### borg repository initialization

From the client, initialize the borg repository on the server using the ssh credentials just configured:
```nohighlight
borg init --encryption=none --append-only borgbackup@backup_server:/mnt/raid/client_machine_repository
# verify using:
borg list borgbackup@backup_server:/mnt/raid/client_machine_repository
```
Note on encryption: I choose to not encrypt the data using borg, but rather do encryption later using gpg for the off-site backup files. The files that are kept locally on the backup server do not need to be encrypted (as they are not encrypted on the actual client that is on the same network). The encryption provided by borg can be either password-only, or key plus password based, however it is not public/private key encryption (it is a form of symmetric encryption). Putting the burden of encryption on the borg process means configuring the client with the password for the repository and securing it, which can be done with some degree of safety, but in my use case, it is simpler to omit encryption at this stage.

Note on `borg list` command. This command has two uses. It will list the backups within the repository, as in the example above, or it can be used to list the contents of a specific backup by adding the identifier of the backup, like:
```nohighlight
borg list borgbackup@backup_server:/mnt/raid/client_machine_repository::client_machine-home-2020-01-01T00:00:00
```
### backup script
The backup script, on the client, runs borg as a client application to backup the client files and then again to prune the backup repository of unneeded prior backups. This script is based on the script on the borg [Quick Start](https://borgbackup.readthedocs.io/en/stable/quickstart.html) page:
```nohighlight
#!/bin/sh

# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

info "Starting backup"

# Backup the most important directories into an archive named after
# the machine this script is currently running on:

borg create                         \
    --stats                         \
    --one-file-system               \
    --verbose                       \
    --filter AME                    \
    --list                          \
    --show-rc                       \
    --compression auto,zlib         \
    --exclude-caches                \
    --exclude '/home/ken/.cache/*'  \
    'borgbackup@backup_server:/mnt/raid/client_machine_repository::{hostname}-home-{now}'            \
    '/home/ken'                      \

backup_exit=$?

info "Pruning repository"

# Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly
# archives of THIS machine. The '{hostname}-' prefix is very important to
# limit prune's operation to this machine's archives and not apply to
# other machines' archives also:

borg prune                          \
    --list                          \
    --prefix '{hostname}-home'      \
    --show-rc                       \
    --keep-hourly    2              \
    --keep-daily    14              \
    --keep-weekly    8              \
    --keep-monthly  -1              \
    'borgbackup@backup_server:/mnt/raid/client_machine_repository'                    \

prune_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

if [ ${global_exit} -eq 0 ]; then
    info "Backup and Prune finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup and/or Prune finished with warnings"
else
    info "Backup and/or Prune finished with errors"
fi

exit ${global_exit}
```
Note:

* Paths to exclude as well as root paths to backup are absolute paths.
* zlib compression is a reasonable compromise between small file size and speed.  `auto` causes borg to only compress when it makes sense to.

The script can be tested by running it directly from the command line.
### configure cron
Configure cron to run this script daily. For cron to run it, it has to have the correct file permissions, ie. owned by root and owner-only visibility:
```nohighlight
chmod go-rwx ~/borg_backup_script_home.sh
```
Next, create a symbolic link in /etc/cron.daily:
```nohighlight
cd /etc/cron.daily
ln -s /root/borg_backup_script_home.sh borg_backup_script_home
```
Note also that in addition to permissions, the file name of the symbolic link (not the script) cannot have an extension after it's name.

## Server - offsite backup configuration
Use this process to backup borg repository to offsite storage.

### Create temporary account to be used later in the process
Log into the backup server as your normal user that has access to root via sudo, or log in directly as root.

Create a temporary user account:
```nohighlight
adduser borgbackuptemp
```
This account will be used later to test the key-pair.

Log out.  Then log back in as the borgbackup user.

### Create GPG key-pair on backup server

Create a strong (long and random) password to use as the passphrase for the key-pair (the private key). This command can be used to generate one:
```nohighlight
< /dev/urandom tr -dc A-Za-z0-9 | head -c30;echo;
```
In your password manager, create an entry for this key and copy the passphrase there. Keep the entry open as there is more information to include, gathered below.

Create a key specifically for these off-site backups:
```nohighlight
tmux
gpg --full-generate-key
```
`tmux` is needed as a work-around for a permissions issue with the terminal when working with gpg (has to do with prompting for the private key passphrase).

gpg will prompt you for:

* key type - select 1 for RSA
* key size - enter 4096
* key is valid for - enter 0 (does not expire)
* Real name - use a full name
* Email address - use a valid internet addressable address (not a local/intranet address)
* Comment - enter 'borgbackup@backup' - this helps you identify the key later on and helps make the key's ID more unique.

These two fields together form the ID of the GPG key: 

`Firstname Lastname (borgbackup@backup) <user@mydomain.com>`

It will prompt for a passphrase. Paste in the password you created earlier.

When complete it will output details about the key. 

Enter these to get full details of the new key:
```nohighlight
gpg --list-keys
gpg --list-secret-keys
```
Copy all of this output from the console screen into the memo section of the password manager entry for this key's passphrase, starting from "gpg:  key ...."

### Export the GPG key-pair
```nohighlight
gpg --export-secret-keys "Firstname Lastname (borgbackup@backup) <user@mydomain.com>" > borgbackup_secretkey.gpg               
gpg --export "Firstname Lastname (borgbackup@backup) <user@mydomain.com>" > borgbackup_publickey.gpg               
gpg --export-ownertrust > borgbackup_otrust.gpg
```
Enter
```nohighlight
exit
```
to leave the `tmux` session. 

Log out as borgbackup.

### Test exported GPG key-pair
Log in as the borgbackuptemp user created earlier. Import the keys you just exported into this temporary account, then test that they work.

```nohighlight
tmux
gpg --import /home/borgbackup/borgbackup_secretkey.gpg
gpg --import /home/borgbackup/borgbackup_publickey.gpg
gpg --import-ownertrust < /home/borgbackup/borgbackup_otrust.gpg
gpg --list-secret-keys
gpg --list-keys
echo "testing 1 2 3" > testfile.txt                                                      
gpg --encrypt --recipient "Firstname Lastname (borgbackup@backup) <user@mydomain.com>" testfile.txt
gpg --decrypt testfile.txt.gpg > testfile.txt.decrypted                                  
diff -qs testfile.txt testfile.txt.decrypted
exit
```
The diff output should indicate the the files match.
Log out of the borgbackuptemp account. This account can be deleted.

### Save copies of key-pair
Log back in as the borgbackup user. 

Modify permissions of the exported secret key file:
```nohighlight
chmod go-rwx borgbackup_secretkey.gpg
```
Copy these three export files to multiple safe and secure locations.

### Create encrypted copy of borg repository
```nohighlight
cd /mnt/raid/

gpgdir --encrypt client_machine_repository \
      --Key-id "Firstname Lastname (borgbackup@backup) <user@mydomain.com>" \
      --no-delete --skip-test

cd client_machine_repository

find -mindepth 1 -type d -exec mkdir ../client_machine_repository_gpg/\{\} \;

find -mindepth 1 -type f -name "*.gpg" -exec mv \{\} ../client_machine_repository_gpg/\{\} \;

```
This process encrypts all of the files in the archive using the public key of the key-pair. The files are created right along side the originals. The `--no-delete` option is given so that the original files are not removed. Note that the `Key-id` can be specified with the name/email string, or you can use the long ID that is shown with `gpg --list-keys` (long string of 0-9, A-F characters).

The first `find` command duplicates the directory structure in the archive to the directory that will store the encrypted files. The second `find` command actually moves the encrypted files to their new location.

### Create Oracle archive cloud storage account
I chose to use Oracle's cloud storage for off-site backups because they have an option for archive storage, which is very economical. In return for this, what is stored there is not immediately available. To access the storage you first have to request access to it, which moves it into a normal cloud storage area for a selectable period of time. During that time period, you are paying a higher rate for the storage and can access the data. After this time window closes, the storage automatically reverts to archive storage. This is a fine trade off, since the only time I will need to access this data is if I loose not only the live system data, but also the live backup server.

There is a certain amount of Oracle lingo that goes with their cloud accounts, but most of it isn't important to worry about. You create an account which has a certain free period after which if left not upgraded to a paid account turns into always-free resource level account, which currently is 4 GB storage. I suggest that you only use the trial period resources to evaluate their system with test data. Be sure you remove the trial buckets you create and then convert the account to a paid account before using it for live data. I had some difficultly upgrading my account as I let it go past the trial period. I followed the upgrade process, but it didn't take effect until I removed all the existing data and buckets I had created there earlier.

The account will end up being an email address as the login and a password. The sign in page is titled "ORACLE Cloud Infrastructure, SIGN IN, Signing in to cloud tenant: xxxx." The tenant name is a name you choose on top of your account and it is tied to a particular geographic region. Below that there are two options to sign in. I could not get anywhere with the Single Sign-On SSO option; it will take you into a strange world of identity providers and federations. Instead use the other option, Oracle Cloud Infrastructure, it is a normal user-name, password login. Create a password manager entry for this account, 'Oracle Cloud Infrastructure' with the username and password.

Once you are signed in, note the right hand panel should show you your current billing cycle charges and days elapsed in the billing cycle. Once you have upgraded to a paid account, you should not see an upgrade banner at the top.

Create another password manager entry, this one for credentials you will use for the backup server to access the Oracle account, 'Oracle Cloud Backup Server Access'. 

* Click on the upper-right button for profile, User Settings. Scroll the screen down and select "Customer Secret Keys from the left menu. Click Generate Secret Key, name 'borgbackup_server_secret_key'.
  * The next screen will show you the Secret Access Key. Copy this as the password in the password manager entry. You *must* do this at this time, as you cannot retrieve or reset the password later on.
  * After the password screen, you will see a new entry under Customer Secret Keys. Hover over the Access Key field and choose copy.  Paste this into the password manager entry as the username.
* Click on the upper-right button for profile, Tenancy: xxxx. Find the field "Object Storage Namespace" and copy this field value into your password manager entry. 
* Click on the menu button, upper left, navigate to Administration, Region Management. The first region in the list should be shown in green as your home region. Copy the region identifier from this screen into your password manager entry.
Save the password manager entry.

Next we will create a bucket for each repository.

Click the menu button, upper left, and navigate to Object Storage, Object Storage. You will land on a screen where you define buckets. You may need to select the root compartment from the drop-down on the left. Create an archive type bucket for each backup client you defined locally including the same name. Click Create Bucket, change the bucket name, e.g. `borgbackup_client_machine_repository`, change the storage tier to "ARCHIVE". Remaining options can be left as default. Make note of this bucket name.

### Configure rclone on backup server

Log into the backup server as borgbackup.

You can configure rclone using the `rclone config` command and following the prompts, or start by creating a configuration file at `~/.config/rclone/rclone.conf:

```nohighlight
[borgbackup_oracle_cloud]
type = s3
provider = Other
env_auth = true
access_key_id = <copied-from-customer-secret-keys>
secret_access_key = <copied-from-create-customer-secret-keys-setup-screen>
region = <region identifier>
endpoint = https://<from-tenancy-object-storage-namespace>.compat.objectstorage.<region identifier>.oraclecloud.com
```

Using the information saved the password manager entry with name 'Oracle Cloud Backup Server Access':

* Replace the access key_id (username) and secret_access_key (password) with the username and password of the password manager entry.
* Replace tenancy namespace with the namespace value saved to the password manager entry.
* Replace the region identifier with the region identifier stored to the password manager entry - for both "region" and "endpoint"

Test that the configuration is working:

`rclone listremotes`

This should print "borgbackup_oracle_cloud". This is identifier for the configuration in the rclone.conf file.

`rclone lsd borgbackup_oracle_cloud:`

This will list the buckets you have created on oracle - all the items that can come after the colon in the path.

`rclone ls borgbackup_oracle_cloud:borgbackup_client_machine_repository`

This should return successfully without printing anything, as this bucket's folder is still empty.

### Encrypt configuration
Once the configuration is working, you can encrypt the configuration file, since the secret key is stored in the configuration.

Create a strong (long and random) password to use as the password for the configuration. This command can be used to generate one:
```nohighlight
< /dev/urandom tr -dc A-Za-z0-9 | head -c30;echo;
```
In your password manager, create an entry for this "oracle rclone configuration on backup server", copy the password into this entry.  For the username, you can store "borgbackup_oracle_cloud".  You may also want to include that the server's IP or name and that the entry belongs to the borgbackup user on that server and that it encrypts the rclone configuration.

run
```nohighlight
rclone config
```
and select option `s` to set configuration password. Then select option `a` to add password. Paste in the configuration password, and again to confirm. Select `q` and `q` again to exit out.

You will need the password when you run rclone.

### Push copy of borg repository to Oracle off-site bucket
```nohighlight
cd /mnt/raid/
rclone -v sync client_machine_repository_gpg \
    borgbackup_oracle_cloud:borgbackup_client_machine_repository
```
It will prompt for the configuration password, then copy up new/changed files.

### Update the off-site backup

Because the borg archive is setup to append only, any existing files will not change or need to be updated as additional backups are done. 

First, move the encrypted files back into the repository directory:

```nohighlight
cd /mnt/raid/client_machine_repository_gpg
find -mindepth 1 -type f -name "*.gpg" -exec mv \{\} ../client_machine_repository/\{\} \;
```

Then repeat the steps above, "Create encrypted copy of borg repository." So, rerun `gpgdir` to encrypt those files not already encrypted (`gpgdir` will skip files that are already encrypted, leaving them as they were), and rerun the two `find` commands to move the `.gpg` files back into the `client_machine_repository_gpg` directory. Then repeat the step above, "Push copy of borg repository to Oracle off-site bucket" to update the files in the Oracle bucket. This will copy up only the files not already there.

### Sample script to update off-site backup

This is a sample script to update an off-site backup.  This is stored in `/mnt/raid/update_offsite_for_asus.sh`, owned by borgbackup and set to executable. Adjust values as needed.

```nohighlight
#!/bin/bash -v

REPO="asus_home"
REPO_GPG="asus_home_gpg"

# move existing gpg files back into main repository
cd /mnt/raid/$REPO_GPG
find -mindepth 1 -type f -name "*.gpg" -exec mv \{\} ../$REPO/\{\} \;

# encrypt new files
cd /mnt/raid
gpgdir --encrypt $REPO --Key-id 7367000000000000DC0F2A850000000000006DFF --no-delete --skip-test

# move all encrypted files into the gpg directory
cd $REPO
find -mindepth 1 -type d -exec mkdir ../$REPO_GPG/\{\} \
find -mindepth 1 -type f -name "*.gpg" -exec mv \{\} ../$REPO_GPG/\{\} \;

# push new files up
cd /mnt/raid/
rclone -v sync $REPO_GPG borgbackup_oracle_cloud:borgbackup_asus_home
```

### Summary

This is a new system to me, but so far this seems functional. Borg seems to be a well-supported tool. The backup is accessable and understandable, which increases my confidence level in it.

Admittedly, there is a lot involved with the setup, but once complete, the process to update the off-site backups is fairly straightforward and could be scripted if desired. The client backups to the live backup server simply work. Just monitor your local mail to insure the backups are working as they should.

I am lacking perhaps the most important steps - verifying that the backup, either on-line or from off-site storage, is good. This will become a future post.

The one feature I find Borg is missing is a Windows client. Even though the software is Python based, this seems to not be available. Hoping updates to come in this regard.

If you find this useful, please provide feedback on what I may have missed, or other suggestions.

updated: 11/30/2020.
