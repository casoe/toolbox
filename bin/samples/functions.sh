#!/bin/bash
# conf-library.sh
# Carsten Söhrens, 18.10.2017

# set -x

LIBRARY=~/conf-library
USER=`whoami`
GROUP=$USER

# function define

confirm() {
    if [ "$FORCE" == '-y' ]; then
        true
    else
        read -r -p "$1 [y/N] " response < /dev/tty
        if [[ $response =~ ^(yes|y|Y)$ ]]; then
            true
        else
            false
        fi
    fi
}

prompt() {
        read -r -p "$1 [y/N] " response < /dev/tty
        if [[ $response =~ ^(yes|y|Y)$ ]]; then
            true
        else
            false
        fi
}

success() {
    echo -e "$(tput setaf 2)$1$(tput sgr0)"
}

inform() {
    echo -e "$(tput setaf 6)$1$(tput sgr0)"
}

warning() {
    echo -e "$(tput setaf 1)$1$(tput sgr0)"
}

newline() {
    echo ""
}

progress() {
    count=0
    until [ $count -eq 7 ]; do
        echo -n "..." && sleep 1
        ((count++))
    done;
    if ps -C $1 > /dev/null; then
        echo -en "\r\e[K" && progress $1
    fi
}

sudocheck() {
    if [ $(id -u) -ne 0 ]; then
        echo -e "Install must be run as root. Try 'sudo ./$scriptname'\n"
        exit 1
    fi
}

sysclean() {
    sudo apt-get clean && sudo apt-get autoclean
    sudo apt-get -y autoremove &> /dev/null
}

sysupdate() {
    if ! $UPDATE_DB; then
        echo "Updating apt indexes..." && progress apt-get &
        sudo apt-get update 1> /dev/null || { warning "Apt failed to update indexes!" && exit 1; }
        sleep 3 && UPDATE_DB=true
    fi
}

sysupgrade() {
    sudo apt-get upgrade
    sudo apt-get clean && sudo apt-get autoclean
    sudo apt-get -y autoremove &> /dev/null
}

timestamp() {
    date +%Y%m%d-%H%M
}

check_network() {
    sudo ping -q -w 10 -c 1 8.8.8.8 | grep "received, 0" &> /dev/null && return 0 || return 1
}

apt_pkg_req() {
    APT_CHK=$(dpkg-query -W -f='${Status}\n' "$1" 2> /dev/null | grep "install ok installed")

    if [ "" == "$APT_CHK" ]; then
        echo "$1 is required"
        true
    else
        echo "$1 is already installed"
        false
    fi
}

apt_pkg_install() {
    echo "Installing $1..."
    sudo apt-get --yes install "$1" 1> /dev/null || { inform "Apt failed to install $1!\nFalling back on pypi..." && return 1; }
}

apt_deb_chk() {
    BEFORE=$(dpkg-query -W "$1" 2> /dev/null)
    sudo apt-get --yes install "$1" &> /dev/null || return 1
    AFTER=$(dpkg-query -W "$1" 2> /dev/null)
    if [ "$BEFORE" == "$AFTER" ]; then
        echo "$1 is already the newest version"
    else
        echo "$1 was successfully upgraded"
    fi
}

apt_deb_install() {
    echo "Installing $1..."
    if [[ "$1" != *".deb"* ]]; then
        sudo apt-get --yes install "$1" &> /dev/null || inform "Apt failed to install $1!\nFalling back on pypi..."
        dpkg-query -W -f='${Status}\n' "$1" 2> /dev/null | grep "install ok installed"
    else
        DEBDIR=`mktemp -d /tmp/pimoroni.XXXXXX`
        cd $DEBDIR
        wget "$GETPOOL/resources/$1" &> /dev/null
        sudo dpkg -i "$DEBDIR/$1" | grep "Installing $1"
    fi
}

# main

if ! check_network; then
	warning "We can't connect to the Internet, check your network!" && exit 1
fi

sysupdate

if apt_pkg_req "apt-utils" &> /dev/null; then
	apt_pkg_install "apt-utils"
fi

if apt_pkg_req "git" &> /dev/null; then
	apt_pkg_install "git"
fi

mkdir -p $LIBRARY

for FILE in $(cat $LIBRARY/conf-inventory)
do
	sudo cp -a $FILE $LIBRARY
done

sudo chown $USER.$GROUP $LIBRARY/*
