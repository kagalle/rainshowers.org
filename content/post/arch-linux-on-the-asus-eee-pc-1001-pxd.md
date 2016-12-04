+++
date = "2011-05-11"
title = "Arch Linux on the Asus Eee PC 1001 PXD"
Tags = [
]
Description = ""

+++

I recently purchased an Asus Eee PC to have something convenient to have at work, mostly for web and music.  I was thinking I would leave the Windows Starter OS on it and add Linux for dual boot.  But after reading some of MS's EULA, I decided I'd rather not "check the box" and instead install some distribution of Linux.<!--more-->

I normally use Arch Linux, but I gave Debian a try thinking it might be straight-forward.  I also read a few posts about Debian variants designed just for net-books.  My results, for whatever reason, weren't stellar.  It booted, but without X.  Most annoying was the total lack of content in the fstab file.  I don't know what sort of magic was going on with that, but it seemed to be an un-feature.

So I tried Arch.  The installation media hasn't been updated for about a year - so the kernel is old.  To my surprise, the kernel does have support for the wireless network but not the wired Ethernet.  So after shuffling the thumb-drive back and forth for awhile, I decided I'd be better off powering up an old wireless router as an access point with no security - just long enough to update.  A quick iwconfig and dhcpcd and I was connected.  Once the system update was done, it was just like setting up any system.

Most things just worked.  I had a little trouble with sound - I ended up just leaving the configuration alone, despite what the arch eee wiki suggested.  The number of controls in the mixer is smaller, but all work correctly.  In addition the audio from the headphone jack works this way.

My only big mistake was choosing an out of date mirror.  I had to figure that out the hard way and then update the machine again.

The track-pad is a little jumpy, but I've never been a fan of track-pads.  It appears to be dual core, and using XFCE4 leaves me with plenty of memory, even with the stock 1GB.  It apparently can be upgraded to 2GB.

The power connector is small, and so I take some care when plugging that in or unplugging it.  The keyboard is nice.  There is a dedicated "del" key, which is nice to have without having to hold the Fn key down.  The wide screen compensates for the small screen size overall.  It is as powerful, if not more so than my desktop.  All in all, I'm very happy with it.
