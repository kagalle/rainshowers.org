+++
Description = ""
Tags = []
date = "2018-02-11T15:55:00-05:00"
title = "Python Packaging"
+++

Packaging a Python project for distrubtion is just not straight forward.<!--more-->

Some parameters:

* Distributing a library or an application
* Distributing the source or byte-code, or some sort of executable
* Including a Python run-time with the application, or is it up to the user to install Python and know how to run your application inside Python
* How to avoid all the pit-falls that come with library paths, external packages, dependencies, Python v2 vs v3 compatibility, and the target host/OS it will be run on.

A simple Google search reveals that I'm not [alone](https://www.nylas.com/blog/packaging-deploying-python/), [in](http://docs.python-guide.org/en/latest/shipping/packaging/), [my](https://www.digitalocean.com/community/tutorials/how-to-package-and-distribute-python-applications), trials.

My real-world example is the application I wrote as a front-end to the `dar` backup utility, [darfortie](https://github.com/kagalle/darfortie). It started out as a bash script, quickly outgrew that and became a Python script with a few supporting modules as well as external dependancies, not the least of which is the `dar` application itself.

-----

The PyPI distribution described below works as it should, but it took me all of the steps below to realize that my problem was that I was installing it using `pip` as a normal user, instead of `sudo pip...` and so the execuatable was not ending up in a directory in my system `PATH`.

-----

Originally I had published the project as source code and as two executable formats, as described in this [ablepear](http://blog.ablepear.com/2012/10/bundling-python-files-into-stand-alone.html)  post, which I summarize below.

#### Source format
The source format lives in a directory 

`/home/ken/darfortie/darfortie` and contains three files:

- darfortie_params.py
- darfortie_previous_file.py
- \__main__.py

The \__main__.py file imports the other two files and contains a `main()`, along with the requisite 

```text
if __name__ == '__main__':
    main()
```
So, if I'm in the directory `/home/ken/darfortie`, I can run the app using

```text
$ python darfortie
```

A shell script also works:

```text
#!/bin/bash
cd /home/ken/darfortie
/usr/bin/python darfortie $@
```
#### Executable format
The first executable format is a zip file that contains the same three files, above:

- darfortie_params.py
- darfortie_previous_file.py
- \__main__.py
This app runs in a similar way, I can run the app using:
```text
$ python /home/ken/darfortie/darfortie.zip
```
The second executable format is zip file renamed as `darfortie`, has its attributes set to executable and with the line `#!/usr/bin/env python` prepended to the file. This runs as:
```text
$ python /home/ken/darfortie/bin/darfortie
```
All of this is fine and works as expected. Enter PyPI...
#### PyPI

[PyPI](pypi.python.org) is the defacto repository for Python software, and so to make my project available this way, I made some changes to the project.

1. PyPI only supports ReStructured text (.rst) for the readme.  Github supports both .rst and Markdown (.md).  So I converted my readme file to .rst and updated the contents, removing the information about running darfortie from source, or zip, as I described above, and changed it to instruct how to install the project using `pip` which is the application that interfaces with the PyPI repository and installs applications on a client machine.
2. Renamed the `__main__.py` module to `darfortie_main.py`.
3. Created a new module `__init__.py` which simply imports the three modules of the project:
```text
darfortie_main
darfortie_params
darfortie_previous_file
```
4. Created a setup.py file which PyPI uses to register the application.

This was uploaded and as a result you can run this to install darfortie on a machine:
```text
pip install -i https://pypi.python.org/pypi darfortie
```
If this is done as a normal user, then the install puts the package in
```text
/home/ken/.local/lib/python2.7/site-packages/darfortie
```
and creates an execuatable such that the application can be run by:
```text
$ ./local/bin/darfortie
```
If installed as `root`, then the install is done into
```text
/usr/local/lib/python2.7/dist-packages/darfortie
```
and the executable is created as:
```text
/usr/local/bin/darfortie
```
which is normally on the system PATH.

