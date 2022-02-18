# Personal server
A simple server running Ubuntu server 20.04.3 on my old laptop. I will be documenting the steps i took to get the server up and running as well ass sharing the scripts - files etc i created along the way.

## Table of contents
1. [Setup](#Setup-and-initial-tweaking)
2. [OpenSSH](#Setting-up-openssh)
3. [Git](#Git)
4. [Scripts](#Scripts)
4. [File Server](#Network-file-server)
5. [Plex Server](#Plex-media-server)

## Setup and initial tweaking
Step one download and install ubuntu server on you machine. There are plenty of turtorials online about how to do this. Download the iso from the official ubuntu website: https://ubuntu.com/download/server 

### Run the server with the laptop-lid closed
In order to make sure the server does not turn of when the laptop lid is closed you have to modify the file `/etc/systemd/logind.conf`. 

**You can either change the file manually:**
```bash
nano /etc/systemd/logind.conf
``` 
change the line `#HandleLidSwitch=suspend` to `HandleLidSwitch=ignore`. (*remember to remove the '#'*)

Then refresh with the command:
```bash
sudo service systemd-logind restart
```

**Or change the file with this command:**
```bash
sudo sed -i "s/HandleLidSwitch=.*/HandleLidSwitch=ignore/g" /etc/systemd/logind.conf
```

## Setting up openssh
### Initial setup
1. Install Openssh
```bash
sudo apt-get install openssh-server
```
2. Enable ssh service
```bash
sudo systemctl enable ssh
```
3. Once installed start the server
```bash
sudo systemctl start ssh
```

find your server ip:
```bash
ip route
```

you can now ssh into the server from other devices on the same network with the command:
```bash
ssh <username>@<server_ip>
```

### Passwordless login
1. Find you client ssh public key in your `$HOME/.ssh` folder. 
copy the public key printed when running the command:
```bash
cat $HOME/.ssh/id_rsa.pub
```

- If the folder or the key does not exist create it by doing this:
  a. create the folder
  ```bash
  mkdir $HOME/.ssh
  ```
  b. create the ssh-key:
  ```bash
  ssh-keygen
  ```

2. SSH into the server and navigate to the .ssh folder. If id does not exist do the same as above

3. copy the client public key into the server `authorized_keys` file.
```bash
nano $HOME/.ssh/authorized_keys
```
You should now be able ssh into the server from this client without a password


### Port forwarding
**NB port forwarding is a possible security risk**, as you enable a new attack vector over the internet. Make sure your ssh-server has a strong password. 

By enabeling port forwarding in your router it is now possible to connect to the server from outside your local network. 

1. find your public network address. You can find it on google: https://www.google.com/search?q=what+is+my+ip&oq=what+is+my+ip

2. find your ssh servers local address. This can be found by running this command on the server:
```bash
ip route | grep -oP '(?<=dhcp src )[^ ]*'
```

3. enable port forwarding in your wifi settings. How to do this depends on your isp, but i found it by opening `192.168.0.1` in the browser
  - create a ssh port forwarding rule on port 22 with the server ip as the internal host.

4. You should now be able to connect to the ssh-server from outside the network by using the address
```bash
ssh <username>@<public ip address>
```

### Limit amount of login-attempts
inspired by this thread *https://serverfault.com/questions/275669/ssh-sshd-how-do-i-set-max-login-attempts*


Set the max number of login-attempt to 1 for each connection
In `/etc/ssh/sshd_config` add the line
```bash
MaxAuthTries 1
```

Add rules to the firewall in order to drop request from the same IP-address if there is more than 3 connection-attempts in 2 minutes.
Create a new chain
```bash
sudo iptables -N SSHATTACK
sudo iptables -A SSHATTACK -j LOG --log-prefix "Possible SSH attack! " --log-level 7
sudo iptables -A SSHATTACK -j DROP
```
addd rules
```bash
sudo iptables -A INPUT -i eth0 -p tcp -m state --dport 22 --state NEW -m recent --set
sudo iptables -A INPUT -i eth0 -p tcp -m state --dport 22 --state NEW -m recent --update --seconds 120 --hitcount 4 -j SSHATTACK
```
See log of blocked attacks here in `/var/log/syslog`:
```bash
Dec 27 18:01:58 ubuntu kernel: [  510.007570] Possible SSH attack! IN=eth0 OUT= MAC=01:2c:18:47:43:2d:10:c0:31:4d:11:ac:f8:01 SRC=192.168.203.129 DST=192.168.203.128 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=30948 DF PROTO=TCP SPT=53272 DPT=1785 WINDOW=14600 RES=0x00 SYN URGP=0
```

### Disable pasword login. Only allow public/private ssh key
In order to avoid password brute force attacks one posibility is only allowing rsa keys. 

This can be done by changing the `/etc/ssh/sshd_config` file
```bash
sudo nano /etc/ssh/sshd_config
```
change `/PermitRootLogin yes` to `PermitRootLogin no`' and `PasswordAuthentication yes` to PasswordAuthentication no

## Git
The .bashrc file is a part of the repository, but its not located inside the `magnum_server` folder structure. In order to do this i link the file inside the folder structure.
```bash
ln <.bashrc path>
```
The .bashrc file can now be added to git normally.


## Scripts
### Monitoring
A script to monitor events on the ssh-server. Used to detect unwanted logins or login-attempts. Uses persitant storage in order to se changes from last time the monitor script was ran

```bash
monitor [-h] [-m] [-f] [-c]
-h: Help 
-m: More info 
-f: Failed login 
-c: Custom <search query>
```

### See laptop battery
```bash
battery
#alternatively
power
```

## Network file server
SSFS can be used to connect the server filesystem to the client machine. 

On the client machine:
1. create the directory to put the file system
```bash
mkdir <directory name>
```

2. Mount the file system
```bash
'sshfs <server-name>:<remote/file/path> <path/to/directory>'
```

If you want to unmount the file system
```bash
umount <path/to/directory>
```

## Synching files between laptop and server with `rsynch`. 
Rsynch is a tool preinstalled on most linux distributions that can be used to synch files between multiple places. The tool can traverse file systems recursively and also only updates changed/new files.

### usage
```bash
rsync <flags> <source location> <remote location>
```

my usage
```bash
rsync -a -v -e "ssh -p 22" MyDirName/ username@192.168.0.20:/my/target/location 
```

### periodic backup
In order to automatically backup any changes to the server i created a small script on my laptop. The script runs the rsynch command above every day at 12:00. The script is added as a `crontab job` as follows.

1. open the file
```bash
sudo crontab -e 
```

2. add the folowing line.
```bash
00 12 * * * /home/magnus/Progging/Scripts/backup.sh
```

## Plex media server
A plex server was installed using the installation guide in the plex documentation

## Endlessh
While setting up this server i used my monitor script to monitor login-attempts. Almost instantly after enabeling port forwarding i noticed a flood of login attempts. Within the first day i had over 1000 attempts. The attackers seemed to be using a standard dictionary attack trying different normal usernames and password combintions. I quickly switched to only using ssh-keys puting an end to the attacks.

Endlessh is a simple tiny way of getting back at the attackers, making their scrips slower by abusing the message sendt to users when loging in. When a client is trying to connect to my ssh-server on port 22 an infinite message is sendt causing the scripts to wait forever without crashing. My actual server is moved to a different port number.

The project is available here https://github.com/skeeto/endlessh
