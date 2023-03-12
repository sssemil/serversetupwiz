#!/bin/bash

set -e

# export DOMAIN
if [[ ! -v DOMAIN ]]; then
    echo "DOMAIN is not set"
    exit -1
elif [[ -z "$DOMAIN" ]]; then
    echo "DOMAIN is set to the empty string"
    exit -1
else
    echo "DOMAIN has the value: $DOMAIN"
fi


apt-get update
apt-get upgrade -y
apt-get install -y ufw nginx

ufw app list
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 'Nginx Full'
ufw enable
ufw app status 

snap install core
snap refresh core 
apt-get remove certbot
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

mkdir -p /var/www/$DOMAIN/html
chown -R $USER:$USER /var/www/$DOMAIN/html
chmod -R 755 /var/www/$DOMAIN
echo "Welcome to $DOMAIN!" > /var/www/$DOMAIN/html/index.html
tee -a /etc/nginx/sites-available/$DOMAIN >/dev/null <<-EOF
server {
	listen 80;
	listen [::]:80;

	root /var/www/$DOMAIN/html;
	index index.html index.htm index.nginx-debian.html;

	server_name $DOMAIN www.$DOMAIN;

	location / {
			try_files $uri $uri/ =404;
	}
}
EOF
ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
sed -i '/server_names_hash_bucket_size/s/^/#/g' /etc/nginx/nginx.conf

nginx -t
systemctl status nginx
systemctl enable nginx
systemctl restart nginx

certbot --nginx -d $DOMAIN -d www.$DOMAIN
systemctl status snap.certbot.renew.service  
certbot renew --dry-run
