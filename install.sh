#!/bin/bash


update() {
	sudo apt-get update -y
	sudo apt-get upgrade -y
}

install_docker() {
	curl -fsSL https://get.docker.com -o get-docker.sh
	sudo sh get-docker.sh
	sudo usermod -aG docker pi
	# TODO: Need to update group so we don't have to logout and login. May not be possible if we removed the user's password though
	echo "Please logout and login so the docker user group update is applied."
}

install_docker_compose() {
	sudo apt-get install python3-pip -y
	sudo pip3 install docker-compose
	docker network create traefik_proxy
}

create_env_file() {
	curl -O -s -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/andrewmarklloyd/pi-plex/master/.env.tmpl"
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
	rm .env.tmpl
}

install_application() {
	curl -O -s -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/andrewmarklloyd/pi-plex/master/docker-compose.yml"
	docker-compose up -d
}

configure_applications() {
	echo "TODO"
	# setup jackett indexer
	# configure transmission-vpn
	# configure sonarr to use jackett
	# configure sonarr to use transmission download client
	# configure sonarr to use remote path mappings (if applicable)
	# configure radarr to use jackett
	# configure radarr to use transmission download client
	# configure radarr to use remote path mappings (if applicable)
	# configure plex to use media directory
}


if [[ ! -f get-docker.sh ]]; then
	update
	install_docker
else
	rm -f get-docker.sh
	install_docker_compose
	create_env_file
	install_application
	rm install.sh
	configure_applications
fi
