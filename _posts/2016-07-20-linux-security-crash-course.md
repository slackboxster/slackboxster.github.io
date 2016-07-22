---
layout: post
title: Incomplete Linux Security Crash Course
---

*These are the notes for my Linux Security lessons at [Liberty University's GenCyber summer camp](http://www.liberty.edu/news/index.cfm?PID=18495&MID=199858).*

## Introductory Videos
Here are some videos to help introduce concepts that may be foreign to you:

* [What is a Computer](https://www.youtube.com/watch?v=AkFi90lZmXA)?
* [What is an Operating System](https://www.youtube.com/watch?v=pVzRTmdd9j0)?
* [What is Open Source Software](https://www.youtube.com/watch?v=a8fHgx9mE5U)?
* [What is Linux](https://www.youtube.com/watch?v=zA3vmx0GaO8)?
	* in case you were interested, check out [the linux source code](https://github.com/torvalds/linux)

## How to use the Linux Command Line
Learn the basics from the [learning the shell tutorial](http://linuxcommand.org/lc3_learning_the_shell.php).

For the more advanced users, scripting unleashes the true power of linux and its command line. You can learn more about that from [a different tutorial on the site](http://linuxcommand.org/lc3_writing_shell_scripts.php).


For the adventurous: I love using vim. If you are bored and want a really cool challenge, learn vim. Vi is not quite as well-rounded as vim, so I would recommend installing vim to really get a powerful editor. Try [this vim tutorial to get started](http://www.openvim.com/).

## Figuring out new things
I couldn't possibly tell you all there is to know about linux. I often have to google things just to remember how to do things, or to do things I've never done before. So use google when you can't figure out something.
Also use man pages -- if you want to get a technical manual for a command, `man command`. This manual will be fairly technical, and if you haven't used linux very long, will make very little sense. But you will be able to catch bits and pieces, and the more you read them, the more useful they become. Searching using the `/` key is very helpful with man pages. And remember to quit with `q`.

## Suggestions for the event

* If you don't know much about computers, you can help your team by maintaining checklists and helping your team members communicate with one another. Try to make a role for yourself with what you know. You may be surprised at how much just asking questions can help your team members. Even if you won't ever do this again, make the most of your experience.

## Disaster response
Come up with a set of simple steps for your team to follow when you find out you've been hacked. Something like this:

* DO NOT PANIC!
* DO NOT YELL AT EACH OTHER!
* No amount of yelling, screaming, or punching tables will help you stop the attack. You need to do as much as you can to stop the attack. You may not be able to stop it -- it may take years of experience as a security professional to be able to stop some things. But do your best and see what you can figure out.
* **Detect**: you need to be able to detect when intruders get in. This will require following logs on your servers and your firewalls. You won't have a lot of traffic, which will help a ton. But keep your eye out for unusual logins and other activity. (Don't forget that scorebot is not an intruder).
	* Use your nagios system AND the scorebot to monitor your servers.
	* log files like `/var/log/auth.log` are important to watch.
* **Investigate**: What did the attackers compromise? A single service, or did they actually log in? What rights do they have? Google will be your friend.
* **Lock Down**: If just a single service, consider shutting that service down and reconfiguring it. If it is a user account, log that user out and lock the account down. Each situation will have different solutions.

It may help to run a disaster response drill a couple of times. Have one of your team members log in. Try to detect it, and when they do, respond as you would to an attacker. You may need to create a temporary user account for this drill.

Final Note: You are almost guaranteed to get hacked. You have more servers than people, and the red team has so much skill, that you are almost guaranteed to get hacked. You won't win by not being hacked. You will win by not being hacked as bad as the other teams, and by responding quickly to hacks that do happen. Do your best.

# How to secure Linux:

## User Management

Follow the principle of least privilege by making sure all users on the system have only the rights they absolutely need.

See [this ubuntu article](https://help.ubuntu.com/14.04/serverguide/user-management.html) for more info on managing users in ubuntu.
[This centos article](https://www.centos.org/docs/5/html/Deployment_Guide-en-US/s1-users-tools.html) explains some of how to do this stuff in centos, however, it is much more complicated than ubuntu.

### Remove unnecessary users

* Find users in the file `/etc/passwd`
	* This file contains a number of system accounts that should be on there. 
	* You can determine which are system users and which are normal users by looking at the uid (the first number after the username in `/etc/passwd` -- if that is less than 1000, it is a system account.
	* (where did I get that number? the `/etc/login.defs` file -- look for `UID_MIN 1000`. It may be different on CentOS).

* Disable unnecessary users with the following commands (replace `treebeard` with the offending username):
	* `sudo usermod --expiredate 1 treebeard`
	* `sudo passwd -l treebeard`

* You can also simply delete the user. 
	* `deluser treebeard` on ubuntu
	* `userdel treebeard` on centos
	* Disabling may be better if you aren't sure if a user might be necessary, or if you need to figure out what a user was doing in the past. Once you delete the user, you won't be able to reenable them or investigate their activities.

### Make sure your necessary users don't have unnecessary rights
The most important one here is to make sure nobody has sudo rights unless they are an administrator (i.e. team member).

* Use the `members` command to find this:
	* `members sudo` (you can replace sudo with any other group)
	* you may need to install the members commmand:
`sudo apt-get install members`
	* If you see a user in the resulting list who shouldn't be there, remove them from the group.

* `deluser user group` in ubuntu (make sure not to `deluser user`)
	* see this link for things to try with centos. Be careful that you don't delete users though. [remove user link](http://unix.stackexchange.com/questions/29570/how-do-i-remove-a-user-from-a-group)

### Add user accounts for your team members
The following are instructions for Ubuntu. For CentOS, `useradd` should replace `adduser`, but you may have to look at the user management link provided above.

* create bob: `sudo adduser bob`
* make bob part of the sudo group: `sudo adduser bob sudo`
* check that bob is part of the sudo group: `groups bob` should return `bob: bob sudo`

#### Sudo
It appears that on centos you will need to modify the sudoers file to give administrative rights to members of the sudo group.

* Edit the sudo file using `sudo visudo`. (Don't edit the file directly)
* In ubuntu you will see something like: `%sudo ALL=(ALL) ALL`
* In centos that line will be commented out, like this: `#%sudo ALL=(ALL) ALL` (notice the `#` symbol).
* On your centos box, uncomment that line (remove the `#`), and then test that people with the sudo group can do administrative tasks.

### Disable Root Login
Avoid using root directly where you can. If you don't have permissions to do something, try sudo first.
Definitely, once you have a sudo user who can do sudo things (log in with that user from putty and try `sudo -i` to make sure), you can disable the root account with the same disable commands from above.

### Resetting a Password
If one of your team members forgets his password, or it stops working, you can change his password with `sudo passwd user`.

## Software Management

### Update your software
Updating software is one of the most important elements of security. Old software has known vulnerabilities that hackers keep in databases. When they find an old version of software, they are two clicks away from running an exploit.

While updates should not be run as root directly, the proxy configuration probably means you will need to run it as root. `sudo -i` to get root prompt, then run the commands. if you are already root, you don't need to sudo, although you (usually) can.

* Ubuntu: `sudo apt-get update; sudo apt-get upgrade`
* CentOS: `sudo yum update`

### Service Management
Look for running services that don't need to be running.
The main way to check this is the same way an attacker would, by using nmap.
Nmap is a scanning tool -- it scans your computer to see what services it has available.

To nmap your server:

* install nmap: `sudo apt-get install nmap` or `sudo yum install nmap`.
* run nmap `nmap localhost`
* You will see a list of services. Compare that with the list of services listed in the Nagios scoring system. Any that are not scored on, you should be free to remove.
* If you don't know what a service does, use google. ;)

Once you find something that doesn't need to be there, like ftp, you will need to find the Ubuntu or CentOS service that is actually running. In the case of ftp, it could be something actually named `vsftp`.

The general concept is:

* stop the service: `sudo service vsftp stop`
* uninstall the program: `sudo apt-get remove vsftp`
* [this question and answer](http://askubuntu.com/questions/477596/how-to-stop-and-remove-ftp-service) has more information.

[Here's another article that may help](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/3/html/Security_Guide/s1-server-ports.html) -- this one is written by Red Hat, the company that manages CentOS.

### Isolate running services
You want running services, like Apache, and MySQL to run under their own dedicated user accounts. Unfortunately, the configuration for that is specific to each service. Usually, though, they come out of the box configured to run with dedicated user accounts.

### Change default service passwords
Tomcat, WordPress, MySQL, and others have their own user authentication mechanisms. You will need to investigate the user accounts on each of these systems.

Here are some links explaining how to secure some of these systems:

* [Cyclos](http://www.cyclos.org/wiki/index.php?title=Installation_%26_maintenance)
* [Tomcat](https://geekflare.com/apache-tomcat-hardening-and-security-guide/)
* [RequestTracker](https://docs.bestpractical.com/rt/4.2.13/security.html)
* [WordPress](https://premium.wpmudev.org/blog/keeping-wordpress-secure-the-ultimate-guide/)
* [MySQL](http://dev.mysql.com/doc/refman/5.7/en/security-against-attack.html)
* For anything else, google "How to secure" followed by the name of the thing.

### Look for bad things:

If you have lots of time to kill, you can start crawling around your system looking for bad things. The problem is it is difficult to know what you are looking for without having lots of experience and lots of google time. But if you are feeling up to it, there are three main kinds of places for bad things to hide:

* startup scripts -- see `/etc/init.d`, and [this in depth article](http://www.tldp.org/HOWTO/HighQuality-Apps-HOWTO/boot.html)
* scheduled tasks -- find out more about cron scheduling [here](https://help.ubuntu.com/community/CronHowto)
* login scripts: these are the bashrc, bash\_aliases and bash_profiles files. 

You can also take a look at [this ubuntu security article](http://www.tldp.org/HOWTO/HighQuality-Apps-HOWTO/boot.html)


### Learn your detection mechanisms
Detection mechanisms come in two main flavors:

* log files, like `auth.log` and apache's access and error logs.
* Monitoring systems like your nagios and the scorebot. (you could also, if you are adventurous, install an intrusion detection system).

### Add some active defense layers
Honeypots provide a layer of security by slowing your attackers down. They are not a substitute for real security, but when used correctly can make it much harder for attackers to get in.

The general principle is to have something that looks good, but that only an attacker would ever find. This kind of thing helps you figure out who is an attacker and who is a good user. 

A couple of honeypots that could be of use to you:

* [HoneyPort](https://github.com/securitygeneration/Honeyport)
* [Kippo](https://github.com/desaster/kippo) (thanks to one of your fellow students for this suggestion).
