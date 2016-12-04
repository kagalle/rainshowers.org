+++
Description = ""
Tags = [
]
date = "2012-01-14"
title = "Use netcat to copy large files"

+++

The lightweight netcat utility can be used to copy large files quickly bewteen machines when encryption is not a concern... and say the nfs gods are not smiling on you today and you don't want to wait for a ~3 MB/s copy with scp.<!--more-->

On the machine that has the file to copy:

`netcat -v 192.168.15.12 9999 < some_big_file.tgz`

* `-v` Be verbose about what it is doing (gives helpful hints if it isn't working for some reason).
* `192.168.15.12` The name or address of the destination machine.
* `9999` Any unused port number.
* `< some_big_file.tgz` Redirect the content of the file into netcat.

On the destination machine:

`netcat -v -l -p 9999 > some_big_file.tgz`

* `-v` Be verbose about what it is doing (gives helpful hints if it isn't working for some reason).
* `-l` Listen mode of netcat
* `-p 9999` The port to listen on - the same port as used above.
* `> some_big_file.tgz` Create a new file from the data that arrives from netcat.

Run the destination machine command first, then the source machine.

The two netcat-s remain running after the file is transfered.  You need to type control-c on the sending side to turn off netcat after the copy is done.  You can use another terminal to verify that the file is complete.

Whole directories can also be moved:

On the machine that has the file to copy:

`tar -cv some_directory/* | netcat -v 192.168.15.12 9999`

* `tar -cv some_directory/*` Bundle up the directory and all the files in it
* `|` Send that into...
* `netcat` just like before

On the destination machine:

`netcat -v -l -p 9999 | tar -xv`

* `netcat`  Take the data that arrives from netcat
* `|` send that into...
* `tar -xv` To unbundle the directory and files again into the current directory

Update:

I found a Java version of netcat [here](http://rrusin.blogspot.com/2012/05/netcat-in-java.html).