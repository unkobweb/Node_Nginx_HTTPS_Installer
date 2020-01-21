#!/bin/bash

sudo apt-get install curl software-properties-common
curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
sudo apt-get install nodejs
sudo npm i -g pm2
sudo apt-get install nginx
sudo apt-get install git

read -p 'Entrez votre nom de domaine : ' domaine
cd /etc/nginx/sites-available
if [ -e /etc/nginx/sites-available/$domaine ]
then
    rm /etc/nginx/sites-available/$domaine
fi

touch "$domaine"

read -p 'Indiquez le port sur lequel votre serveur fonctionne : ' port

upstream="${domaine//.}"

echo -e "# Installed by Node Nginx HTTPS Installer\n# Created by Kobweb\n\nupstream $upstream {\n\tserver localhost:$port;\n}\n\nserver {\n\n\tlisten 80;\n\tlisten [::]:80;\n\tserver_name $domaine;\n\n\tlocation / {\n\t\tproxy_pass http://$upstream;\n\t}\n}" >> $domaine

nginx -t | echo

rm /etc/nginx/sites-enabled/$domaine
ln -s /etc/nginx/sites-available/$domaine /etc/nginx/sites-enabled/$domaine

cd /var/www/

read -p 'Indiquez le git de votre projet web : ' gitpath

IFS='/' read -r -a githash <<< "$gitpath"
hash="${githash[-1]}"
IFS='.' read -r -a gitbash <<< "$hash"
actual="${gitbash[0]}"

if [ -d /var/www/$actual ]
then
    rm -r /var/www/$actual
fi

git clone $gitpath

cd /var/www/$actual

sudo npm install

read -p 'Indiquez le nom du fichier qui gère votre serveur nodejs : ' jsname
pm2 start /var/www/$actual/$jsname

service nginx restart

sudo apt-get install certbot python-certbot-nginx
certbot --nginx

nginx -t | echo

service nginx restart