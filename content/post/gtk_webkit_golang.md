+++
date = "2016-12-18T22:33:31-05:00"
title = "Installing GTK+ and webkit development environment for Go (golang)"
Description = ""
Tags = [
]

+++

Process to get a working Go development environment for GTK+ and Webkit on Debian.<!--more-->

Install needed debian packages:
```bash
apt-get install golang git libwebkit2gtk-4.0-dev libjavascriptcoregtk-3.0-dev
```

Create a workspace for go development:
```text
mkdir ~/go
export GOPATH=~/go
```
Note: putting the GOPATH export in `.bashrc` should work, but experience has shown it doesn't.  Verifying it is set (by .bashrc) and running a build results in errors about '$GOPATH not set.'  Running it manually solves this.

Clone source code for gotk3 and webkit:

`github.com/gotk3/gotk3.git` and move the resulting `gotk3` folder into 
`~/go/src/github.com/gotk3/gotk3`
  
`github.com/sourcegraph/go-webkit2.git`  into
`~/go/src/github.com/sourcegraph/go-webkit2`
    
`github.com/sqs/gojs.git` into
`~/go/src/github.com/sqs/gojs`
  
And, clone examples for gotk3

`github.com/gotk3/gotk3-examples`  into
`~/go/src/github.com/gotk3/gotk3-examples`
  
Build and install each of these into this local directory structure:
```text
cd ~/go/src/github.com/sqs
go install ./gojs
```

This creates `~/go/pkg/linux-amd64/github.com/sqs/gojs.a`.
Do likewise for gotk3 and go-webkit2.

The Go units tests can be run using (using webkit2 as an example):
```text
cd ~/go/src/github.com/sourcegraph/go-webkit2
go test ./webkit2
```

The code should build and you'll get some indication that the test `PASSED`.

With this, the gotk3 examples can be built and run to test.
I have webkit2 examples yet to do.

Go GTK applications are built just as any Go application.  The Go package for the main `.go` file needs to be `main`, and the main function needs to be `main()`.

Note that there can be many different branches, or even separate projects for the github projects.  For example gotk3, `conformal` and `gotk3` are completely different projects, even though they are both bindings for GTK in Go.
