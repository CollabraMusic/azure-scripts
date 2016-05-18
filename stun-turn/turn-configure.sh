#!/bin/bash
TURN_USERNAME=
TURN_PASSWORD=
TURN_EXTERNAL_IP=

error()
{
    echo "$1" >&2
    exit 3
}

log()
{
    echo "$1"
}

require_opt()
{
    if [ ! "$1" ];
    then
        error "$2 argument is required"
    fi
}

while :; do
    case "$1" in
        --turn-username)
            TURN_USERNAME="$2"
            shift
            ;;
        --turn-password)
            TURN_PASSWORD="$2"
            shift
            ;;
        --turn-external-ip)
            TURN_EXTERNAL_IP="$2"
            shift
            ;;
        *)
            break
    esac

    shift
done

require_opt "$TURN_USERNAME" "--turn-username"
require_opt "$TURN_PASSWORD" "--turn-password"
require_opt "$TURN_EXTERNAL_IP" "--turn-external-ip-address"

apt-get update
apt-get install -y coturn

echo "TURNSERVER_ENABLED=1" > /etc/default/coturn
echo "lt-cred-mech
realm=default
external-ip=$TURN_EXTERNAL_IP
" > /etc/turnserver.conf
turnadmin -a -u "$TURN_USERNAME" -p "$TURN_PASSWORD" -r default
service coturn restart
