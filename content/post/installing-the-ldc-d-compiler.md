+++
Tags = [ "Compilers", "ldc" ]
date = "2009-12-04"
title = "Installing the ldc D Compiler"
Description = ""

+++

The D language compiler [ldc](http://www.dsource.org/projects/ldc%7Cldc) is not yet part of the standard repository of packages available for arch linux. There are some "aur" [community contributed items](http://aur.archlinux.org/packages.php?O=0&K=ldc&do_Search=Go). I chose to build from source.<!--more-->

 Instructions page at [build instructions](http://www.dsource.org/projects/ldc/wiki/BuildInstructions). Ldc is built for the [llvm](http://llvm.org/) low level virtual machine. Currently the 2.6 release version of llvm is used. The instructions have you downloading the release as a zip - but I chose to check out the release from the [svn repository](http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_26) - since before the release that was the only option. Ldc doesn't have an up-to-date release and so the current development snap-shot is used. In summary:

llvm:
```nohighlight
subversion repository
http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_26
r89983
```
ldc:
```nohighlight
mercurial repository
http://hg.dsource.org/projects/ldc
42fc0d955a0d 11/15/2009 13:22:02 +0000
```
In addition, other requirements are:
```nohighlight
libconfig: from libconfig-1.3.2.tar.gz
cmake: installed from pacman; 2.6.4-2
```
Following the instructions worked as expected. When I'm building something from source without the benifit of package management, I keep that software under /usr/local. This is the default mostly, but when running ccmake for ldc, I needed to change two configuration settings:

`LIBCONFIG_LDFLAGS="-L/usr/local/lib -lconfig++"`
I received help for this from this post on the ldc forum.

`CMAKE_CXX_FLAGS="-DLLVM_REV=89983"`
This change was based on an error message I recieved when I first tried the build.

Tango

I followed the [tango build instructions](http://groups.google.com/group/ldc-dev/browse_thread/thread/bbed5ab72de76e6c) - which boils down to checking out the trunk of tango (http://svn.dsource.org/projects/tango/)trunk r4902 and running build.sh in the build directory. I ran this as a normal user, and so the install section of the script failed. I did the install manually by copying:
```nohighlight
cp build/libs/* /usr/local/lib/
cp -r user/* /usr/local/include/
```
Setting_up_include_and_library_paths

This part is not well documented, or dare I say, not documented at all. When ldc is run you need to either specify on the command-line what to include (include files) and what to link to (libraries) along with the file(s) you are compiling. The other option is to put this include and library information in the ldc.conf file. For me it is located where my ldc execuatable is, `/usr/local/bin/ldc.conf`.

After the install it looked like this
```nohighlight
bash-4.0# cat ldc.conf.original
// This configuration file uses libconfig.
// See http://www.hyperrealm.com/libconfig/ for syntax details.

// Special macros:
// %%ldcbinarydir%%
//  - is replaced with the path to the directory holding the ldc executable

// The default group is required
default:
{
    // 'switches' holds array of string that are appends to the command line
    // arguments before they are parsed.
    switches = [
        "-I<where I installed ldc from>/../tango",
        "-I<where I installed ldc from>/../tango/lib/common",
        "-L-L%%ldcbinarypath%%/../lib",
        "-d-version=Tango",
        "-defaultlib=tango-base-ldc",
        "-debuglib=tango-base-ldc"
    ];
};
```
By experimentation, I ended up with...
```nohighlight
default:
{
    // 'switches' holds array of string that are appends to the command line
    // arguments before they are parsed.
    switches = [
        "-I/usr/local/include",
        "-I/usr/local/include/tango",
        "-L-L/usr/local/lib",
        "-L-ltango-user-ldc",
        "-d-version=Tango",
        "-defaultlib=tango-base-ldc",
        "-debuglib=tango-base-ldc"
    ];
};
```
The first option is the one that ldc gets. -I specifies an include path. -L specifies things that you want to send to the linker. So, -L-l specifies to the linker actual libraries you want to link with. -L-L specifies to the linker paths to look in to find the libraries.