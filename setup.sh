#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt update -qq && apt full-upgrade -y -qq
apt install -qq -y iptables sudo curl ssh build-essential gcc g++ automake git-core git autoconf make patch libmysql++-dev libtool libssl-dev grep binutils zlibc libc6 libbz2-dev cmake subversion libboost-all-dev wget tmux p7zip-full libtbb-dev libace-dev libmysqlclient-dev openssl libssl-dev zlib1g-dev mariadb-server
curl -s https://install.zerotier.com | bash


##GET_FILES
git clone https://github.com/vmangos/core.git /opt/azeroth/core
git clone https://github.com/brotalnia/database.git /opt/azeroth/db


##FOLDER_STRUCT
mkdir /opt/azeroth/core/build && cd /opt/azeroth/core/build
cmake -DDEBUG=0 -DSUPPORTED_CLIENT_BUILD=5875 -DUSE_EXTRACTORS=0 -DCMAKE_INSTALL_PREFIX=/opt/azeroth ../ && make -j $(nproc) && make install
7z x /opt/azeroth/db/$(find /opt/azeroth/db/ -name "*.7z" | sort -t _ -k5 -k4M -k3 | tail -n 1 | cut -d / -f 5) -o/opt/azeroth/core/sql/
cd /opt/azeroth/core/sql/migrations/
./merge.sh
cd /


##CONFIGURE
mv /opt/azeroth/etc/mangosd.conf.dist /opt/azeroth/etc/mangosd.conf
mv /opt/azeroth/etc/realmd.conf.dist /opt/azeroth/etc/realmd.conf
sed -i 's/DataDir = "."/DataDir = "\/opt\/azeroth\/data"/ ; s/LogsDir = ""/LogsDir = "\/opt\/azeroth\/logs"/' /opt/azeroth/etc/mangosd.conf
sed -i 's/LogsDir = ""/LogsDir = "\/opt\/azeroth\/logs"/' /opt/azeroth/etc/realmd.conf
cp /opt/azeroth/etc/mangosd.conf /opt/azeroth/etc/realmd.conf /opt/azeroth


##ADD_USER
useradd -mUs /bin/bash admin
echo "admin:pass" | chpasswd
usermod -aG sudo admin
chown -R admin:admin /opt/azeroth/
cat << EOF >> /home/admin/.bashrc
if [[ -n \$SSH_CONNECTION ]]; then
     tmux attach -t azeroth
fi
EOF

chmod 700 start.sh db_setup.sh
