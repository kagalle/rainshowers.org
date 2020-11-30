+++
Description = ""
Tags = [
]
date = "2016-08-17T22:55:27-05:00"
title = "Python environment and virtual environments"

+++

While working though an [introduction to virtual environments](https://www.dabapps.com/blog/introduction-to-pip-and-virtualenv-python/) I was able to get to the point that I was in the virtual environment by way of `activate` and then by habit, typed control-D to exit the virtual environment.  To my surprise I ended up exiting my entire terminal session, though it was obvious since I "sourced" `activate` into my current shell... never mind that.  This post is about a way to avoid all that.<!--more-->

### Summary of process when starting from a newly installed debian machine
--- Article updated 2/3/18

#### Initial setup only
Install pip
```nohighlight
sudo apt-get install python-pip
```
Install virtualenv (globally)
```nohighlight
sudo pip install virtualenv
```
Install vex (globally)  (Note: this has a dependency on virtualenv, so this step would suffice for both this step and the previous.)
```nohighlight
sudo pip install vex
```
#### Setup project space
Create the project folder and setup the environment

```nohighlight
~$ mkdir myproject
~$ cd myproject/
~/myproject$ virtualenv -p /usr/bin/python2 env2
Running virtualenv with interpreter /usr/bin/python2
New python executable in /home/ken/myproject/env2/bin/python2
Also creating executable in /home/ken/myproject/env2/bin/python
Installing setuptools, pip, wheel...done.
```

Enter the virtual environment using vex
```nohighlight
~/myproject$ vex --path env2 bash
```
Note: these steps don't include setting up the modified command prompt when within the environment, detailed below.

### Original article
So I went searching and found a page that described in full detail what I stumbled into, "[Virtualenv's bin/activate is Doing It Wrong](https://gist.github.com/datagrok/2199506)."

This page led to a project call [vex](https://github.com/sashahart/vex) which packaged up the idea layed out.

What was troubling me at first was why one minute running "pip list" showed the system installed python packages, while running it another time showed just those in the virtual environment.  What about the environment was making pip behave differently?  The version of pip that ends up in the virtual environment is not the same pip that is in the system.  I wasn't paying attention to what version was being run.  This is complicated by having both Python 2 and Python 3 installed on my system.  In the virtual environment, the modified PATH only overrides the versions of python and pip that the environment was created with.  If the virtual environment was created with Python 2, then running "pip3" is going to run the system pip, not the pip in the virtual environment.  So,

`/usr/bin/pip3`

and

`/home/ken/myproject/env3/bin/pip3`

are not the same at all, just named the same.

Steps so far...

Install virtualenv into my Python system packages.  I used "su" to work as root; sudo would also work.
```nohighlight
[root@host ~]# pip3 install virtualenv
```

Check my work
```nohighlight
bash-4.3$ pip3 list
```

Create a test project and create a virtual environment within it
```nohighlight
bash-4.3$ mkdir ~/myproject
bash-4.3$ cd ~/myproject
bash-4.3$ virtualenv -p /usr/bin/python3 env3
```
Compare pip between the system and the virtual environment
```nohighlight
bash-4.3$ meld /usr/bin/pip3 env3/bin/pip3
```
or if meld is not installed,
```nohighlight
bash-4.3$ diff /usr/bin/pip3 env3/bin/pip3
```
Prepare for installing packages into "user" space.  Edit ~/.profile and append:
```nohighlight
PATH=$PATH:/home/ken/.local/bin
```
Install vex into my user packages (not in the virtual environment)
```nohighlight
bash-4.3$ pip3 install --user vex
```
As specified in [3], add the code to .bashrc to change the prompt when in a virtual environment.  Edit ~/.bashrc, append the following and then logout and log back in:
```nohighlight
# python virtual environment support
function virtualenv_prompt() {
if [ -n "$VIRTUAL_ENV" ]; then
echo "(${VIRTUAL_ENV##*/}) "
fi
}
export PS1="$(virtualenv_prompt)$PS1"
```
Enter the virtual environment using vex:
```nohighlight
bash-4.3$ vex --path env3 bash
```
Check my work with the following.  The only packages installed in the virtual environment are pip, setuptools and wheel.
```nohighlight
(env3) bash-4.3$ pip3 list
```
Exit the vitual environment and check again.  The list now contains 8 items, including vex and virtualenv.
```nohighlight
(env3) bash-4.3$ exit
bash-4.3$ pip3 list
```
This also works for Python 2.
