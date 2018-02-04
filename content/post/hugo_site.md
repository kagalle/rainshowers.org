+++
Tags = [
]
Description = ""
date = "2016-12-18T20:49:30-05:00"
title = "Site now powered by hugo"

+++

[hugo](https://gohugo.io/) is a static website engine.  This site was previously done using b2evolution, but with the expection of supporting user comments, did not need any of the dynamic overhead.  I moved to hugo to eliminate having to moderate comments, manage updates and ward off hacking attempts.<!--more-->

Creating the site was a matter of installing hugo locally
```bash
apt-get install hugo python-pygments
```
 and running `hugo new site .` in a new folder.
Then I cloned the [vienna](https://github.com/keichi/vienna) theme from github into the `themes` directory.  I also forked the theme in my github account so I can save the modifications I have made.  I fixed a problem with the Google+ link, changed a few styles and changed the main image.
I also have the entire site directory checked into github, so the `themes` folder is a nested repository.
I add new content with `hugo new post/post_filename.md`, where I choose an appropritate name.  This creates a new file which I edit using the `remarkable` markdown editor, editing the fields at the top and adding content at the bottom.

Content is built using a small `compile.sh` script:
```bash
#!/bin/bash
hugo --cleanDestinationDir
```
The site is tested using the Hugo built in local server, started with the `serve.sh` script:
```bash
#!/bin/bash
hugo server -w -D
```
Note that the server watches for file changes, and recompiles and redeploys files as you change them.  However, you still need to compile them (`compile.sh`) before deploying them to the live server (`push.sh`).

The built site is pushed to my host using another script, `push.sh`:
```bash
#!/bin/bash
rsync -e "/usr/bin/ssh" --bwlimit=2000 -av ./public/ user@myhost.com:/home/.../rainshowers.org/
```
where `user@myhost.com` is my web host account.

The directory tree looks like this:
```text
├── compile.sh
├── push.sh
├── serve.sh
├── config.toml
├── content
│   └── post
│       ├── hugo_site.md
│       └── ...
└── themes
    ├── main.css
    └── vienna
        ├── static
            ├── css
            │   └── main.css
            ├── images
                └── bg.jpg  # background image

```