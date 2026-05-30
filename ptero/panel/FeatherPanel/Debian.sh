#!/bin/bash

set -e

echo "======================================"
echo "  SERVER SETUP (FIXED & STABLE)"
echo "======================================"

# ---------------- UPDATE SYSTEM ----------------
apt update && apt upgrade -y

# ---------------- BASE PACKAGES ----------------
apt install -y software-properties-common curl ca-certificates gnupg2 sudo lsb-release make

# ---------------- ADD SURY PHP REPO ----------------
echo "Adding PHP repository..."

curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /usr/share/keyrings/sury-php.gpg

echo "deb [signed-by=/usr/share/keyrings/sury-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" \
| tee /etc/apt/sources.list.d/sury-php.list

apt update

# ---------------- PHP INSTALL (SAFE VERSION) ----------------
# PHP 8.3 is stable and supported (NOT 8.5)
apt install -y \
php8.3 php8.3-cli php8.3-fpm php8.3-common \
php8.3-mysql php8.3-mbstring php8.3-bcmath \
php8.3-xml php8.3-curl php8.3-zip php8.3-gd \
php8.3-redis php8.3-pgsql

# ---------------- MARIADB ----------------
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | bash

apt update

apt install -y mariadb-server nginx redis-server \
tar unzip git zip dos2unix

# ---------------- DONE ----------------
echo "======================================"
echo "✔ SERVER INSTALL COMPLETE"
echo "======================================"
php -v
