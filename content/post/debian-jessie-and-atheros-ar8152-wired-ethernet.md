+++
title = "debian jessie and atheros ar8152 wired ethernet"
Description = ""
Tags = [
]
date = "2016-08-19T22:53:44-05:00"

+++

I did a little work with a Debian install and was not seeing the wired network card, even after loading the module, atl1c. Running ifconfig only showed the lo interface.<!--more-->

Turns out running iwconfig shows both interfaces eth0 and lo (I turned off the wireless interface for testing).

Running dhclient eth0 worked. I've never seen that happen before.

The other interesting thing I ran across is that lspci now has a -k option to show what kernel module goes with the hardware.