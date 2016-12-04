+++
Tags = [ "Mercurial", "Git" ]
date = "2010-10-23"
title = "Convert a mercurial repository to a git repository"
Description = ""

+++

I have decided to have another look at git, since it stores the contents of files as content and not files.  If I rename or move a file, the content doesn't have to be stored a second time.  My hope is that I will worry less about having things right the first time, and can focus on just getting stuff done, making adjustments later as needed without a heavy price to pay.<!--more-->

Based on https://git.wiki.kernel.org/index.php/GitFaq#Can_I_import_from_Mercurial.3F

- Downloaded and extracted a snapshot from `repo.or.cz/w/fast-export.git` into `~/git/fast-export/`.
- Create a folder for the git archive: `~/project_git/` and cd into it.
- Initialize a git repository in that folder: `git init`.
- Run the utility: 

    `~/git/fast-export/ hg-fast-export.sh -r ~/mercurial_working_copy.`

- The repository is created, but the working copy has no files.  From git's point of view it is as if the files were there and we had deleted all of them.  So tell git to abandon all the changes in the working copy, which creates the files in the working copy: `git reset --hard`
