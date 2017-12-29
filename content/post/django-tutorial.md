+++
Description = ""
Tags = [
]
date = "2017-12-26T22:38:00-05:00"
title = "Django and Python3 notes"

+++


Notes while working though the [Writing your first Django app tutorial](https://docs.djangoproject.com/en/2.0/intro/tutorial01/).

To get anywhere I need python3, pip3:

	sudo apt-get install python3-pip
	
Install virtualenv globally:
	
	sudo pip3 install virtualenv

Create a directory structure:

	/home/ken/django/tutorial01

Create a virtal environment to work in:

	virtualenv -p /usr/bin/python3 env3
	
Enter the virtual environment:

	vex --path env3 bash
	
Verify there is a ready to use environment (specifically that the list of python modules available is limited to):

	(env3) bash-4.4$ pip3 list
	pip (9.0.1)
	setuptools (38.2.5)
	wheel (0.30.0)

Install django:

	   pip3 install Django
	   
Create a project:

	(env3) bash-4.4$ pwd
	/home/ken/django/tutorial01/env3
	(env3) bash-4.4$ django-admin startproject mysite
	(env3) bash-4.4$
	
Start the development server to test:

	(env3) bash-4.4$ cd mysite/
	(env3) bash-4.4$ python manage.py runserver
	Performing system checks...
	...
	Starting development server at http://127.0.0.1:8000/

Create the polls app:

	(env3) bash-4.4$ pwd
	/home/ken/django/tutorial01/env3/mysite
	(env3) bash-4.4$ python manage.py startapp polls
	(env3) bash-4.4$
	
Edit the `polls/views.py`, `polls/urls.py`, and `mysite/urls.py`.  Navigate to the polls URL, as described in the tutoral.

Ending directory structure, which is somewhat unclear from the tutorial:

	(env3) bash-4.4$ pwd
	/home/ken/django/tutorial01
	(env3) bash-4.4$ find env3/mysite/ \( -type d -name __pycache__ -prune \) -o -print
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
	(env3) bash-4.4$ 
	
This concludes part 1.


	