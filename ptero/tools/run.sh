#!/bin/bash

# ==================================================
#  SERVER UTILITY MENU | v2.1 (FIXED)
# ==================================================

# --- COLORS ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[1;30m'
NC='\033[0m'

# --- BRANDING FIX (FORCE NAME) ---
HOST="liekgCloud"
USER=$(whoami)

# --- HELPER ---
pause() {
    echo ""
    read -n 1 -s -r -p "Press any key to continue..."
    echo ""
}

# --- SAFE RUNNER ---
run() {
    local url="$1"

    echo -e "\n${YELLOW}Running script...${NC}"

    if ! bash <(curl -fsSL "$url"); then
        echo -e "${RED}Failed to run script${NC}"
    fi
}

# ===================== MENU =====================
tools_menu() {
    while true; do
        clear

        echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}║${NC}      ${PURPLE}⚡ SERVER UTILITIES & TOOLS ⚡${NC}                    ${CYAN}║${NC}"
        echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
        echo -e "${GRAY}  Host: ${HOST} | User: ${USER}${NC}"
        echo ""

        echo -e "${BLUE}  [ ACCESS & NETWORK ]${NC}"
        echo -e "  ${GREEN}1)${NC} Root Access"
        echo -e "  ${GREEN}2)${NC} Tailscale"
        echo -e "  ${GREEN}3)${NC} Zerotier"
        echo -e "  ${GREEN}4)${NC} Cloudflare DNS"
        echo ""

        echo -e "${YELLOW}  [ SYSTEM OPERATIONS ]${NC}"
        echo -e "  ${GREEN}5)${NC} System Info"
        echo -e "  ${GREEN}6)${NC} Port Forward"
        echo ""

        echo -e "${PURPLE}  [ GUI & TERMINAL ]${NC}"
        echo -e "  ${GREEN}7)${NC} Web Terminal"
        echo -e "  ${GREEN}8)${NC} RDP Installer"
        echo -e "  ${GREEN}9)${NC} SSL Panel"
        echo ""

        echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
        echo -e "  ${RED}0) Exit${NC}"
        echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"

        echo ""
        echo -ne "${CYAN}Select Tool → ${NC}"
        read t

        case $t in
            1)
                run "https://raw.githubusercontent.com/lie-kg1/ptero/refs/heads/main/ptero/tools/root.sh"
                pause
                ;;
            2)
                run "https://raw.githubusercontent.com/lie-kg1/ptero/refs/heads/main/ptero/tools/tailscale.sh"
                pause
                ;;
            3)
                run "https://raw.githubusercontent.com/lie-kg1/ptero/refs/heads/main/ptero/tools/zerotier.sh"
                pause
                ;;
            4)
                run "https://raw.githubusercontent.com/lie-kg1/ptero/refs/heads/main/ptero/tools/cloudflare.sh"
                pause
                ;;
            5)
                run "https://raw.githubusercontent.com/lie-kg1/ptero/refs/heads/main/ptero/tools/info.sh"
                pause
                ;;
            6)
                run "https://raw.githubusercontent.com/lie-kg1/ptero/refs/heads/main/ptero/tools/localtonet.sh"
                pause
                ;;
            7)
                run "https://raw.githubusercontent.com/lie-kg1/ptero/refs/heads/main/ptero/tools/terminal.sh"
                pause
                ;;
            8)
                run "https://raw.githubusercontent.com/lie-kg1/lie-kg-Hub/refs/heads/main/srv/tools/rdp.sh"
                pause
                ;;
            9)
                run "https://raw.githubusercontent.com/lie-kg1/hub/refs/heads/main/liekgCloud/toolbox/mengssl.sh"
                pause
                ;;
            0)
                echo -e "${GREEN}Goodbye 👋${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid Option${NC}"
                sleep 1
                ;;
        esac
    done
}

# --- START ---
tools_menu
