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
	curl -O -s -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/andrewmarklloyd/pi-plex/master/traefik/traefik.toml"
	curl -O -s -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/andrewmarklloyd/pi-plex/master/traefik/rules.toml"
	mv traefik.toml /mnt/hdd/docker/traefik/
	mv rules.toml /mnt/hdd/docker/traefik/
	touch /mnt/hdd/docker/traefik/acme/acme.json
	chmod 600 /mnt/hdd/docker/traefik/acme/acme.json
}

start_application() {
	docker-compose up -d
}

configure_drive() {
	echo "Must be formatted as ext4. Press enter to continue"
	read
	echo "Identify the name of the disk partition:"
	sudo lsblk -o UUID,NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL,MODEL
	echo "Getting the location of the disk partition"
	sudo blkid
	echo "Creating target directory"
	sudo mkdir /mnt/hdd
	echo "Mounting the storage device"
	sudo mount /dev/sda2 /mnt/hdd
	echo "Verify the mount was successful"
	df -h /mnt/hdd

	echo "Taken from raspberrypi.org. For more see https://www.raspberrypi.org/documentation/configuration/external-storage.md"
}

unmount_device() {
	sudo umount /mnt/hdd
}

configure_applications() {
	echo "TODO"
	# setup jackett indexer
	echo "use torrentz as indexer"
	# configure transmission-vpn
	# configure sonarr to use jackett
	echo "add jacket:9117 url as indexer"
	echo "add transmission-vpn as the download client"
	echo "add remote path mapping: transmission-vpn /data/completed/ /downloads/Torrents/complete/"
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
	start_application
	rm install.sh
	configure_applications
fi
