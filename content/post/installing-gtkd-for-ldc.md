+++
Description = ""
Tags = [ "ldc", "gtk" ]
date = "2009-12-13"
title = "Installing gtkD for ldc"

+++
<!--more-->

1. Download gtkD 1.3 from [gtkd](http://www.dsource.org/projects/gtkd)
1. unzip
1. run `make` to run the GNUmakefile in the base directory.
1. `su` to root 
1. `make install` copies include and lib files under /usr/local/.

libraries:
```nohighlight
libgtkd.a
libgtkdgl.a
libgtkdsv.a
```
Test it out...

1. cd to gtkD/demos/gtk
1. try to compile HelloWorld.d.

First attempt was to do

`ldc HelloWorld.d`

That resulted in a linking error:
```nohighlight
/usr/local/lib/libgtkd.a(Loader.o): In function `_D4gtkc6Loader6Linker17dumpLoadLibrariesFZv':
gtkc.Loader:(.text+0x4e8): undefined reference to `_D5tango2io6Stdout6StdoutC5tango2io6stream6Format20__T12FormatOutputTaZ12FormatOutput'
gtkc.Loader:(.text+0x518): undefined reference to `_D5tango2io6stream6Format20__T12FormatOutputTaZ12FormatOutput8formatlnMFAaYC5tango2io6stream6Format20__T12FormatOutputTaZ12FormatOutput'                                                                                                                               
/usr/local/lib/libgtkd.a(Loader.o): In function `_D4gtkc6Loader6Linker15dumpFailedLoadsFZv':                                                                 
gtkc.Loader:(.text+0x6d8): undefined reference to `_D5tango2io6Stdout6StdoutC5tango2io6stream6Format20__T12FormatOutputTaZ12FormatOutput'                    
gtkc.Loader:(.text+0x71c): undefined reference to `_D5tango2io6stream6Format20__T12FormatOutputTaZ12FormatOutput8formatlnMFAaYC5tango2io6stream6Format20__T12FormatOutputTaZ12FormatOutput'                                                                                                                               
/usr/local/lib/libgtkd.a(Loader.o): In function `_D4gtkc6Loader12pLoadLibraryFAaE4gtkc6Loader4RTLDZPv':                                                      
gtkc.Loader:(.text+0x7d9): undefined reference to `_D5tango4stdc7stringz9toStringzFAaAaZPa'                                                                  
gtkc.Loader:(.text+0x83c): undefined reference to `_D5tango4stdc7stringz9toStringzFAaAaZPa'                                                                  
/usr/local/lib/libgtkd.a(Loader.o): In function `_D4gtkc6Loader10pGetSymbolFPvAaZPv':                                                                        
gtkc.Loader:(.text+0x894): undefined reference to `_D5tango4stdc7stringz9toStringzFAaAaZPa'                                                                  
/usr/local/lib/libgtkd.a(Loader.o):(.rodata+0x10): undefined reference to `_D5tango2io6Stdout8__ModuleZ'                                                     
collect2: ld returned 1 exit status                                                                                                                          
Error: linking failed:                                                                                                                                       
status: 1
```
After a lot of searching, I found a note is post that alluded to a solution - link manually with gcc, instead of letting ldc do the linking:

```nohighlight
ldc -c HelloWorld.d
gcc HelloWorld.o -o HelloWorld -lm -lpthread -ldl -lgtkd -ltango-base-ldc -ltango-user-ldc -v
Using built-in specs.
Target: i686-pc-linux-gnu
Configured with: ../configure --prefix=/usr --enable-shared --enable-languages=c,c++,fortran,objc,obj-c++,ada --enable-threads=posix --mandir=/usr/share/man --infodir=/usr/share/info --enable-__cxa_atexit --disable-multilib --libdir=/usr/lib --libexecdir=/usr/lib --enable-clocale=gnu --disable-libstdcxx-pch --with-tune=generic
Thread model: posix
gcc version 4.4.2 (GCC)
COMPILER_PATH=/usr/lib/gcc/i686-pc-linux-gnu/4.4.2/:/usr/lib/gcc/i686-pc-linux-gnu/4.4.2/:/usr/lib/gcc/i686-pc-linux-gnu/:/usr/lib/gcc/i686-pc-linux-gnu/4.4.2/:/usr/lib/gcc/i686-pc-linux-gnu/:/usr/lib/gcc/i686-pc-linux-gnu/4.4.2/:/usr/lib/gcc/i686-pc-linux-gnu/
LIBRARY_PATH=/usr/lib/gcc/i686-pc-linux-gnu/4.4.2/:/usr/lib/gcc/i686-pc-linux-gnu/4.4.2/:/usr/lib/gcc/i686-pc-linux-gnu/4.4.2/../../../:/lib/:/usr/lib/
COLLECT_GCC_OPTIONS='-o' 'HelloWorld' '-v' '-mtune=generic'
 /usr/lib/gcc/i686-pc-linux-gnu/4.4.2/collect2 --eh-frame-hdr -m elf_i386 --hash-style=both -dynamic-linker /lib/ld-linux.so.2 -o HelloWorld /usr/lib/gcc/i686-pc-linux-gnu/4.4.2/../../../crt1.o /usr/lib/gcc/i686-pc-linux-gnu/4.4.2/../../../crti.o /usr/lib/gcc/i686-pc-linux-gnu/4.4.2/crtbegin.o -L/usr/lib/gcc/i686-pc-linux-gnu/4.4.2 -L/usr/lib/gcc/i686-pc-linux-gnu/4.4.2 -L/usr/lib/gcc/i686-pc-linux-gnu/4.4.2/../../.. HelloWorld.o -lm -lpthread -ldl -lgtkd -ltango-base-ldc -ltango-user-ldc -lgcc --as-needed -lgcc_s --no-as-needed -lc -lgcc --as-needed -lgcc_s --no-as-needed /usr/lib/gcc/i686-pc-linux-gnu/4.4.2/crtend.o /usr/lib/gcc/i686-pc-linux-gnu/4.4.2/../../../crtn.o
``` 
And that leaves me with an executable that runs.

Other information I found, seemed to indicate that I needed to use dsss to build. That went nowhere because there doesn't appear to be any way to install dsss with/to-work-with ldc (only dmd and gdc).

At this point my /usr/local/bin/ldc.conf is... "/usr/local/include/d" contains the header files for gtk.
```nohighlight
default:
{
    // 'switches' holds array of string that are appends to the command line
    // arguments before they are parsed.
    switches = [
        "-I/usr/local/include",
        "-I/usr/local/include/tango",
        "-I/usr/local/include/d",
        "-L-L/usr/local/lib",
        "-L-ltango-user-ldc",
        "-d-version=Tango",
        "-defaultlib=tango-base-ldc",
        "-debuglib=tango-base-ldc"
    ];
};
```
It seems as though ldc should be able to be configured to link, since I think it uses gcc to do its linking. Seems there is something about gtkD needing to be able to load gtk libraries dynamically.

Notes: The LGPL license is modified to allow for static linking for non-GPL applications. See "COPYING" in the base directory.