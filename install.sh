#!/bin/bash


sudo apt-get update -y
sudo apt-get upgrade -y
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh
sudo usermod -aG docker pi
sudo usermod -aG docker pi
sudo newgrp docker
sudo pip3 install docker-compose
docker network create traefik_proxy

echo 'Enter the FQDN for the application.'
read FQDN
echo 'Enter the OpenVPN provider.'
read vpnProvider
echo 'Enter the OpenVPN username.'
read -s vpnUsername
echo 'Enter the OpenVPN password.'
read -s vpnPassword

sed "s/{{.FQDN}}/${FQDN}/" .env.tmpl \
	| sed "s/{{.VPN.Provider}}/${vpnProvider}/" \
	| sed "s/{{.VPN.Username}}/${vpnUsername}/" \
	| sed "s/{{.VPN.Password}}/${vpnPassword}/" > .env

docker-compose up -d