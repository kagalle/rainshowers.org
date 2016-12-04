+++
Tags = [ "Git" ]
Description = ""
date = "2010-06-13"
title = "Git cheat-sheet"

+++

| | |
|-------|---------|
|`git reset --hard`|Reverts all changes to the working copy.|
|`git add -u`|Adds all changes done to the working copy to the to-be-committed list (files that were added, removed, updated).|
|`git add <path>`|Recursively adds the files within `<path>` to the to-be-committed list.|
|`git reset -- <path>`|Remove a `<path>` from the to-be-committed list, no change to working copy.|
|`git checkout -- <path>`|Undo changes to `<path>` in the working copy (svn revert `<path>`).|
|`git ls-tree -r <revision-id>`<br>`git cat-file -p <file-id>`|get file-id's for all the files in/at a specific revision - use this id for "cat-file"  <br>Use `<revision-id>^` to get the revision prior to the one specified - to get, for example, the id of a file deleted at `<revision-id>`.<br> Dumps the file contents to stdout (see previous git ls-tree entry - these two together make a `svn -r <rev> url://path/file`).  (Thanks to http://www.gelato.unsw.edu.au)|
|`git remote show origin`<br>`git remote -v`|Get the URL of the repository that you cloned from. (Thanks to a post on Google Groups "Git for human beings" group.)|
|`git config --global diff.tool meld`<br>`git difftool ...`|Use meld to see diff output.|
|`git ls-files -v`|List all files in the working copy and status of each (in one letter code).|

