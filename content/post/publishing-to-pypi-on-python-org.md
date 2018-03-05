+++
Description = ""
Tags = [
]
date = "2016-08-28T00:11:45-05:00"
title = "Publishing to PyPI on python.org"

+++
##### Editor note: This was a post that I never quite finished, but it has some useful information, so I'm passing it along. --3/4/2018

In searching for tutorials and videos about how to organize a Python project and publish it to PyPI, I was greeted with introductions and titles like these:

- "So simple!"
- "That's all! ...it is very easy."
- "...5 easy steps"
- "...4 easy steps"
- "really, it's very very easy, but it could be a little more obvious"

This goes to the adage that "It's easy if you know how to do it."

There are a lot of moving pieces to getting a Python project arranged and assembled together so that it can be uploaded to pypi.python.org.

- Packages that are to be included 
- The project needs to build and run in a way that is compatible with the setuptools/setup.py infrastructure.  Specifically, the project will contain a package to be distributed, but will also have a script to run the project.  Both will depend on and need to import the package.
- The documentation needs to work and look right from PyPI and potentially github.com.
- The meta-data that goes with the project needs to facilitate having `pip install` create an executable script that runs the project once installed.
- To be able to build and test, especially since it needs to be done repeatedly, a Python virtual environment needs to created, used, and recreated as needed.
- Usable platforms and Python versions need to be determined.
- The testpypi.python.org site should be used before publishing to pypi.python.org.
- Versioning needs to be decided on and know how it effects the publishing process.  Specially, it is important to use the test pypi site to verify that project is ready to go, since once published to pypi, you will have committed to the specified version number.

Here are some notes on what I ended up with when publishing the first revision of *darfortie* [github](https://github.com/kagalle/darfortie) [PyPI](https://pypi.python.org/pypi?:action=display&amp;name=darfortie&amp;version=1.0")

*directory and file structure*
```text
   darfortie_project
       README.rst
       setup.py
           packages=["darfortie"],
           entry_points={'console_scripts': ['darfortie = darfortie.darfortie_main:main']},
      darfortie
    
          __init__.py
              from darfortie import darfortie_main
              from darfortie import darfortie_*
        
          darfortie_main.py
              from darfortie import darfortie_*
              def main():
               ...
        
          darfortie_*.py
```

1. A top-level folder to hold everything.  The name isn't significant.
2. The README.rst is a reStructured formatted text file.  This is all that PyPI supports, so use this format.  Github supports this and other formats such as \*.md (MarkDown).  If you have a MarkDown file already you can use [pandoc](http://pandoc.org/try/) to convert the file.
3. The setup.py is what controls the publishing of the project to PyPI.  Follow the "github" link above to see the full contents of the file, but to significant lines are...

  - The packages line indicates that you want to publish a specified package.  If the directory containing the package is like-named and located directly under, that is all that is needed.  See [setup.py docs](https://docs.python.org/2/distutils/setupscript.html#listing-whole-packages)
  - The entry_points line indicates that a script should be created when the project is installed that the end-user can run.  `darfortie =` specifies the name the script should have, what remains on the line specifies the main function to run, `package.python_file:function_name`.
  - The `darfortie` directory is the package directory for the darfortie package that was specified in the `packages` line of setup.py.
  - The __init__.py file indicates that this is in fact a package and normally includes imports from all of the files in the package so that items within the package can be accessed directly by using `package_name.item`.  The latter is not important in this particular case, because the package isn't being imported by an external application (but there is no reason it couldn't be).
