#! /usr/bin/env bash

# Stop on error
set -e

export DEBIAN_FRONTEND="noninteractive"

apt_wait () {
    while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
        echo "Waiting: dpkg/lock is locked..."
        sleep 5
    done

    while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 ; do
        echo "Waiting: dpkg/lock-frontend is locked..."
        sleep 5
    done

    while fuser /var/lib/apt/lists/lock >/dev/null 2>&1 ; do
        echo "Waiting: lists/lock is locked..."
        sleep 5
    done

    if [ -f /var/log/unattended-upgrades/unattended-upgrades.log ]; then
        while fuser /var/log/unattended-upgrades/unattended-upgrades.log >/dev/null 2>&1 ; do
            echo "Waiting: unattended-upgrades is locked..."
            sleep 5
        done
    fi
}

echo "Checking apt-get availability..."

apt_wait

sudo sed -i "s/#precedence ::ffff:0:0\/96  100/precedence ::ffff:0:0\/96  100/" /etc/gai.conf

# Configure Swap Disk
if [ -f /swapfile ]; then
    echo "Swap exists."
else
    sudo dd if=/dev/zero of=/swapfile bs=128M count=8
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
    echo "vm.swappiness=30" | sudo tee -a /etc/sysctl.conf
    echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf
fi

# Upgrade The Base Packages
export DEBIAN_FRONTEND="noninteractive"

sudo apt-get update
apt_wait
sudo apt-get upgrade -y
apt_wait

# Add A Few PPAs To Stay Current
sudo apt-get install -y --force-yes software-properties-common

# Update Package Lists
apt_wait
sudo apt-get update

# Base Packages
apt_wait
sudo add-apt-repository universe
sudo apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes build-essential curl pkg-config fail2ban gcc g++ libmcrypt4 libpcre3-dev \
make python3 python3-pip ufw zip unzip whois ncdu uuid-runtime acl libpng-dev libmagickwand-dev wget

# Install Python Httpie
sudo pip3 install httpie

# Install AWS CLI
sudo pip3 install awscli
sudo pip3 install awscli-plugin-endpoint

# Set The Timezone
sudo ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Disable protected_regular
sudo sed -i "s/fs.protected_regular = .*/fs.protected_regular = 0/" /usr/lib/sysctl.d/protect-links.conf

sysctl --system

# Setup Unattended Security Upgrades
apt_wait
sudo apt-get install -y --force-yes unattended-upgrades

sudo mv /tmp/10periodic /etc/apt/apt.conf.d/10periodic
sudo mv /tmp/50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades

sudo timedatectl set-timezone America/New_York

