#!/bin/bash
mysql_install_db
service mysql start
mysql -u root -e "CREATE DATABASE IF NOT EXISTS realmd DEFAULT CHARSET utf8 COLLATE utf8_general_ci;"
mysql -u root -e "CREATE DATABASE IF NOT EXISTS characters DEFAULT CHARSET utf8 COLLATE utf8_general_ci;"
mysql -u root -e "CREATE DATABASE IF NOT EXISTS mangos DEFAULT CHARSET utf8 COLLATE utf8_general_ci;"
mysql -u root -e "CREATE DATABASE IF NOT EXISTS logs DEFAULT CHARSET utf8 COLLATE utf8_general_ci;"
mysql -u root -e "create user 'mangos'@'localhost' identified by 'mangos';"
mysql -u root -e "SET PASSWORD FOR 'mangos'@'localhost' = PASSWORD('mangos');"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'mangos'@'%' IDENTIFIED BY 'mangos';"
mysql -u root -e "flush privileges;"
mysql -u root -e "grant all on realmd.* to mangos@'localhost' with grant option;"
mysql -u root -e "grant all on characters.* to mangos@'localhost' with grant option;"
mysql -u root -e "grant all on mangos.* to mangos@'localhost' with grant option;"
mysql -u root -e "grant all on logs.* to mangos@'localhost' with grant option;"
mysql -u root realmd < /opt/azeroth/core/sql/logon.sql
mysql -u root logs < /opt/azeroth/core/sql/logs.sql
mysql -u root characters < /opt/azeroth/core/sql/characters.sql
mysql -u root mangos < /opt/azeroth/core/sql/world_full_*
mysql -u root realmd < /opt/azeroth/core/sql/migrations/logon_db_updates.sql
mysql -u root logs <   /opt/azeroth/core/sql/migrations/logs_db_updates.sql
mysql -u root characters < /opt/azeroth/core/sql/migrations/characters_db_updates.sql
mysql -u root mangos < /opt/azeroth/core/sql/migrations/world_db_updates.sql
mysql -u root realmd -e "DELETE FROM realmlist WHERE id=1;"
mysql -u root realmd -e "INSERT INTO realmlist (id, name, address, port, icon, realmflags, timezone, allowedSecurityLevel) VALUES ('1', 'Hellscream', '127.0.0.1', '8085', '1', '0', '1', '0');"
