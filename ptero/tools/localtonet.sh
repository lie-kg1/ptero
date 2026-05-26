#!/bin/bash

# ==================================================
#  LOCALTONET AUTO-RUN PRO v2.0
# ==================================================

# --- COLORS ---
R='\033[1;31m'; G='\033[1;32m'; Y='\033[1;33m'; B='\033[1;34m'
M='\033[1;35m'; C='\033[1;36m'; W='\033[1;37m'; GR='\033[0;90m'; NC='\033[0m'

# --- UI HEADER ---
clear
echo -e "${C}╭──────────────────────────────────────────────────╮${NC}"
echo -e "${C}│${M}          LOCALTONET AUTO-RUN PRO v2.0            ${C}│${NC}"
echo -e "${C}╰──────────────────────────────────────────────────╯${NC}"

# 1. Install Check
echo -e " ${B}[*] Checking system requirements...${NC}"
if ! command -v localtonet &> /dev/null; then
    echo -e " ${Y}[!] Localtonet not found. Installing...${NC}"
    curl -fsSL https://localtonet.com/install.sh | sh
    echo -e " ${G}[✓] Installation Complete!${NC}"
else
    echo -e " ${G}[✓] Localtonet is ready.${NC}"
fi

echo -e "${GR} ──────────────────────────────────────────────────${NC}"

# 2. Input Section
echo -e " ${W}ENTER CONFIGURATION:${NC}"
echo -en " ${C}➤ Auth-Token : ${NC}"
read USER_TOKEN

# Validation
if [ -z "$USER_TOKEN" ]; then
    echo -e " ${R}✘ Error: Token missing!${NC}"
    exit 1
fi

echo -en " ${C}➤ Local Port : ${NC}"
read PORT
PORT=${PORT:-8080} # Default to 8080 if empty

# 3. Setting Token
echo -e "\n ${B}[*] Applying Authentication...${NC}"
localtonet authtoken "$USER_TOKEN" > /dev/null 2>&1
echo -e " ${G}[✓] Token Saved!${NC}"

# 4. Final Launch
echo -e "${GR} ──────────────────────────────────────────────────${NC}"
echo -e " ${M}🚀 Launching Tunnel on Port ${W}${PORT}${M}...${NC}"
echo -e " ${B}Press CTRL+C to stop the tunnel.${NC}"
echo -e "${C}╰──────────────────────────────────────────────────╯${NC}"

# Start Localtonet
localtonet -p "$PORT"
