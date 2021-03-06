---
layout: page
title: Build your own VCS
permalink: git/build-your-own-vcs
---

A good conceptual model is the key to using any tool effectively. In order to use a version control system, or even understand how it can be useful, you will need to develop a conceptual model. For programmers, coding something yourself is a very effective way to develop a conceptual model of how it works -- a model that you can feel. This fun activity will help you develop a conceptual model that will make learning a complex tool much simpler.

## Getting Started -- what does a VCS do?
> Version control is a system that records changes to a file or set of files over time so that you can recall specific versions later.

*From [the git book section 1.1](https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control).*

A Version Control System allows you to keep track of your code, view different versions of your code, switch between versions, maintain different versions of your code, and share your work with other programmers.

Before we start building one, we need to have some basic concepts:

* *Working directory*: this is the directory containing your code. You will be modifying files in this directory.
* *Repository*: this is a hidden subdirectory of your working directory that will contain all the files that your VCS needs to manage your code. We'll name this `.repo`.

In this activity, we will keep things simple by adding another directory, `.vcs` -- this is where we will keep the code of our vcs so that we can easily reference the scripts we create. Ordinarily your VCS is a software packaged installed on your operating system, so you just run it as you would any other linux command. But we don't have time to mess with the $PATH variable and such, so this is simpler.

If you crave a top down understanding, here's a basic outline:

A version control system will allow us to save snapshots of our code, creating a history that we can navigate back and forth through. We can tag snapshots so they are easier to find. We can also create parallel branches of code, so that we can try things and discard them later (or so that multiple people can work in parallel). Branching necessitates merging, and we will keep our project simple by stopping the train before we start trying to merge code. But having done all the other things will give you enough of an idea of how everything else works that you will be able to appreciate the complexity of the merge process. And the magic necessary to make it smooth.

We will start our version control system with the basics -- saving code. In order to do that, we'll have to detour through setting up a repository. From there we will figure out how to jump around in the history. Once we can jump around, tagging will be a simple extension. Then we will come to figuring out how to do branching... which is deceptively complex in its own right. :) And once you've finished branching, you'll be ready for Git.

## Project
Download the initial project files, and follow the instructions in the README. The project includes some test scripts that you can use to verify that your scripts do exactly what they are supposed to. A (mostly blank) file has already been created for each of the scripts you will need to write, and the test script will also make sure they are all executable.

[Initial Project Files](http://ryanheathcote.com/git/vcs-project.zip)

The main instruction you will need is: run the tests with `make test`. 

## Setting up a Repository
The first thing you would want to do with a VCS is save your code regularly. (Not just save your files, but save the entire set of your project's files). But we need a place for saving code, and a system for saving code. 

The `init` script is the beginning of any VCS project.

The goal is to type `vcs-init.sh <directory>`, and have your repository set up.

Update the `vcs/vcs-init.sh` script that will do the following:

* Require a single argument. Exit with an error if the argument is missing.
* If the target is not an existing file, create a directory with the name of the argument.
* If the target is not a directory, exist with an error.
* If the target contains a file named `.repo`, exit with an error.
* If the above checks pass, initialize the repository.
* create a directory called `.repo` inside the target directory. This is where the code will be saved, and where we will also keep other vcs files that help us manage the saved code.
* inside your `.repo` directory, create a directory called `refs`. This will come in handy later.
* inside your `.repo/refs` directory, create a directory called `tags`. This will come in handy later.
* inside your `.repo` directory, create a directory called `snapshots`. This will store the code.

## Saving code
The first thing you want to be able to do with a VCS is to save code. We're going to call these "snapshots", and we're going to save them to our `.repo` directory.

The goal is to be able to run `vcs-commit.sh` in your working directory and save a "snapshot" to our `.repo/shapshots` directory.

Update the `vcs/vcs-commit.sh` script to do the following: 

* make sure the script is being run from a directory that contains a repository. Error if this is not the case.
* create a subdirectory in `.repo/snapshots` named with a number, indicating which snapshot we are creating. For your first snapshot, the directory name should be `1`, the next `2`, and so on.
* copy all code files (recursively) from your working directory into your snapshot directory (including hidden files!). It should make sure not to copy the `.repo` or `.vcs` directories.
    * hint: the rsync command has a `--exclude` option, as well as other options that will make this task incredibly simple. ;)
* create a file named `.commit` in the snapshot directory that contains metadata about the snapshot:
    * include the username of the user who made the commit.
    * include the date the commit was made.
    * allow the user to pass an argument to the script. This will be the "commit message", which should also be included. e.g. `vcs-commit.sh "I don't know why but this works so I'm committing it before it breaks again"`.
    * hint: you can get the current user's username in linux. You can also get the current date.
   
##Finding code
It's somewhat useful to be able to save snapshots easily, because I can explore the snapshots directory if I want to find an old version of a file after I've broken something. But it's a little tedious to try to find which snapshot has what I'm looking for. So let's create a script that will let us scroll through all the commit messages.

Start by creating a "history viewer". We'll call it `vcs-log.sh`

This script is really simple:
* for each snapshot, output the snapshot id followed by the contents of the snapshot's `.commit` file.

Here's some sample output (from commits made by the test script, hence they're all the same time...)

```
snapshot: 1
user: ryan
time: Sat Oct 14 15:18:22 EDT 2017
message: 

snapshot: 2
user: ryan
time: Sat Oct 14 15:18:22 EDT 2017
message: 

snapshot: 3
user: ryan
time: Sat Oct 14 15:18:22 EDT 2017
message: 

snapshot: 4
user: ryan
time: Sat Oct 14 15:18:22 EDT 2017
message: this is a test message!
```

## Tagging

We sometimes want to "bookmark" certain commits. This is really simple -- we create a script that creates file in the `.repo/refs/tags` folder that references our current checked out snapshot.

Objective: I can create an alias for snapshot 4 by running `.vcs/tag.sh 4 test`, it will create a file in the refs directory named `test` that links to `snapshots/4`. 

Write a script called `.vcs/tag.sh`:
* take a command line parameter giving the name of the tag.
* create a symbolic link in `refs/tags` directory that named for the first parameter and linking to the snapshot whos id is given in the second parameter.

Update `vcs-log.sh` to list tags as well as snapshots in the output. (Note this output will be somewhat redundant as a snapshot that is tagged will be listed twice, but it would be quite complicated to make the tags list next to their respective snapshots).

##Bonus Tasks

* Show the tags of a snapshot before the output of that snapshot's `.commit` file.
* Implement a vcs ignore system -- if your working directory contains a `.vcsignore` file, the commit script will not include files referenced by the `.vcsignore` file in the snapshot.
    * Ok, let me make that clearer. If I have a `.vcsignore` file that contains two lines, one with `build` and another with `.blob`, then, when I create my snapshot, if there is a directory named `build`, I won't copy that directory into the snapshot. Likewise, I will ignore a file named `.blob`.`
* Change the directory name of a snapshot to be a sha1 hash of the commit directory and change the system to use the hashes to reference snapshots.

## Further discussion
This activity is much more limited in scope than I'd hoped it to be (much to the relief of all students assigned the task). To get a sense for where this would go, read the article that inspired the activity: ["The Git Parable" by Tom Preston-Werner](http://tom.preston-werner.com/2009/05/19/the-git-parable.html). 

We haven't implemented some of the more complex features that would make this tool powerful, but we don't need to. There is already a professional tool that we can learn that has all the complex features. However, you could use this system to back up your projects. Explore the `.testing_temp` directory after you run a test to see how the system looks on your hard drive. Also feel free to play around with it on other projects. Although once you've learned git, you won't want to.
