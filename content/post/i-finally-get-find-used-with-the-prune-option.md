+++
Description = ""
Tags = [ ]
date = "2010-06-19"
title = 'I finally "get" find used with the prune option'

+++

After years of muddling through with find and the "-prune" option, the light finally went on and I get it. Although perhaps inperfect, here's how it is in my mind...<!--more-->

Find is going to search every single directory, file, etc on the given path (or the current path, if none is specified). For each thing found it is going to try to get it to "fit" through the logic (or "hole") you provide. The first hole where it fits, that's where it goes.

```nohighlight
        /--------- hole 1 ----------\
find . ( -type d -name media -prune ) -o

       /----------- hole 2 ----------\
       ( -type d -name images -prune ) -o 
       
       /-hole 3 -\    /- hole 4 -\
       ( -type d ) -o -print 
```

1. `.` Search everything at and under this directory.
2. `( -type d -name media -prune )` Look for directory items named "media". If found "take" it. Also, since it is a directory and we said, `-prune`, don't recurse into this directory.
3. ` -o` This is what makes for the "try each hole in turn" behavior, since if the current item matches the first hole, then the expression is like, " (true or anything or anything ...) " which is true. None of the "anything" groups of logic are evaluated against the item/file - it is consumed by the hole that resulted in a "true" value.
4. `( -type d )` I don't want the directory entries to be printed - I only want the files (with their path). This hole consumes any directories, but because there is no "-prune" option, recursion still happens into that directory.
5. ` -print` End of the line - if nothing else matches (evaluates to true), then we do this one - that is print the file out. Only the files that didn't match any of the earlier logic make it to this point.

All the elements within the ` ( ) ` groupings are "and"ed together. So for example, "the item needs to be a directory AND its name needs to be media AND if it is a directory then don't recurse into it".

Way cool.