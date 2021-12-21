# magnum_server
A simple server running Ubuntu server 20.04.3 on my old laptop. I will be documenting the steps i took to get the server up and running as well ass sharing the scripts - files etc i created along the way.

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

## Git
The .bashrc file is a part of the repository, but its not located inside the `magnum_server` folder structure. In order to do this i link the file inside the folder structure.
```bash
ln <.bashrc path>
```
The .bashrc file can now be added to git normally.

## Scripts

### Monitoring

## Local network file server

## Plex media server