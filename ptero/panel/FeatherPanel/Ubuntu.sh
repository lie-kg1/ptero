#!/bin/bash

set -e

# ==============================
# SYSTEM UPDATE
# ==============================
apt update && apt upgrade -y

# ==============================
# DEPENDENCIES
# ==============================
apt install -y software-properties-common curl apt-transport-https ca-certificates gnupg lsb-release

# ==============================
# ADD PHP REPO
# ==============================
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
apt update

# ==============================
# ENABLE UNIVERSE
# ==============================
add-apt-repository -y universe
apt update

# ==============================
# INSTALL STACK (SAFE VERSION)
# ==============================

apt install -y \
php8.3 php8.3-cli php8.3-fpm php8.3-common \
php8.3-mysql php8.3-mbstring php8.3-bcmath \
php8.3-xml php8.3-curl php8.3-zip php8.3-gd \
php8.3-redis php8.3-pgsql \
mariadb-server nginx redis-server \
tar unzip zip git make dos2unix

# ==============================
# DONE
# ==============================
echo "✔ Installation complete"
php -v
