#!/bin/bash

ENV=
STORAGE_ACCOUNT_NAME=
MNT_SHARE_NAME=
MNT_SHARE_DIR=
STORAGE_ACCESS_KEY=
SSL_CERT=
SSL_KEY=
STUN_IP_ADDRESS=

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
        --ssl-key)
            SSL_KEY="$2"
            shift
            ;;
        --ssl-cert)
            SSL_CERT="$2"
            shift
            ;;
         --stun-ip-address)
            STUN_IP_ADDRESS="$2"
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
require_opt "$SSL_KEY" "--ssl-key"
require_opt "$SSL_CERT" "--ssl-cert"
require_opt "$STUN_IP_ADDRESS" "--stun-ip-address"

chmod +x ./set-env-0.1.py
echo "$ENV" | python ./set-env-0.1.py -o /var/www/recording-api/source/.env

chmod +x ./afs-utils-0.1.sh
bash ./afs-utils-0.1.sh -a "$STORAGE_ACCOUNT_NAME" -p -c -s "$MNT_SHARE_NAME" -b "$MNT_SHARE_DIR" -k  "$STORAGE_ACCESS_KEY"

service pm2-init.sh restart

bashrc="/home/azureuser/.bashrc"
sudo_alias="alias sudo='sudo '"
if ! grep -Fxq "$sudo_alias" "$bashrc";
then
    log "Adding alias for sudo, pm2 support"
    echo "$sudo_alias" >> "$bashrc"
fi

pm2_alias="alias pm2='HOME=/root PM2_HOME=/root/.pm2 pm2'"
if ! grep -Fxq "$pm2_alias" "$bashrc";
then
    log "Adding alias for pm2"
    echo "$pm2_alias" >> "$bashrc"
fi


echo "
user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 768;
    # multi_accept on;
}

http {
    ##
    # SSL
    ##
    ssl_session_cache    shared:SSL:10m;
    ssl_session_timeout    10m;

    ##
    # Basic Settings
    ##

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    # server_tokens off;

    # server_names_hash_bucket_size 64;
    # server_name_in_redirect off;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    ##
    # Logging Settings
    ##

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    ##
    # Gzip Settings
    ##

    gzip on;
    gzip_disable \"msie6\";

    # gzip_vary on;
    # gzip_proxied any;
    # gzip_comp_level 6;
    # gzip_buffers 16 8k;
    # gzip_http_version 1.1;
    # gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

    ##
    # nginx-naxsi config
    ##
    # Uncomment it if you installed nginx-naxsi
    ##

    #include /etc/nginx/naxsi_core.rules;


    ##
    # Virtual Host Configs
    ##

    include /etc/nginx/sites-enabled/*;
}
" > "/etc/nginx/nginx.conf"

echo "
    server {
    listen 443 ssl;
    keepalive_timeout	70;
    ssl_certificate		certs/collabramusic.com.chained.crt;
    ssl_certificate_key	certs/collabramusic.com.key;

    location / {
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \"upgrade\";
        proxy_set_header Host \$host:\$server_port;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_pass http://127.0.0.1:3000;
    }
}
" > "/etc/nginx/sites-enabled/recording-api"

mkdir -p /etc/nginx/certs

echo "$SSL_CERT" | openssl base64 -d -A > /etc/nginx/certs/collabramusic.com.chained.crt
echo "$SSL_KEY" | openssl base64 -d -A > /etc/nginx/certs/collabramusic.com.key

echo "
stunServerAddress=$STUN_IP_ADDRESS
stunServerPort=3478
" > /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini

nginx -s reload
log "Nginx reloaded configuration"
