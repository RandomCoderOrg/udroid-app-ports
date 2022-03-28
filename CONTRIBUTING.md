# Contribution Guidelines
######  VERSION: <kbd>v1.0</kdb>

### Adding new app port
for adding a new app port
- make sure to name folder as code name of app
	- ex: Visual Studio Code name is `code` so folder name becomes code
- An app port folder should contains only the following files
	-	`install.sh` ( for installation of app ( include permanent download link ) )
	-	fix.sh [optional] ( for any fix need to be done after installation  )
	-	README.txt ( for brief description about app & fix )
	-	License ( if fix/install/app is licensed by another user )

### Coding
for every fix make sure to add use this functions
```bash
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
```
for better look 
- use tab of `4` spaces
- format code before pusing
- add comment for readers
