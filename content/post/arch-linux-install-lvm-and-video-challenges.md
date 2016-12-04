+++
Description = ""
Tags = [
]
date = "2011-07-24"
title = "Arch Linux Install - LVM and video challenges"

+++

The latest install media for Arch Linux is dated May 2010, which is not a problem except that the kernel is beginning to show its age and as I recently found out, there are a few issues with creating a system with LVM volumes.<!--more-->

I ran /arch/setup and switched to another console to get dm-mod loaded.  I was able to get LVM filesystems specified and created using the installer, but the whole thing crashed while trying to create the boot partition.  I've never seen that before.  Anyway, after that the LVM stuff was on there and the "roll back previous changes" option really didn't help any because LVM will refuse to recreate if it sees stuff already there.

So, I ended up doing the install as I used to do - doing the LVM stuff outside of the installer and then just specifying in the installer what LVM volumes I want to use where.  Since the LVM volumes were already created, I just used them (after rebooting).  All that was needed was to run these three commands before starting the installer - modprobe dm-mod; vgscan; vgchange -ay.

Before I used to have to create them all manually and then proceed to the installer.  If I had to do it again, that is how I would do it.  I found the very deeply nested screens involved with creating LVM volumes in the installer taxing.  They mostly make sense, but it is just easier to understand doing it manually.  In addition you can use the "-l +100%FREE" option to specify all remaining free space.

I used this page as a guide, though not a step-by-step one.  http://wiki.archlinux.org/index.php/LVM

The other thing I found was that on the system I was setting up (AMD with ATI video) the system would hang and the screen would go blank half way though booting up from the install media (USB).  I had to add "nomodeset" to the kernel line to get it to boot completely.  It wasn't an issue with the installed system - at that point in the boot process the text console switched to a higher resolution correctly.
