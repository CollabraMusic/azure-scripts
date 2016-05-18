#!/bin/bash

apt-get update
apt-get install -y coturn

echo "TURNSERVER_ENABLED=1" > /etc/default/coturn

echo "stun-only" > /etc/turnserver.conf

service coturn restart
