#!/bin/bash

BOLD="\e[1m"
RST="\e[0m"

INFO() {
	echo
	echo -e ": $*"
	sleep 1
}

INFO "Installing ${BOLD}Firefox${RST}...}"
# trigger normal installation to resolve all dependencies (fonts)
apt-get install -y firefox

# remove firefox snap and install firefox from ppa for debian package
INFO "Removing ${BOLD}Firefox${RST} snap...}"
rm -rf /etc/apt/preferences.d/fire*
apt remove firefox* -y
apt update && apt install firefox software-properties-common -y

INFO "Adding ${BOLD}Firefox${RST} ${BOLD}PPA${RST}...}"
add-apt-repository --yes ppa:mozillateam/ppa

# add preferences to pin firefox package from ppa
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' | sudo tee /etc/apt/preferences.d/mozilla-firefox

echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox

INFO "Installing ${BOLD}Firefox${RST} from ${BOLD}PPA${RST}...}"
apt update
apt remove firefox -y
apt install firefox -y
