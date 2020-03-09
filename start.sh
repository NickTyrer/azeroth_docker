#!/bin/bash

#check if database dir mangos is present (wont be if a mount is used)
if [ ! -d /var/lib/mysql/mangos ]; then
./db_setup.sh
fi

#check if config files are present (wont be if a mount is used)
if [ -z "$(ls -A /opt/azeroth/etc)" ]; then
cp /opt/azeroth/mangosd.conf /opt/azeroth/realmd.conf /opt/azeroth/etc
fi

#setup ipatbles
iptables -P INPUT DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 8085 -j ACCEPT
iptables -A INPUT -p tcp --dport 3724 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT

#start services
if ! pgrep -x "mysqld" > /dev/null; then
service mysql start
fi
service ssh start
./usr/sbin/zerotier-one -d
sleep 10

#join zerotier network and wait for ip to be assigned then update db with assigned ip
zerotier-cli join $ZT_NET
while [ -z $(ip a | grep zt | grep inet | awk '{print $2}' | cut -d / -f 1) ] ; do sleep 10; done; ZT_IP=$(ip a | grep zt | grep inet | awk '{print $2}' | cut -d / -f 1)
mysql -u root realmd -e "UPDATE realmlist SET address = '$ZT_IP' WHERE id = 1;"

#setup tmux console
runuser -l admin -c "tmux new -d -s azeroth"
runuser -l admin -c "tmux send-keys 'cd /opt/azeroth/bin && ./mangosd' C-m"
runuser -l admin -c "cd /opt/azeroth/bin && ./realmd"
