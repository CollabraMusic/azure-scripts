#!/bin/bash
TURN_USERNAME=
TURN_PASSWORD=

apt-get update
apt-get install -y coturn

echo "TURNSERVER_ENABLED=1" > /etc/default/coturn
echo "lt-cred-mech
realm=default
" > /etc/turnserver.conf
turnadmin -a -u "$TURN_USERNAME" -p "$TURN_PASSWORD" -r default
service coturn restart
