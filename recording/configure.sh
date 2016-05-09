#!/bin/bash

ENV="{"
STORAGE_ACCOUNT_NAME=
MNT_SHARE_NAME=
MNT_SHARE_DIR=
STORAGE_ACCESS_KEY=

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
        --env)
            ENV="$2"
            shift
            ;;
        --storage-account-name)
            STORAGE_ACCOUNT_NAME="$2"
            shift
            ;;
        --mnt-share-name)
            MNT_SHARE_NAME="$2"
            shift
            ;;
        --mnt-share-dir)
            MNT_SHARE_DIR="$2"
            shift
            ;;
        --storage-access-key)
            STORAGE_ACCESS_KEY="$2"
            shift
            ;;
        *)
            break
    esac

    shift
done

require_opt "$ENV" "--env"
require_opt "$STORAGE_ACCOUNT_NAME" "--storage-account-name"
require_opt "$MNT_SHARE_NAME" "--mnt-share-name"
require_opt "$MNT_SHARE_DIR" "--mnt-share-dir"
require_opt "$STORAGE_ACCESS_KEY" "--storage-access-key"

chmod +x ./set-env-0.1.py
echo "$ENV" | python ./set-env-0.1.py -o /var/www/recording-api/source/.env

chmod +x ./afs-utils-0.1.sh
bash ./afs-utils-0.1.sh -a "$STORAGE_ACCOUNT_NAME" -p -c -s "$MNT_SHARE_NAME" -b "$MNT_SHARE_DIR" -k  "$STORAGE_ACCESS_KEY"

export HOME=/root PM2_HOME=/root/.pm2
node /usr/bin/pm2 restart all

bashrc = /home/azureuser/.bashrc
sudo_alias = "alias sudo = 'sudo '"
if [ ! grep -Fxp "$sudo_alias" "$bashrc" ];
then
    echo "$sudo_alias" >> "$bashrc"
fi

pm2_alias = "alias pm2='HOME=/root PM2_HOME=/root/.pm2 pm2'"
if [ ! grep -Fxp "$pm2_alias" "$bashrc" ];
then
    echo "$pm2_alias" >> "$bashrc"
fi

