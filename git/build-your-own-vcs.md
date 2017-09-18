# Build your own VCS

In order to use git effectively, it helps to understand what git is doing. This fun activity will enable you to interact with git more confidently. 

## Getting Started -- what does a VCS do?
A Version Control System allows you to keep track of your code, view different versions of your code, and even collaborate with others.
<Insert official definition here>

Before we start building one, we need to have some basic concepts:

* Working directory: this is the directory containing your code. You will be modifying files in this directory.
* Repository: this is a hidden subdirectory of your working directory that will contain all the files that your VCS needs to manage your code. We'll name this `.repo`.

In this activity, we will keep things simple by adding another directory, `.vcs` -- this is where we will keep the code of our vcs so that we can easily reference the scripts we create.

## Saving code
The first thing you want to be able to do with a VCS is to save code. We're going to call these "Snapshots", and we're going to save them to our `.repo` directory.

The objective is to be able to run this command in our working directory:
`.vcs/commit.sh` and have the VCS save a "snapshot" to our `.repo` directory.

The commit.sh script needs to:

* create a subdirectory named `snapshots` under `.repo`
* create a subdirectory in snapshots with a number, indicating which snapshot we are creating. For your first snapshot, the directory name should be `1`, the next `2`, and so on.
* copy all code files from your working directory into your snapshot directory (including hidden files!). It should make sure not to copy the `.repo` or `.vcs` directories.
* create a file named `.commit` in the snapshot directory that contains metadata about the snapshot -- who committed it, when was it committed, and an optional message that the user can specify as a command line argument to the script.
    * hint: you can get the current user's username in linux. You can also get the current date. and you can specify strings as command line arguments.
* Bonus points if you implement a vcs ignore system -- if your working directory contains a `.vcsignore` file, the vcs will not include files referenced by the `.vcsignore` file in the snapshot.
    * Ok, let me make that clearer. If I have a `.vcsignore` file that contains two lines, one with `build` and another with `.blob`, then, when I create my snapshot, if there is a directory named `build`, I won't copy that directory into the snapshot. Likewise, I will ignore a file named `.blob`.
    
##Finding code
It's somewhat useful to be able to save snapshots easily, because I can explore the snapshots directory if I want to find an old version of a file after I've broken something. But why don't we make this even easier.

The objective is to be able to run this command in our working directory:
`.vcs/checkout.sh 4` and have the VCS set up our working directory to look exactly like snapshot number 4. The `4` in the command is an argument specifying the number of the snapshot to check out.

In order to be able to check code out and so forth, we will need to have some idea of what snapshot we are currently using. When we check out a snapshot, we will need to update a file that keeps track of our snapshot. However, we'll need to keep track of multiple snapshots at some point in the future, so for this, create a directory in your `.repo` directory called `refs` and inside there create a file called `HEAD` that contains the number of the currently checked out snapshot.

Update your `commit.sh` script to update the `.repo/refs/HEAD` file with the new snapshot number.

Write a script called `.vcs/checkout.sh`:
* remove all the files in the working directory that aren't ignored
* copy all the files from the snapshot into the working directory.
* modify `HEAD` to contain the number of the snapshot checked out.
* Print an error message if a snapshot doesn't exist

Write another script called `./log.sh` that shows a list of all the snapshots in your snapshot directory and their commit messages, time of commit and author. This will make it easier for you to choose which commit to checkout.

## Tagging
We sometimes want to "bookmark" certain commits. This is really simple -- we create a script that creates another file in the `.repo/refs` folder that references our current checked out snapshot.

Objective: If I have checked out snapshot 4, and I run `.vcs/tag.sh test`, it will create a file in the refs directory named `test` that contains `4`. 

Write a script called `.vcs/tag.sh`:
* take a command line parameter giving the name of the tag.
* create a file in the refs directory with the name of the tag and its contents being the current snapshot.

Now extend your checkout script to enable checking out any ref. The objective is to be able to write `.vcs/checkout test` and have it checkout snapshot 4.

## Branching 
We've got most of the building blocks of branching. Now for the final piece. A branch is simply another ref that points to a specific snapshot. But what makes branches special is a piece we don't have yet:

When you create your commit, add the previous snapshot number to your `.commit` file on a line prefixed with `parent`. E.g. If I create snapshot 10 after checking out snapshot 4 and modifying it slightly, `snapshots/10/.commit` should contain a line `parent 4` indicating that snapshot 10 was based off snapshot 4.

In order for branching to work, you need to always have a `current branch`. Update your refs/HEAD to reference a name instead of a snapshot id. Update your vcs to default this to `master`. And also update your vcs to create a ref `master` that points to a commit.

Which reminds me... we'll need an init script.
The init script should create the initial setup for a repo. create the subdirectories, create the master ref, and set up head.

`HEAD` should always refer to the current branch in use. If you check out a specific snapshot, you should indicate that a branch must be created before the user can make further commits.
`master` will be the default branch that your VCS checks out when you initialize.

Create a script for creating a branch that will create a new ref that points to the current snapshot, and updates the HEAD ref to point to the new branch.

When you create a commit, you update the value of the current branch's ref to point to the latest snapshot.

Also update your `log` script to print out the tags and branches currently applied to a ref, in addition to all the other information.
