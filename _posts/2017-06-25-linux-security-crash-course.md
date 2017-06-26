---
layout: post
title: Incomplete Linux Security Crash Course
---

# Securing Linux

Welcome to my Linux security crash course designed for Liberty University's GenCyber Summer Camp. It explains how to get a linux system secure enough to survive a day of red-team attacks.


## Figuring out new things

No human could possibly tell you all there is to know about linux. I don't even remember half of what I learn about it, and I only know probably 5% of what there is to know about it.
* *Man Pages*: `man command` will give you a very technical user's manual for a given command. This manual will be fairly technical, and if you haven't used linux very long, will make very little sense. But you will be able to catch bits and pieces, and the more you read them, the more useful they become. Searching using the `/` key is very helpful with man pages. And remember to quit with `q`.
* *Google*: Google is your best friend. I regularly use google to remember how to do things, or to learn new things. 
* *Resources*: The Resources section at the end of this lesson includes a number of links to useful resources.

## Suggestions for the camp

* Make the most of this experience. You have a bunch of really smart mentors and teachers who want to help you learn and grow, personally and technically.
* Take notes: there is a lot to learn, and each person can only learn so much. Take notes and help your team members learn.
* Practice: working with computers is like riding a bicycle. You can't learn a lot from lectures. You have to *do* it.
* Work as a team. The smartest person on your team at best knows 10% of what the dumbest red-teamer knows. The only way to overcome the skill deficit is to work together.
* Don't Panic: yelling, at each other or at the computer, is not going to help you stop a hacker. Calm, clear thinking is the only way you'll get somewhere.
* If you feel lost in the technical side of things, you can still be a big help to your team:
    * look at the checklist and choose one or two things to learn to do really well. Work with a mentor to make sure you've got them down.
        * learn to run scans to check that a vulnerability has been eliminated.
        * learn to change passwords really well.
        * learn to do software updates.
    * help your team keep organized:
        * there are a lot of servers and not a lot of time, so things need to be organized.
        * Look at the checklists, and coordinate who is going to take care of which task on each server, and make sure they all get secured.
    * Be the peacemaker: teamwork requires relationships, and human relationships are challenging -- often feelings get hurt, people don't get along, or people just don't understand each other. Helping your team resolve these relational tensions can go a long way to making your team more effective. 
    * Help your team manage an incident response. You can maintain communication and keep track of the process, and your more technical team members can focus on the technical tasks.

# How to secure a Computer

## Threat Model

When securing a system, you need to identify two things: the value of the thing you are securing, and the threats against which you are securing it. 

Security is an economics game.
 
* Economics is the study of scarce resources that have alternative uses. In other words, economics involves figuring out systems that enable making the best use of limited resources. 
* Your resources are time and knowledge, both of which are limited, and both can be used for many things. We need to focus our resources on keeping the Red Team out for one whole day. No more, no less.
* As a result, I will focus your time on securing your servers as quickly as possible. We will get these machines secured, not locked down. If you want to learn professional-grade security, this lesson offers a very basic starting point from which you can grow your skills.
* A security professional running a web server would do a whole lot more technical stuff to secure a server. He also has a lot more time and a lot more knowledge -- in other words, he has more resources. We can't try to match his level of security. 
* One of my assumptions is that once Red Team gains even minimal access to your server, they will hose it. Hence it is the highest value use of our time is in keeping them out. There is less value in preventing them from doing damage once they get in, because there are so many ways for them to break the server that we wouldn't cover them all. Instead, lets keep them OUT.

## Systematic process:

Any time you attempt to achieve something, you want to have a structured process that can get you to your objective. For us, we want to start at the base level of our system, and work outwards. We establish a secure zone, and then we expand the borders of that secure zone. Below is the outline of that process:
1. Integrity of the operating system.
2. OS User accounts.
3. OS Software updates.
4. OS Services
    * Minimization
    * Configuration
    * User accounts
5. Application Software
    * Updates
    * Configuration
    * User accounts
6. Detection

# How to secure Linux

## 1. Integrity of the Operating System

Before you try to secure an operating system you will need to remove any malware that could track or thwart your ability to do anything on your server. Finding and removing malware is an entire industry on its own. However, in our case, it appears that only two of the linux servers have a back door (according to the OpenVAS scan).

In order to find and remove these backdoors from the inside:
1. Figure out which process is listening on the backdoor port: 
    * `netstat -antp | grep 1337`
    * *sample output*
2. Figure out which files are running the process
    * `lsof -p <the pid>`
    * *sample output*
3. Kill the process:
    * `pkill -9 <the pid>`
4. Remove the files
    * `rm -rf <the file>`
5. Verify that it's gone:
    * no more listening `netstat -antp | grep 1337`
    * files are gone `ls <the file location>`
    * the process is dead `ps x | grep <filename>`

Once we've cleaned up the operating system, we can move on to the server itself.

## 2. OS User Accounts

This will be the MOST IMPORTANT thing you do to secure your servers. Make sure you do it well. Most of the teams in last year's camp got hacked very quickly by red team because they hadn't changed all of their operating system user account passwords. With Red Team's skill, it only takes one poorly secured user account for them to get in and hose the server.


### Analyze the situation

* Figure out what users are on each server by looking at the file `/etc/passwd`
	* This file contains a number of system accounts that should be on there. 
	* You can determine which are system users and which are normal users by looking at the uid (the first number after the username in `/etc/passwd` -- if that is less than 1000, it is a system account.
	* (where did I get that number? the `/etc/login.defs` file -- look for `UID_MIN 1000`).
    * the `toor` account is very easily overlooked. It is an alias to the superuser account `root`, so it is incredibly important to make sure it is secured.
    * we must assume that all existing user accounts are insecure.

### Delete the toor user

The toor user is unnecessary and poses significant security risks. `deluser toor` will remove him. :)

### Change passwords


```
How I generate passwords:

Go to the wikipedia random page repeatedly.
https://en.wikipedia.org/wiki/Special:Random

Select page titles with unusual words.
Concatenate two together.

```



This is the most important step. If you forget to change a password, it is likely that Red Team will be logged into that account within 5 minutes. Maybe an hour because of how many servers they are attacking. In other words, one unchanged password and you will not stand a chance.

Use the printouts to set the passwords for your system. Ordinarily we would not use the same password twice ever. However, we will strategically reuse passwords to save time and simplify things. But we won't use all the same passwords so that Red Team doesn't get a whole lot of benefit from discovering one password.

Your root user password should not be reused anywhere. Reuse the same password for all your normal user accounts. And then use a different password for anything else on the server.

* first, change the root password:
    * `passwd`
    * follow the prompts to give a new, secure password.
    * verify by trying to log in with the new password.
* change the passwords of all non-system users that have passwords:
    * `passwd <username>`
    * follow the prompts to give a new, secure password to the user.
    * verify by trying to log in as that user with the new password.

### Make sure nobody is in the sudo group
If you do the password change, this is a less significant vulnerability, but it could still have an impact if an attacker gets into a different service on the machine. 

* Use `members sudo` to find which users are in the `sudo` group
	* you may need to install the members commmand:
`sudo apt-get install members`
	* If you see a user in the resulting list who shouldn't be there, remove them from the group:
        * `deluser user group` (make sure not to `deluser user`)

## 3. OS Software updates.

Once you have secured your user accounts, the next thing that Red Team will want to attack is vulnerabilities that give access without having a valid user account. They will use a database of known vulnerabilities, so the best way to secure against this is to update your software. The moment a red-teamer detects out of date software, they are only two clicks away from hosing your server.

Updating software in Debian is usually really simple:
 
* Run this command:`sudo apt-get update; sudo apt-get upgrade`
* Then just wait for the packages to update. 

## Further content will come tomorrow!