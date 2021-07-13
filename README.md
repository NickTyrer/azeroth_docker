# Azeroth Docker

A docker image to host your own private World of Warcraft server over a Zerotier network.

### Getting Started

Firsty get youself a free [Zerotier](https://www.zerotier.com/) account as this server will be hosted over a Zerotier network. Here is a good primer on [Zerotier](https://www.youtube.com/watch?v=Bl_Vau8wtgc) to show what we are aiming for. Once you have your account, set up a new Zerotier network and note the network id.

### Container Creation

```
docker run -d \ 
           -e ZT_NET=<network id> \
           -v <local path for db files>:/var/lib/mysql \
           -v <local path for config files>:/opt/azeroth/etc \
           -v <local path for honor files>:/opt/azeroth/honor \
           --cap-add=NET_ADMIN \
           --cap-add=SYS_ADMIN \
           --device /dev/net/tun \
           --name=<container name> \
           nicktyrer/azeroth_docker
```

### Join the Zerotier Network

Once the container is running head back to the config page for your Zeroier network and authorise the container access to the network and then note down the containers IP address (In the managed IP's column).


### Add a GM Account

Attach to the container
```
docker exec -ti <container name> /bin/bash
````

Attach to the tmux session
```
sudo -u admin tmux a -t azeroth
```

```
account create <username> <password>
```

```
account set gmlevel <username> 6
```
detach from tmux using `ctrl+b then d` then `exit` to exit the container

### Client config

People wanting to connect to the server will need three things:
1. Zerotier client with access to the Zerotier network
2. World of Warcraft 1.12.1 client (use one of the links [here](https://elysium-project.org/howtoplay/en))
3. Edit realmlist.wtf in the Warcraft World of Warcraft 1.12.1 client to include `set realmlist <zerotier container ip>`

### Security

Take a look [here](https://blog.reconinfosec.com/locking-down-zerotier/) for how to restrict access to your container using Zerotiers network flow rules.


Thats it - [here](https://www.reaper-x.com/2007/09/21/wow-mangos-gm-game-master-commands/) are all of the gm commands to administer your server.

## Sources
[vMangos](https://github.com/vmangos/core)
