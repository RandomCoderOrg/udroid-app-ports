#!/usr/bin/env bash

_c_magneta="\e[95m"
_c_green="\e[32m"
_c_red="\e[31m"
_c_blue="\e[34m"
RST="\e[0m"

die()    { echo -e "${_c_red}[E] ${*}${RST}";exit 1;:;}
warn()   { echo -e "${_c_red}[W] ${*}${RST}";:;}
shout()  { echo -e "${_c_blue}[-] ${*}${RST}";:;}
lshout() { echo -e "${_c_blue}-> ${*}${RST}";:;}
msg()    { echo -e "${*} \e[0m" >&2;:;}

### Firefox
packages="firefox"
package="firefox"

# check is script running as root
if [ $(id -u) != 0 ]; then
	lshout "Please run this script as root.."
	die "Try: sudo ${0}"
fi

# remove old ubuntu packages
shout "Trying to remove ubuntu $package packages.."
apt remove --purge -y $packages
apt autoremove -y

# Add debian package repo as debian.list
shout "Adding debain sources..."
cat <<- EOF > /etc/apt/sources.list.d/debian.list
deb http://deb.debian.org/debian buster main
deb http://deb.debian.org/debian buster-updates main
deb http://deb.debian.org/debian-security buster/updates main
EOF

lshout "Added debain.list"
shout "Adding Debian keys.."
keys="DCC9EFBF77E11517 648ACFD622F3D138 AA8E81B4331F7F50 112695A0E562B32A"
for key in $keys; do
	lshout "Adding $key"
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $key || {
		die "Failed to add key $key.."
	}
done

shout "Adding $package package preferences.."
cat << EOF > /etc/apt/preferences.d/$package.pref
# Note: 2 blank lines are required between entries
Package: *
Pin: release a=eoan
Pin-Priority: 500

Package: *
Pin: origin "deb.debian.org"
Pin-Priority: 300

Package: $package*
Pin: origin "deb.debian.org"
Pin-Priority: 700
EOF
lshout "Done.. [/etc/apt/preferences.d/$package.pref]"

shout "upgrading apt indexes"
lshout "${_c_green}apt-get clean"
apt-get clean || lwarn "Failed to clean old indexes.."
lshout "${_c_green}apt-get update"
apt-get update || die "Failed to update package indexes.."

shout "Installing $package.."
apt-get install $package -y || die "Failed to install $package"

shout "Installation done."
