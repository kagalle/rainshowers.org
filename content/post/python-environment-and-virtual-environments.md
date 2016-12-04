+++
Description = ""
Tags = [
]
date = "2016-08-17T22:55:27-05:00"
title = "Python environment and virtual environments"

+++

While working though an introduction to virtual environments[1] I was able to get to the point that I was in the virtual environment by way of `activate` and then by habit, typed control-D to exit the virtual environment.  To my surprise I ended up exiting my entire terminal session, though it was obvious since I "sourced" `activate` into my current shell... never mind that.  This post is about a way to avoid all that.<!--more-->

So I went searching and found[2] a page that described in full detail what I stumbled into, "Virtualenv's bin/activate is Doing It Wrong."

This page led to a project call vex[3] which packaged up the idea layed out.

What was troubling me at first was why one minute running "pip list" showed the system installed python packages, while running it another time showed just those in the virtual environment.  What about the environment was making pip behave differently?  The version of pip that ends up in the virtual environment is not the same pip that is in the system.  I wasn't paying attention to what version was being run.  This is complicated by having both Python 2 and Python 3 installed on my system.  In the virtual environment, the modified PATH only overrides the versions of python and pip that the environment was created with.  If the virtual environment was created with Python 2, then running "pip3" is going to run the system pip, not the pip in the virtual environment.  So,

`/usr/bin/pip3`

and

`/home/ken/myproject/env3/bin/pip3`

are not the same at all, just named the same.

Steps so far...

1. Install virtualenv into my Python system packages.  I used "su" to work as root; sudo would also work.<br>
    `[root@host ~]# pip3 install virtualenv`

2. Check my work<br>
    `bash-4.3$ pip3 list`

3. Create a test project and create a virtual environment within it<br>
    `bash-4.3$ mkdir ~/myproject`<br>
    `bash-4.3$ cd ~/myproject`<br>
    `bash-4.3$ virtualenv -p /usr/bin/python3 env3`<br>

4. Compare pip between the system and the virtual environment<br>
     `bash-4.3$ meld /usr/bin/pip3 env3/bin/pip3`<br>

     or if meld is not installed,<br>

     `bash-4.3$ diff /usr/bin/pip3 env3/bin/pip3`<br>

5. Prepare for installing packages into "user" space.  Edit ~/.profile and append:<br>

    `PATH=$PATH:/home/ken/.local/bin`<br>

6. Install vex into my user packages (not in the virtual environment)<br>

    `bash-4.3$ pip3 install --user vex`<br>

7. As specified in [3], add the code to .bashrc to change the prompt when in a virtual environment.  Edit ~/.bashrc, append the following and then logout and log back in:<br>

    `function virtualenv_prompt() {`<br>
    `if [ -n "$VIRTUAL_ENV" ]; then`<br>
    `echo "(${VIRTUAL_ENV##*/}) "`<br>
    `fi`<br>
    `}`<br>
    `export PS1='$(virtualenv_prompt)\s-\v\$ '`<br>

8. Enter the virtual environment using vex:<br>

    `bash-4.3$ vex --path env3 bash`<br>

9. Check my work with the following.  The only packages installed in the virtual environment are pip, setuptools and wheel.<br>

    `(env3) bash-4.3$ pip3 list`<br>

10. Exit the vitual environment and check again.  The list now contains 8 items, including vex and virtualenv.<br>

    `(env3) bash-4.3$ exit`<br>
    `bash-4.3$ pip3 list`<br>

There are some variations with Python 3, but as seen above, what works for Python 2 also works for Python 3.[4]  I'll save that for another day.

 

[1] https://www.dabapps.com/blog/introduction-to-pip-and-virtualenv-python/

[2] https://gist.github.com/datagrok/2199506

[3] https://github.com/sashahart/vex

[4] https://docs.python.org/3/library/venv.html