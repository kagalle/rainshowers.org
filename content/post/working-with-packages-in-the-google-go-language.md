+++
Description = ""
Tags = [
]
date = "2010-08-06"
title = "Working with packages in the Google Go language"

+++

I used the go provided "hello world" example to explore creating and using packages.<!--more-->

* The hello package does the work of printing hello.
* main.go uses the hello package to print hello.

In both cases below, the directory structure is not significant in the naming or organization of the package, as it is in Java. The .a static library doesn't contain any directory structure - essentially just enclosing the contents of one folder. If the packages are laid out in a directory structure, then the .a libraries are simply placed in actual directories as needed.

Using a folder to contain the object files of the package

```text
#Directory containing the source of both hello.go and main.go.
[ken@asus hello]$ ls
hello.go  hello_src  main.go
```
```text
# hello_src is a directory containing the object file for hello.go, namely hello.8.
[ken@asus hello]$ ls hello_src
hello.8
```
```text
# compile main.go
# compile fails - can't find hello package
[ken@asus hello]$ ~/bin/8g  main.go
main.go:4: can't find import: hello
```
```text
# try again, tell compiler to look in the hello_src directory for included files.
[ken@asus hello]$ ~/bin/8g -Ihello_src main.go
[ken@asus hello]$ ls -lrt
-rw-r--r-- 1 ken ken  115 Nov 16  2009 hello.go
drwxr-xr-x 2 ken ken 4096 Jun 13 22:18 hello_src
-rw-r--r-- 1 ken ken   87 Jun 13 22:19 main.go
-rw-r--r-- 1 ken ken 3402 Jun 15 21:50 main.8
```
```text
# link the files
# link fails - can't find hello
[ken@asus hello]$ ~/bin/8l main.8
??none??: cannot open file: /home/ken/go/pkg/linux_386/hello.8
```
```text
# tell linker to look in the hello_src directory
[ken@asus hello]$ ~/bin/8l -Lhello_src main.8
[ken@asus hello]$ ls -lrt
-rw-r--r-- 1 ken ken    115 Nov 16  2009 hello.go
drwxr-xr-x 2 ken ken   4096 Jun 13 22:18 hello_src
-rw-r--r-- 1 ken ken     87 Jun 13 22:19 main.go
-rw-r--r-- 1 ken ken   3402 Jun 15 21:50 main.8
-rwxr-xr-x 1 ken ken 666048 Jun 15 21:52 8.out
Using a real .a static library file to form package
```
```text
# create the package - hello.a
# add the "c" option in addition to "r" and "g" to avoid the "gopack..." comment
# g = maintain go type information in library
# r = add or replace files
[ken@asus hello]$ ~/bin/gopack rg hello.a hello_src/*
gopack: creating hello.a
```
```text
# create a "test" directory to test the new library in
# copy hello.a and main.go to it
[ken@asus test]$ ls
hello.a  main.go
```
```text
# compile main.go
# fails - can't find lib
[ken@asus test]$ ~/bin/8g main.go
main.go:4: can't find import: hello
```
```text
# compiles OK - look in current directory for hello lib
[ken@asus test]$ ~/bin/8g -I. main.go
[ken@asus test]$ ls -lrt
-rw-r--r-- 1 ken ken   87 Jun 15 21:43 main.go
-rw-r--r-- 1 ken ken 8486 Jun 15 21:44 hello.a
-rw-r--r-- 1 ken ken 3412 Jun 15 21:45 main.8
```
```text
# link
# fails - can't find hello lib - only place it looks is under $GOHOME/pkg/linux_386
[ken@asus test]$ ~/bin/8l main.8
??none??: cannot open file: /home/ken/go/pkg/linux_386/hello.a
```
```text
# links OK - also look for libraries in the current directory
[ken@asus test]$ ~/bin/8l -L. main.8

[ken@asus test]$ ls -lrt
-rw-r--r-- 1 ken ken     87 Jun 15 21:43 main.go
-rw-r--r-- 1 ken ken   8486 Jun 15 21:44 hello.a
-rw-r--r-- 1 ken ken   3412 Jun 15 21:45 main.8
-rwxr-xr-x 1 ken ken 666064 Jun 15 21:45 8.out
```
