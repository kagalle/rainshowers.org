+++
Description = ""
date = "2016-12-04T18:06:32-05:00"
title = "qemu virtual machine and bridged network"
Tags = [
]

+++

There are many articles that describe configuring bridged networking for qemu virtual hosts and clients. None I found seemed to be completely helpful, but I finally found a solution that worked for me.<!--more-->

The reason for needing to use bridging is so that you can connect to the virtual machine from anywhere on the network, including the host that it is running on.

The user-mode networking that is enabled by default works only in one direction, at least easily. It uses NAT, so the same rules apply as you would have between the Internet and a typical home router. The only way to make a connection to the server machine (the virtual machine) is to port-forward specific ports to it. This works fine, but it doesn't work well if the domain-name needs to be consistent, ie. you don't want the port number in the URL. I was not able to forward the well-known port number. This is an example of how to use port-forwarding with qemu:

```
qemu-system-x86_64 \
    -boot menu=on  \
    -drive file=image.qcow2,format=qcow2 \
    -enable-kvm    \
    -m 1G          \
    -net user,hostfwd=tcp::5555-:80
```
This forwards port 5555 on the host machine to port 80 on the guest (virtual machine), which leads to having to use a URL like:

`http://localhost:5555/`

The solution that worked for me was to

* Setup a Debian linux host. I had previously used Devuan to get a debian based system without systemd, however, apparently the virt-manager application now has a dependency against something that is systemd specific.  So I went with Debian testing 8.10.  I used the `jigdo` utility to obtain the installation `.iso`:
```bash
sudo apt-get install jigdo-file
jigdo-lite http://cdimage.debian.org/cdimage/weekly-builds/amd64/jigdo-cd/debian-testing-amd64-netinst.jigdo
```
being careful to specify an appropriate mirror.

* Setup a bridge on the host, even before considering what qemu will require. To follow the below example, the DNS related lines require the installation of "resolvconf".

    In /etc/network/interfaces, setup the main network card like so:
    
    ```bash
    auto br0
    iface br0 inet static
    # This is the address of the bridge (and so, the host).
    address 192.168.15.12
    netmask 255.255.255.0
    # This is the address of the real gateway on the network (to the Internet).
    gateway 192.168.15.1
    # This is my local (internal) domain name.
    dns-domain birchtreefarm.local
    # This points at my local (internal) DNS server, and an alternate.
    dns-nameservers 192.168.15.10 192.168.15.1
    # This adds the network interface of the host to the bridge.
    # Adjust this to match the name of the interface on the machine.
    bridge_ports eth1
    # This runs brctl to bring up the bridge.
    /sbin/brctl stp br0 on
    ```
        
* Install "Virtual Machine Manager" (virt-manager). This will pull in qemu as a dependency if you don't already have it installed.

* Create a new virtual machine using the existing virtual drive image (qcow2).

* On step 4 under "Network selection," choose "Specify shared device name" and enter `br0` for the "Bridge name".
(Note previous instructions were: For the network settings, "br0" will appear as a device name; use virtio as the device model.)

References

https://devuan.org/<br>
https://virt-manager.org/<br>
https://wiki.debian.org/NetworkConfiguration#Bridging<br>

*Last updated: 12/10/2016 10:04pm*
