---
layout: page
title: Incomplete Linux Security Crash Course
permalink: gencyber2017
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
    * `netstat -tulpn | grep 1337`
    * `tcp    0    0 0.0.0.0:1337    0.0.0.0:*    LISTEN    3652/nc`
    * in this case 3652 is the process id.
2. Figure out which files are being used by the process.
    * `lsof -p 3652` (change the number to match the process id)
    ```
    COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF    NODE NAME
    nc      3652 rose  cwd    DIR    8,1     4096 2097264 /home/rose
    nc      3652 rose  rtd    DIR    8,1     4096       2 /
    nc      3652 rose  txt    REG    8,1    27160  655411 /bin/nc.traditional
    nc      3652 rose  DEL    REG    8,1          1576273 /lib/x86_64-linux-gnu/libnss_files-2.13.so
    nc      3652 rose  DEL    REG    8,1          1576266 /lib/x86_64-linux-gnu/libc-2.13.so
    nc      3652 rose  DEL    REG    8,1          1576264 /lib/x86_64-linux-gnu/ld-2.13.so
    nc      3652 rose    0u  sock    0,7      0t0    7534 can't identify protocol
    nc      3652 rose    1u   REG    8,1        0 2490381 /tmp/tmpfhdUXJp (deleted)
    nc      3652 rose    2u   REG    8,1        0 2490381 /tmp/tmpfhdUXJp (deleted)
    nc      3652 rose    3u  IPv4   7535      0t0     TCP *:1337 (LISTEN)

    ```
    * Things to note:
        * the user for all these commands is rose -- so rose is the one running the backdoor.
        * some of the files used by the process are the program that it is running. In this case, `/bin/nc` is the actual program. But nc is a basic program. We need to figure out HOW rose is running the program.
        * Don't just kill the process. You could eliminate the trail to the process. But in this case, it's actually easy -- the process will restart in a minute if we kill it.
        * Why??? something is restarting the process! Probably a scheduled task. In linux, cron is the way to create scheduled tasks.
        * Edit rose's crontab:
            * `crontab -u rose -e`
            * This line: `* * * * * /usr/sbin/backdoor` tells the scheduler to run the program `/usr/sbin/backdoor` every minute.
            * remove that line from the crontab.
            * make sure it's been removed: `crontab -u rose -l`
        * for fun: explanation of the backdoor:
            ```
            It is a script:
            #!/bin/bash
            
            This is the command it uses to check that the script is running:
            isOn=`netstat -tln | grep ':1337'|wc -l`
            
            The if statement checks the result of the isOn command -- if it is zero, then
            if [ $isOn == "0" ]
            then
              It starts a netcat command that enables data sent to the 1337 port to give access to bash (the command line)
              nc -l -p 1337 -e /bin/bash
            fi
            ```
        * Now remove the backdoor file:
            * `rm /usr/sbin/backdoor`
3. Verify that it's gone:
    * no more listening `netstat -tulpn | grep 1337`
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

## 4. OS Services

* Minimization: remove any unnecessary services
* Configuration: configure services correctly so that they don't allow inappropriate access.
* User accounts: if services allow logins, make sure the user accounts for those services are secure.

While there are a number of services that probably don't need to be running on your server, the really important ones are the ones that are accessible over the network. These are the ones that Red Team can use to attack your server.

* Find services listening on the network with: `netstat -tulpn`
* You will see a list of services. Compare that with the list of services listed in the Nagios scoring system. Any that are not scored on, you should be free to remove. Some of these services show as vulnerable in the OpenVAS scan, but some are still unnecessary.
* If you don't know what a service does, use google. ;)

## Minimization: remove unnecessary services


For each:

* stop the service: `service samba stop`
* completely uninstall the program: `apt-get purge samba`

Remove at least the following services:

* cups (printing): `service cups stop`; `apt-get remove cups`
* swat: `update-inetd --disable swat`
* samba (windows file sharing) (smbd and nmbd): `/etc/init.d/samba stop`; or just `apt-get remove samba` (apt also stops the service)
* nfs (linux file sharing): `service nfs-common stop`; `apt-get remove nfs-common`
* rpcbind (used by nfs): `service rpcbind stop`; `apt-get remove rpcbind`
* avahi-daemon (apple discovery services!): `service avahi-daemon stop`; `apt-get remove avahi-daemon`
* exim4 (email server): `service exim4 stop`; `apt-get remove exim4`
* postgres (sql databases): (be careful -- make sure it is not being used by the application running on the server) `service postgresql stop`; `apt-get remove postgresql`
* minissdpd (plug and play network protocols): `service minissdpd stop`; `apt-get remove minissdpd`


Once a server is secured, the netstat output should look something like this (although it will be a little different on some servers):
```
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:3306            0.0.0.0:*               LISTEN      3050/mysqld     
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      3706/sshd       
tcp6       0      0 :::80                   :::*                    LISTEN      2411/apache2    
tcp6       0      0 :::21                   :::*                    LISTEN      3778/proftpd: (acce
tcp6       0      0 :::22                   :::*                    LISTEN      3706/sshd       
udp        0      0 0.0.0.0:68              0.0.0.0:*                           2365/dhclient   
udp        0      0 0.0.0.0:64836           0.0.0.0:*                           2365/dhclient   
udp6       0      0 :::54657                :::*                                2365/dhclient   
```

When you are done:

`apt-get autoremove` to remove remaining unnecessary packages.


## Minimization: remove unnecessary services

For each:

* stop the service: `service samba stop`
* completely uninstall the program: `apt-get purge samba`

Remove at least the following services:

* samba (smbd and nmbd): service samba stop; apt-get purge samba
* cups (printing): service cups stop; apt-get purge cups

look for:
telnet, rlogin, rexec, automount, named, inetd, portmap (nfs)

remove anything but ssh, ftp, apache, tomcat, and mysql.

You can get more information from [this article](https://www.tecmint.com/remove-unwanted-services-from-linux/) and [this q&a](http://askubuntu.com/questions/477596/how-to-stop-and-remove-ftp-service).

## Configuration and User Accounts: configure services securely.

* ssh (port 22): secure shell allows operating system users to log in. Apart from changing operating system user passwords and updating packages, there isn't much to do here. There is the scan warning about weak encryption algorithms. However, as advanced as our Red Team is, they aren't the NSA, and they don't have a week to attack us, so the weak encryption algorithms should not cause significant problems, and therefore are not worth spending time on (yet).
    * consider quickly installing fail2ban as a countermeasure.

* ftp: we need to disable anonymous access.
    remove proftp
    install ftp
    * https://www.pluralsight.com/blog/it-ops/how-to-set-up-safe-ftp-in-linux
    * `nano /etc/vsftpd.conf` and change `anonymous_enable=YES` to `anonymous_enable=NO`
    * ordinary we would also allow local users to log in, however, we just need to keep the port open, not actually logging in since nagios can't log in..., so not enabling local users keeps things simple. :)
    * restart the service to reload configuration: `service vsftp restart`
    
* apache:
    * https://www.tecmint.com/apache-security-tips/
    * Remove the phpinfo.php file:
        * `rm /var/www/phpinfo.php`
    * change permissions of web directory:
        * http://fideloper.com/user-group-permissions-chmod-apache
        * https://wiki.apache.org/httpd/FileSystemPermissions
        * `$ sudo chown -R www-data:www-data /var/www`
        * `find /var/www/html -type f -exec chmod 640 {} \;`
        * `find /var/www/html -type d -exec chmod 750 {} \;`
    * to configure: `nano /etc/apache2/apache2.conf`
    * Lock down which directories are accessible:
        ```
            <Directory />
            Options None
            Order deny,allow
            Deny from all
            </Directory>
        ```
    
    * Disable Directory Listing:
        ```
          <Directory /var/www/html>
              Options -Indexes
          </Directory>
        ```
    * Verify it's running as www-data:
        * `User www-data`
        * `Group http-web`
        * `ps ax | grep 'apache'`
    * hide version numbers
        * `ServerSignature Off`
        * `ServerTokens Prod`
    * install modsecurity?
        $ sudo apt-get install libapache2-modsecurity
        $ sudo a2enmod mod-security
        $ sudo /etc/init.d/apache2 force-reload
    * install modevasive?
        $ sudo apt-get install libapache2-modevasive
        $ sudo a2enmod mod-evasive
        $ sudo /etc/init.d/apache2 force-reload


* Mysql: 
    * https://www.digitalocean.com/community/tutorials/how-to-secure-mysql-and-mariadb-databases-in-a-linux-vps
    * only run it on loopback interface:
        * configure: `nano /etc/mysql/my.cnf`
        * change: `bind-address = 127.0.0.1`
        * prevent loading local files: `local-infile=0`
    * at this point, this is probably as secure as we'll get it for single application servers. If you were running multiple databases on a single mysql instance, you'd want to do things a little differently.

if "Local Address" starts with 0.0.0.0, it is public. If 127.0.0.1, it's private to this server.


* Tomcat
    * https://www.owasp.org/index.php/Securing_tomcat
    * remove default web application (just remove files... see the common section of the link)
    * change default management user account (xml) to not be tomcat/tomcat (unnecessary if the management application is removed).
    * protect the shutdown port


(also, read an article on properly securing each -- to make sure any gotchas are caught.)



* For anything else, google "How to secure" followed by the name of the thing.

## 5. Application Software

Once you have your operating system and services secure, it's time to secure the applications running on your system, which can often provide a lot of access for attackers to your computer.

Your applications are:
* WordPress
* Joomla
* Drupal
* Request Tracker
* Jenkins
* Gitlab
* Bugzilla

For each, you will need to address the same broad categories:
    * Updates
    * Configuration
    * User accounts
    
I have been in charge of two servers running WordPress that got hacked. One was because WordPress was out of date, another was because a WordPress account had a bad password.

Mr Frankenfield will cover this section in more detail. 

## 6. Firewalls

Mr Frankenfield will cover firewalls in his networking section, but I'll quickly cover them in less detail.

## 7. Detection 
Detection mechanisms come in two main flavors:

focus this section on linux detection mechinisms (and identify it as an opportunity to let less technical team members help -- as in, have a mentor explain to them what a legitimate threat looks like relative to an attacker threat.)

* log files, like `auth.log` and apache's access and error logs.
* *build out a list of logs to watch*
* Monitoring systems like your nagios and the scorebot.


also, in the real world, elaborate intrusion detection systems are used.


# Resources

The [Securing Debian Manual](https://www.debian.org/doc/manuals/securing-debian-howto/index.en.html#contents) has a lot of in-depth detail on the process of securing a Debian Linux computer. 

## Introductory Videos
Here are some videos to help introduce concepts that may be foreign to you:

* [What is a Computer](https://www.youtube.com/watch?v=AkFi90lZmXA)?
* [What is an Operating System](https://www.youtube.com/watch?v=pVzRTmdd9j0)?
* [What is Open Source Software](https://www.youtube.com/watch?v=a8fHgx9mE5U)?
* [What is Linux](https://www.youtube.com/watch?v=zA3vmx0GaO8)?
	* in case you were interested, check out [the linux source code](https://github.com/torvalds/linux)

## How to use the Linux Command Line
Learn the basics from the [learning the shell tutorial](http://linuxcommand.org/lc3_learning_the_shell.php).

If you already know how to use the command line, you should learn scripting. Scripting unleashes the true power of linux and its command line. You can learn more about that from [a different tutorial on the site](http://linuxcommand.org/lc3_writing_shell_scripts.php).


For the adventurous: I love using vim. If you are bored and want a really cool challenge, learn vim. Try [this vim tutorial to get started](http://www.openvim.com/).


## Learn more about user management
User management can get much more complicated, and in a normal production setup we would disable root login, give every team member a user account on the server, and do a lot more in-depth configuration of the user accounts on the server. Our objective is to secure against red-team, so we will do the absolute minimum that achieves that goal, so that we have time to do all the things that secure against red-team, instead of spending the whole week doing enterprise-grade user management.

See [this ubuntu article](https://help.ubuntu.com/14.04/serverguide/user-management.html) for more info on managing users (our servers are debian, but ubuntu is based on debian, and its article is much more friendly).

