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

_download() {

    if [ "$(id -u)" != 0 ]; then
        if command -v sudo >>/dev/null 2>&1; then
            SUDO="sudo"
        fi
    fi

    if ! command -v wget >>/dev/null; then
        $SUDO apt install wget
    fi

    # from https://stackoverflow.com/questions/4686464/how-to-show-wget-progress-bar-only

    function progressfilt() {
        local flag=false c count cr=$'\r' nl=$'\n'
        while IFS='' read -d '' -rn 1 c; do
            if $flag; then
                printf '%s' "$c"
            else
                if [[ $c != "$cr" && $c != "$nl" ]]; then
                    count=0
                else
                    ((count++))
                    if ((count > 1)); then
                        flag=true
                    fi
                fi
            fi
        done
    }
    function cleanup() {
        echo -e "\ncleaning up..."
        rm -rvf "$(basename "$1")"*
    }
    trap 'cleanup $1; exit 1;' HUP INT TERM

    wget --progress=bar:force "$1" 2>&1 | progressfilt || {
        cleanup "$1"
        exit 1
        :
    }
}
########## APP ###########
URLPREFIX="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-"

case $(uname -m) in
*armv7l* | *armv8l*)
    URL="armhf"
    ;;
*aarch64* | *arm64*)
    URL="arm64"
    ;;
x86_64)
    URL="x64"
    ;;
esac

link="$URLPREFIX$URL"
if ((UID != 0)); then
    echo "Please run as root"
    exit 1
fi

shout "Downloading VSCODE..."
_download   "$link"
shout "Trying to install VSCODE... [ file: $(basename "${URLPREFIX}${URL}") ]"
dpkg -i     "$link" || die "Failed to install VSCODE"
shout "Fixing for root user.."
sed -i 's/--unity-launch/--no-sandbox --user-data-dir=vscocderoot --unity-launch/' /usr/share/applications/code.desktop || die "Failed to fix for root user"
cat << EOF > /usr/bin/code-root
#!/bin/bash
code --user-data-dir=vscocderoot --unity-launch --no-sandbox "\$@"
EOF
msg "Done"
msg "Now you can start using Visual Studio Code with the command 'code-root'"