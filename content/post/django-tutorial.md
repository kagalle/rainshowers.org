+++
Description = ""
Tags = [
]
date = "2017-12-26T22:38:00-05:00"
title = "Django and Python3 notes"

+++


Notes while working though the [Writing your first Django app tutorial](https://docs.djangoproject.com/en/2.0/intro/tutorial01/).<!--more-->

To get anywhere I need python3, and pip:
```text
~$ sudo apt-get install python3-pip
```
Install virtualenv and vex globally:
```text	
~$ sudo pip3 install virtualenv vex
```
Create a directory structure:
```text
~$ mkdir -p django/tutorial01
~$ cd django/tutorial01
~/django/tutorial01$
```
Create a virtal environment to work in:\
See [virtual environments](python-environment-and-virtual-environments) for more information.
```text
~/django/tutorial01$ virtualenv -p /usr/bin/python3 env3
```
Enter the virtual environment:
```text
~/django/tutorial01$ vex --path env3 bash
```
Verify the environment is a ready to use (specifically that the list of python modules available is limited to):
```text
(env3) ~/django/tutorial01$ pip3 list
	pip (9.0.1)
	setuptools (38.2.5)
	wheel (0.30.0)
```
Install django:
```text
(env3) ~/django/tutorial01$ pip3 install Django
``` 
Create a project:
```text
(env3) ~/django/tutorial01$ cd env3
(env3) ~/django/tutorial01/env3$ django-admin startproject mysite
(env3) ~/django/tutorial01/env3$ cd mysite/
```
Create a repository for the initial project and commit work done so far:
```text
(env3) ~/django/tutorial01/env3/mysite$ git init
(env3) ~/django/tutorial01/env3/mysite$ git add manage.py mysite
(env3) ~/django/tutorial01/env3/mysite$ git commit -m"check in initial just-created project"
```
Start the development server to test:
```text
(env3) ~/django/tutorial01/env3/mysite$ python manage.py runserver
	Performing system checks...
	...
	Starting development server at http://127.0.0.1:8000/
```
Open a browser to the above URL.

Create the polls app:
```text
(env3) ~/django/tutorial01/env3/mysite$ python manage.py startapp polls
```
Edit the `polls/views.py`, `polls/urls.py`, and `mysite/urls.py` as described in the documentation.

Navigate to the polls URL, as described in the tutoral.

Ending directory structure, which is somewhat unclear from the tutorial:
```text
(env3) ~/django/tutorial01$ find env3/mysite/ \( -type d -name __pycache__ -prune \) -o -print
	env3/mysite/
	env3/mysite/manage.py
	env3/mysite/mysite
	env3/mysite/mysite/wsgi.py
	env3/mysite/mysite/urls.py
	env3/mysite/mysite/__init__.py
	env3/mysite/mysite/settings.py
	env3/mysite/db.sqlite3
	env3/mysite/polls
	env3/mysite/polls/tests.py
	env3/mysite/polls/admin.py
	env3/mysite/polls/urls.py
	env3/mysite/polls/views.py
	env3/mysite/polls/apps.py
	env3/mysite/polls/models.py
	env3/mysite/polls/migrations
	env3/mysite/polls/migrations/__init__.py
	env3/mysite/polls/__init__.py
```
	