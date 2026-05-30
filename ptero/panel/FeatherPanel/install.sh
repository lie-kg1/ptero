#!/bin/bash

# ==================================================
# FEATHERPANEL INSTALLER MODE (FIXED + STABLE)
# ==================================================

set -e

# ---------------- COLORS ----------------
C_RESET="\e[0m"
C_RED="\e[1;31m"
C_GREEN="\e[1;32m"
C_YELLOW="\e[1;33m"
C_BLUE="\e[1;34m"
C_CYAN="\e[1;36m"
C_GRAY="\e[1;90m"

line(){ echo -e "${C_GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"; }
step(){ echo -e "${C_BLUE}➜ $1${C_RESET}"; }
ok(){ echo -e "${C_GREEN}✔ $1${C_RESET}"; }
fail(){ echo -e "${C_RED}✘ $1${C_RESET}"; }

clear

# ---------------- BANNER ----------------
echo -e "${C_CYAN}"
cat << "EOF"
 ███████████  FEATHERPANEL INSTALLER  ███████████
EOF
echo -e "${C_RESET}"

line

# ---------------- OS DETECT ----------------
. /etc/os-release
OS=$ID
CODENAME=$VERSION_CODENAME

echo -e "${C_GREEN}🧠 OS: $OS ($CODENAME)${C_RESET}"
line

# ---------------- DOMAIN ----------------
read -p "🌐 Enter domain: " DOMAIN

if [[ -z "$DOMAIN" ]]; then
  fail "Domain required"
  exit 1
fi

line

# ---------------- BASE INSTALL ----------------
step "Installing base system..."

if [[ "$OS" == "ubuntu" ]]; then
   bash <(curl -fsSL https://raw.githubusercontent.com/lie-kg/ptero/main/ptero/panel/FeatherPanel/Ubuntu.sh)
elif [[ "$OS" == "debian" ]]; then
   bash <(curl -fsSL https://raw.githubusercontent.com/lie-kg/ptero/main/ptero/panel/FeatherPanel/Debian.sh)
else
   fail "Unsupported OS"
   exit 1
fi

ok "Base installed"

line

# ---------------- DEPENDENCIES ----------------
step "Installing dependencies..."

apt update -y
apt install -y curl wget git unzip mariadb-server nginx php php-fpm openssl

# Node FIX (no npm conflict issues)
step "Installing Node.js (clean method)..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

ok "Dependencies installed"

line

# ---------------- COMPOSER ----------------
step "Composer install..."

curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ok "Composer installed"

line

# ---------------- PANEL PATH ----------------
APP_DIR="/var/www/featherpanel"

rm -rf "$APP_DIR"
mkdir -p /var/www

step "Cloning panel..."

git clone https://github.com/mythicalltd/featherpanel.git "$APP_DIR" || {
  fail "Git clone failed"
  exit 1
}

ok "Panel downloaded"

line

# ---------------- BACKEND ----------------
step "Backend setup..."

cd "$APP_DIR/backend" || exit 1

if [[ -f "composer.json" ]]; then
  COMPOSER_ALLOW_SUPERUSER=1 composer install
  ok "Backend ready"
else
  fail "composer.json missing"
  exit 1
fi

line

# ---------------- FRONTEND ----------------
step "Frontend build..."

cd "$APP_DIR/frontend" || exit 1

npm install
npm run build

ok "Frontend built"

line

# ---------------- DATABASE ----------------
step "Database setup..."

DB_NAME="featherpanel"
DB_USER="featherpanel"
DB_PASS="1234"

mariadb -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
mariadb -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
mariadb -e "FLUSH PRIVILEGES;"

ok "Database ready"

line

# ---------------- SSL ----------------
step "SSL creation..."

mkdir -p /etc/certs/featherpanel

openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
-subj "/C=NA/ST=NA/L=NA/O=FeatherPanel/CN=${DOMAIN}" \
-keyout /etc/certs/featherpanel/privkey.pem \
-out /etc/certs/featherpanel/fullchain.pem

ok "SSL created"

line

# ---------------- NGINX ----------------
step "Nginx config..."

rm -f /etc/nginx/sites-enabled/default

cat <<EOF > /etc/nginx/sites-available/featherpanel.conf
server {
    listen 80;
    server_name ${DOMAIN};
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${DOMAIN};

    root /var/www/featherpanel/frontend/dist;
    index index.html;

    ssl_certificate /etc/certs/featherpanel/fullchain.pem;
    ssl_certificate_key /etc/certs/featherpanel/privkey.pem;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location /api {
        proxy_pass http://127.0.0.1:8721;
    }
}
EOF

ln -sf /etc/nginx/sites-available/featherpanel.conf /etc/nginx/sites-enabled/

nginx -t && systemctl restart nginx

ok "Nginx ready"

line

# ---------------- FINISH ----------------
echo -e "${C_GREEN}"
echo "=============================================="
echo "        FEATHERPANEL INSTALL COMPLETE        "
echo "=============================================="
echo -e "${C_RESET}"

echo "🌐 https://${DOMAIN}"
echo "✔ DONE"
