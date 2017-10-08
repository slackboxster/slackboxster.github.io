# Build your own VCS

A good conceptual model is the key to using any tool effectively. In order to use a version control system, or even understand how it can be useful, you will need to develop a conceptual model. For programmers, coding something yourself is a very effective way to develop a conceptual model of how it works -- a model that you can feel. This fun activity will help you develop a conceptual model that will make learning a complex tool much simpler.

## Getting Started -- what does a VCS do?
> Version control is a system that records changes to a file or set of files over time so that you can recall specific versions later.

*From [the git book section 1.1](https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control).*

A Version Control System allows you to keep track of your code, view different versions of your code, switch between versions, maintain different versions of your code, and share your work with other programmers.

Before we start building one, we need to have some basic concepts:

* *Working directory*: this is the directory containing your code. You will be modifying files in this directory.
* *Repository*: this is a hidden subdirectory of your working directory that will contain all the files that your VCS needs to manage your code. We'll name this `.repo`.

TODO: I think we need to go with the path approach rather than keeping the code in the working directory ... we need the ability to blow away the working directory. For now build it with the hidden folder idea, and we'll adjust after we've got the thing built.
TODO: show examples of log output.

In this activity, we will keep things simple by adding another directory, `.vcs` -- this is where we will keep the code of our vcs so that we can easily reference the scripts we create. Ordinarily your VCS is a software packaged installed on your operating system, so you just run it as you would any other linux command. But we don't have time to mess with the $PATH variable and such, so this is simpler.

If you crave a top down understanding, here's a basic outline:

A version control system will allow us to save snapshots of our code, creating a history that we can navigate back and forth through. We can tag snapshots so they are easier to find. We can also create parallel branches of code, so that we can try things and discard them later (or so that multiple people can work in parallel). Branching necessitates merging, and we will keep our project simple by stopping the train before we start trying to merge code. But having done all the other things will give you enough of an idea of how everything else works that you will be able to appreciate the complexity of the merge process. And the magic necessary to make it smooth.

We will start our version control system with the basics -- saving code. In order to do that, we'll have to detour through setting up a repository. From there we will figure out how to jump around in the history. Once we can jump around, tagging will be a simple extension. Then we will come to figuring out how to do branching... which is deceptively complex in its own right. :) And once you've finished branching, you'll be ready for Git.

## How do I know if I'm doing well?
I'll include some test scripts so that you can figure out how well your repository is doing. 

## Setting up a Repository
The first thing you would want to do with a VCS is save your code regularly. (Not just save your files, but save the entire set of your project's files). But we need a place for saving code, and a system for saving code. 

The `init` script is the beginning of any VCS project.

you should be able to type `.vcs/init.sh`, and have your repository set up.

Write an `init.sh` script that will do the following:

* Init requires a target. The first argument should be the name of a directory to initialize. If that directory doesn't exist, create it. If it does exist, first check for an existing VCS repo, and exit if one exists.
    * E.g. If I run `.vcs/init.sh spam`, it will create a new directory named spam
* create a directory called `.repo` inside the target directory. This is where the code will be saved, and where we will also keep other vcs files that help us manage the saved code.
    * Create the following directory structure 
* inside your `.repo` directory, create a directory called `refs`. This will come in handy later.
* inside your `.repo` directory, create a directory called `snapshots`. This will store the code.

<create a copy of the code after every step>

## Saving code
The first thing you want to be able to do with a VCS is to save code. We're going to call these "Snapshots", and we're going to save them to our `.repo` directory.

The objective is to be able to run this command in our working directory:
`.vcs/commit.sh` and have the VCS save a "snapshot" to our `.repo` directory.

The commit.sh script needs to:

* create a subdirectory in `.repo/snapshots` with a number, indicating which snapshot we are creating. For your first snapshot, the directory name should be `1`, the next `2`, and so on.
* copy all code files from your working directory into your snapshot directory (including hidden files!). It should make sure not to copy the `.repo` or `.vcs` directories.
* create a file named `.commit` in the snapshot directory that contains metadata about the snapshot -- who committed it, when was it committed, and an optional message that the user can specify as a command line argument to the script.
    * hint: you can get the current user's username in linux. You can also get the current date.
* Bonus points if you implement a vcs ignore system -- if your working directory contains a `.vcsignore` file, the vcs will not include files referenced by the `.vcsignore` file in the snapshot.
    * Ok, let me make that clearer. If I have a `.vcsignore` file that contains two lines, one with `build` and another with `.blob`, then, when I create my snapshot, if there is a directory named `build`, I won't copy that directory into the snapshot. Likewise, I will ignore a file named `.blob`.
    
##Finding code
It's somewhat useful to be able to save snapshots easily, because I can explore the snapshots directory if I want to find an old version of a file after I've broken something. But why don't we make this even easier.

The objective is to be able to run this command in our working directory:
`.vcs/checkout.sh 4` and have the VCS set up our working directory to look exactly like snapshot number 4. The `4` in the command is an argument specifying the number of the snapshot to check out.

In order to be able to check code out and so forth, we will need to have some idea of what snapshot we are currently using. When we check out a snapshot, we will need to update a file that keeps track of our snapshot. This is where our `refs` subdirectory comes in handy. Inside there create a file called `HEAD` that contains the number of the currently checked out snapshot.

Update your `commit.sh` script to set the `.repo/refs/HEAD` file to the new snapshot number.

Write a script called `.vcs/checkout.sh`:
* remove all the files in the working directory that aren't ignored
* copy all the files from the snapshot into the working directory.
* modify `HEAD` to contain the number of the snapshot checked out.
* Print an error message if a snapshot doesn't exist

Write another script called `./log.sh`: that shows a list of all the snapshots in your snapshot directory and their commit messages, time of commit and author. This will make it easier for you to choose which commit to checkout.

## Tagging
//TODO: tags need to be in a subdirectory, as do branches... otherwise things get screwy.

We sometimes want to "bookmark" certain commits. This is really simple -- we create a script that creates another file in the `.repo/refs` folder that references our current checked out snapshot.

Objective: If I have checked out snapshot 4, and I run `.vcs/tag.sh test`, it will create a file in the refs directory named `test` that contains `4`. 

Write a script called `.vcs/tag.sh`:
* take a command line parameter giving the name of the tag.
* create a file in the refs directory with the name of the tag and its contents being the current snapshot.

Now extend your checkout script to enable checking out any ref. The objective is to be able to write `.vcs/checkout test` and have it checkout snapshot 4.

Bonus for tagging commits by ref or number, rather than having to checkout a snapshot before tagging it. E.g. `./vcs/tag.sh test 4` will tag snapshot 4 with the tag `test`.

## Branching 
We've got most of the building blocks of branching. Now for the final piece. A branch is simply another ref that points to a specific snapshot. But what makes branches special is a piece we don't have yet: A branch is a moving ref. Whenever you work, you work on a branch. When you commit a new snapshot, your current branch ref is updated to point to your latest commit. We also keep track of the parent commit of each commit, so that we can trace back the history along multiple branches. This comes in very handy when merging code.

Create a script called `.vcs/branch.sh`:

* this script will create a new branch, taking the name of the branch as its first argument. E.g. `.vcs/branch.sh hello` will create a branch named hello pointing to the current commit.
* this will create a new `ref` named `hello` that contains the value of the current commit.
* it will also modify `HEAD` to contain `hello`
    * In order for branching to work, you need to always have a `current branch`. Not having a current branch is called a "detached head state". We will discuss this more when we get into git itself.
    
Update your init script:
* default the value of `HEAD` to `master`. 
* create a ref named `master` that points to the non-existent snapshot 0.

Update your commit script to do the following:
* update your `.commit` file to contain a line `parent NUMBER` where <number> is the number of the parent commit.
    * E.g. If I create snapshot 10 after checking out snapshot 4 and modifying it slightly, `snapshots/10/.commit` should contain a line `parent 4` indicating that snapshot 10 was based off snapshot 4.
* update the current branch's ref to point to the new snapshot.
* Check that the current `HEAD` is not pointing to a specific snapshot by number (or a tag) -- a detached HEAD state. If it is, indicate that the user needs to create a branch before commiting, and stop your commit.

Update your `log` script to print out the tags and branches currently pointing to a snapshot, in addition to all the other information.
