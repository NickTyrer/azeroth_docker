#!/bin/bash
##CHECK_IF_DATABASE_DIR_MANGOS_IS_PRESENT (wont be if a mount is used)
if [ ! -d /var/lib/mysql/mangos ]; then
./db_setup.sh
fi


##CHECK_IF_CONFIG_FILES_ARE_PRESENT (WONT_BE_IF_A_MOUNT_IS_USED)
if [ -z "$(ls -A /opt/azeroth/etc)" ]; then
cp /opt/azeroth/mangosd.conf /opt/azeroth/realmd.conf /opt/azeroth/etc
fi


##SETUP_IPTABLES
iptables -P INPUT DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 8085 -j ACCEPT
iptables -A INPUT -p tcp --dport 3724 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT


##START_SERVICES
if ! pgrep -x "mysqld" > /dev/null; then
service mysql start
fi
service ssh start
./usr/sbin/zerotier-one -d
sleep 10


##JOIN_ZEROTIER_NETWORK_AND_WAIT_FOR_IP_TO_BE_ASSIGNED_THEN_UPDATE_DB_WITH_ASSIGNED_IP
zerotier-cli join $ZT_NET
while [ -z $(ip a | grep zt | grep inet | awk '{print $2}' | cut -d / -f 1) ] ; do sleep 10; done;
ZT_IP=$(ip a | grep zt | grep inet | awk '{print $2}' | cut -d / -f 1)
mysql -u root realmd -e "UPDATE realmlist SET address = '$ZT_IP' WHERE id = 1;"


##SETUP_TMUX_CONSOLE
runuser -l admin -c "tmux new -d -s azeroth"
runuser -l admin -c "tmux send-keys 'cd /opt/azeroth/bin && ./mangosd' C-m"
runuser -l admin -c "cd /opt/azeroth/bin && ./realmd"
