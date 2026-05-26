#!/bin/bash

# ==================================================
#  CLOUDFLARE COMMANDER v3.1 (Smooth Edition)
# ==================================================

# --- THEME & COLORS ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' 

# --- HELPER FUNCTIONS ---

show_header() {
    clear
    local s_status="${GRAY}NOT INSTALLED${NC}"
    local s_pid="${GRAY}---${NC}"
    local s_uptime="${GRAY}---${NC}"
    local arch=$(dpkg --print-architecture 2>/dev/null || uname -m)

    if command -v cloudflared &>/dev/null; then
        if systemctl is-active --quiet cloudflared; then
            s_status="${GREEN}ACTIVE (RUNNING)${NC}"
            s_pid="${WHITE}$(pgrep -x cloudflared)${NC}"
            s_uptime="$(systemctl show -p ActiveEnterTimestamp cloudflared | cut -d'=' -f2 | cut -d' ' -f2-3)"
        else
            s_status="${RED}INACTIVE (STOPPED)${NC}"
        fi
    fi

    # UI Banner - Smooth Corners
    echo -e "${PURPLE} ╭────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${PURPLE} │${NC}              ${WHITE}CLOUDFLARED TUNNEL MANAGER${NC}                  ${PURPLE}│${NC}"
    echo -e "${PURPLE} │${NC}                 ${GRAY}v3.1 | Premium Edition${NC}                   ${PURPLE}│${NC}"
    echo -e "${PURPLE} ╰────────────────────────────────────────────────────────────╯${NC}"
    echo ""
    
    echo -e "${CYAN}  SYSTEM STATUS ${GRAY}───────────────────────────────────────────${NC}"
    echo -e "  ${GRAY}●${NC} Architecture : ${WHITE}$arch${NC}"
    echo -e "  ${GRAY}●${NC} Service Stat : $s_status"
    echo -e "  ${GRAY}●${NC} Process ID   : $s_pid"
    echo -e "  ${GRAY}●${NC} Last Started : ${CYAN}$s_uptime${NC}"
    echo -e "${GRAY} ────────────────────────────────────────────────────────────${NC}"
    echo ""
}

step_msg() { echo -e "  ${CYAN}[INFO]${NC} $1..."; }
success_msg() { echo -e "  ${GREEN}[DONE]${NC} $1"; }
error_msg() { echo -e "  ${RED}[FAIL]${NC} $1"; }

install_cf() {
    show_header
    echo -e "${WHITE}  STARTING INSTALLATION SEQUENCE${NC}"
    echo -e "${GRAY}  ────────────────────────────────${NC}"
    sleep 1

    step_msg "Configuring Cloudflare Repository"
    sudo mkdir -p --mode=0755 /usr/share/keyrings
    curl -fsSL https://cloudflare.com | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://cloudflare.com any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null
    success_msg "Repository Added"

    step_msg "Updating APT & Installing Binary"
    sudo apt-get update -qq >/dev/null
    sudo apt-get install -y cloudflared -qq >/dev/null 2>&1
    
    if ! command -v cloudflared &>/dev/null; then
        error_msg "Binary Installation Failed"
        read -p "Press Enter to return..."
        return
    fi
    success_msg "Cloudflared Binary Installed"

    if systemctl list-units --type=service | grep -q cloudflared; then
        step_msg "Removing conflicting services"
        sudo cloudflared service uninstall >/dev/null 2>&1
    fi

    echo ""
    echo -e "${YELLOW}  ╭────────────────────────────────────────────────────────╮${NC}"
    echo -e "${YELLOW}  │                    ACTION REQUIRED                     │${NC}"
    echo -e "${YELLOW}  │${NC} Paste your Tunnel Token below.                         ${YELLOW}│${NC}"
    echo -e "${YELLOW}  ╰────────────────────────────────────────────────────────╯${NC}"
    echo ""
    echo -ne "${PURPLE}  ➤ INPUT TOKEN:${NC} " 
    read USER_TOKEN

    # Aggressive Token Cleaning
    CLEAN_TOKEN=$(echo "$USER_TOKEN" | sed -E 's/.*service install //g' | tr -d '"' | tr -d "'" | xargs)

    if [[ -z "$CLEAN_TOKEN" ]]; then
        error_msg "Token cannot be empty!"
        read -p "Press Enter to return..."
        return
    fi

    step_msg "Registering Tunnel Service"
    sudo cloudflared service install "$CLEAN_TOKEN"
    
    echo -ne "\n  ${CYAN}Initializing: ${NC}"
    for i in {1..20}; do echo -ne "▓"; sleep 0.05; done
    echo -e "\n"
    
    if systemctl is-active --quiet cloudflared; then
        success_msg "Tunnel is Online & Stable!"
    else
        error_msg "Service failed to start. Check: journalctl -u cloudflared"
    fi

    read -p "  Press [Enter] to return..."
}

uninstall_cf() {
    show_header
    echo -e "${RED}  ╭────────────────────────────────────────────────────────╮${NC}"
    echo -e "${RED}  │                WARNING: DESTRUCTIVE ACTION             │${NC}"
    echo -e "${RED}  ╰────────────────────────────────────────────────────────╯${NC}"
    echo -ne "${RED}  Are you sure you want to remove everything? (y/N): ${NC}"
    read confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        step_msg "Stopping Service"
        sudo cloudflared service uninstall >/dev/null 2>&1
        step_msg "Removing Binary"
        sudo apt-get remove -y cloudflared -qq >/dev/null 2>&1
        sudo rm -f /etc/apt/sources.list.d/cloudflared.list /usr/share/keyrings/cloudflare-main.gpg
        success_msg "Cloudflared Completely Removed."
    else
        echo -e "\n  ${GRAY}Operation Cancelled.${NC}"
    fi
    sleep 2
}

while true; do
    show_header
    echo -e "  ${WHITE}AVAILABLE OPERATIONS:${NC}"
    echo -e "  ${GREEN}[1]${NC} Install or Update Tunnel    ${GRAY}(Auto-Fix)${NC}"
    echo -e "  ${RED}[2]${NC} Uninstall Completely        ${GRAY}(Remove All)${NC}"
    echo -e "  ${GRAY}[0]${NC} Exit Dashboard"
    echo ""
    echo -e "${PURPLE} ╰────────────────────────────────────────────────────────────╯${NC}"
    echo -ne "  ${PURPLE}root@cloudflared:~# ${NC}"
    read choice

    case $choice in
        1) install_cf ;;
        2) uninstall_cf ;;
        0) clear; exit ;;
        *) echo -e "  ${RED}Invalid Option${NC}"; sleep 1 ;;
    esac
done
