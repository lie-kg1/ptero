#!/bin/bash

# ==================================================
#  OMNI-ADMIN v201 | TITAN EDITION (AUTO-FIXED)
# ==================================================

# --- THEME & COLORS ---
R="\e[1;31m"; G="\e[1;32m"; Y="\e[1;33m"; B="\e[1;34m"; M="\e[1;35m"; C="\e[1;36m"; W="\e[1;37m"; GR="\e[1;90m"; N="\e[0m"

# --- CONFIG ---
LOG_FILE="$HOME/omni_titan.log"
BACKUP_DIR="$HOME/omni_backups"
mkdir -p "$BACKUP_DIR"

# --- SMART AUTO-FIX INSTALLER ---
auto_install() {
    local PKG=$1
    if ! command -v "$PKG" &>/dev/null; then
        echo -ne "${Y} [AUTO-FIX] Missing tool: $PKG. Installing... ${N}"
        if [ -f /etc/debian_version ]; then
            sudo apt-get update -qq >/dev/null 2>&1
            sudo apt-get install -y -qq "$PKG" >/dev/null 2>&1
        elif [ -f /etc/redhat-release ]; then
            sudo yum install -y -q "$PKG" >/dev/null 2>&1
        elif [ -f /etc/arch-release ]; then
            sudo pacman -S --noconfirm "$PKG" >/dev/null 2>&1
        fi
    fi
}

pause() { 
    echo -e "\n${GR}────────────────────────────────────────${N}"
    read -p " ↩ Press Enter to return..." _ 
}

# --- HEADER UI ---
draw_header() {
    clear
    CPU=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    RAM=$(free -m | awk '/Mem/ {printf "%.1f", $3/$2*100}')
    
    echo -e "${C} ╭─────────────────────────────────────────────────────────────╮${N}"
    echo -e "${C} │${W}  OMNI-ADMIN v201 ${GR}|${Y} TITAN EDITION ${GR}|${M} $(whoami)@$(hostname) ${C}│${N}"
    echo -e "${C} ├─────────────────────────────────────────────────────────────┤${N}"
    echo -e "${C} │${GR}  CPU: ${G}${CPU}%${GR}  │  RAM: ${G}${RAM}%${GR}  │  KERNEL: ${B}$(uname -r)${C}  │${N}"
    echo -e "${C} ╰─────────────────────────────────────────────────────────────╯${N}"
    echo ""
}

# ==================================================
#  CATEGORY 1: SYSTEM & HARDWARE
# ==================================================
menu_sys() {
    while true; do
        draw_header
        echo -e "${M} [ CATEGORY 1: SYSTEM & HARDWARE ]${N}"
        printf "${GR} 1.${W} %-25s ${GR}11.${W} %-25s\n" "OS Release Info" "PCI Devices"
        printf "${GR} 2.${W} %-25s ${GR}12.${W} %-25s\n" "Kernel Version" "USB Devices"
        printf "${GR} 3.${W} %-25s ${GR}13.${W} %-25s\n" "CPU Architecture" "Block Devices (lsblk)"
        printf "${GR} 4.${W} %-25s ${GR}14.${W} %-25s\n" "CPU Cores/Threads" "Disk Space (df)"
        printf "${GR} 5.${W} %-25s ${GR}15.${W} %-25s\n" "RAM Utilization" "Disk Inodes"
        printf "${GR} 6.${W} %-25s ${GR}16.${W} %-25s\n" "Uptime Detail" "Mount Points"
        printf "${GR} 7.${W} %-25s ${GR}17.${W} %-25s\n" "Load Average" "Hardware List (lshw)"
        printf "${GR} 8.${W} %-25s ${GR}18.${W} %-25s\n" "Hostname Info" "BIOS/Firmware Info"
        printf "${GR} 9.${W} %-25s ${GR}19.${W} %-25s\n" "System Date/Time" "Sensor Temps"
        printf "${GR}10.${W} %-25s ${GR}20.${W} %-25s\n" "Last Reboot Log" "Battery Status"
        echo -e "${R} 0. Back to Main Menu${N}"
        read -p " Select Tool > " opt
        
        case $opt in
            1) cat /etc/*release ;;
            2) uname -a ;;
            3) lscpu | grep Architecture ;;
            4) lscpu | grep -E '^Thread|^Core|^Socket' ;;
            5) free -h ;;
            6) uptime -p ;;
            7) uptime ;;
            8) hostnamectl ;;
            9) date ;;
            10) last reboot | head -5 ;;
            11) auto_install pciutils; lspci ;;
            12) auto_install usbutils; lsusb ;;
            13) lsblk ;;
            14) df -hT --exclude-type=tmpfs ;;
            15) df -i ;;
            16) mount | column -t ;;
            17) auto_install lshw; sudo lshw -short ;;
            18) [ -d /sys/firmware/efi ] && echo "UEFI Boot" || echo "Legacy BIOS" ;;
            19) auto_install lm-sensors; sensors ;;
            20) acpi -bi 2>/dev/null || echo "No battery detected" ;;
            0) return ;;
            *) echo "Invalid option"; sleep 1; continue ;;
        esac
        pause
    done
}

# ==================================================
#  CATEGORY 2: NETWORK
# ==================================================
menu_net() {
    while true; do
        draw_header
        echo -e "${B} [ CATEGORY 2: NETWORK & INTERNET ]${N}"
        printf "${GR}21.${W} %-25s ${GR}31.${W} %-25s\n" "IP Address (All)" "Ping Google"
        printf "${GR}22.${W} %-25s ${GR}32.${W} %-25s\n" "Public IP (Curl)" "Ping Custom"
        printf "${GR}23.${W} %-25s ${GR}33.${W} %-25s\n" "DNS Lookup (Dig)" "Traceroute"
        printf "${GR}24.${W} %-25s ${GR}34.${W} %-25s\n" "Whois Domain" "MTR (Live Trace)"
        printf "${GR}25.${W} %-25s ${GR}35.${W} %-25s\n" "Netstat Listening" "Speedtest CLI"
        printf "${GR}26.${W} %-25s ${GR}36.${W} %-25s\n" "SS Active Conns" "Download File (Wget)"
        printf "${GR}27.${W} %-25s ${GR}37.${W} %-25s\n" "Route Table" "HTTP Headers (Curl)"
        printf "${GR}28.${W} %-25s ${GR}38.${W} %-25s\n" "ARP Table" "Scan Local Network"
        printf "${GR}29.${W} %-25s ${GR}39.${W} %-25s\n" "Interface Stats" "Bandwidth (nload)"
        printf "${GR}30.${W} %-25s ${GR}40.${W} %-25s\n" "Flush DNS Cache" "Wifi Signal (Linux)"
        echo -e "${R} 0. Back to Main Menu${N}"
        read -p " Select Tool > " opt
        
        case $opt in
            21) ip a ;;
            22) curl -s ifconfig.me ;;
            23) read -p "Domain: " d; auto_install dnsutils; dig "$d" +short ;;
            24) read -p "Domain: " d; auto_install whois; whois "$d" | head -20 ;;
            25) netstat -tulpn ;;
            26) ss -tuna ;;
            27) ip route ;;
            28) ip neigh ;;
            29) ip -s link ;;
            30) sudo systemd-resolve --flush-caches && echo "Flushed." ;;
            31) ping -c 4 google.com ;;
            32) read -p "Host: " h; ping -c 4 "$h" ;;
            33) read -p "Host: " h; traceroute "$h" ;;
            34) read -p "Host: " h; auto_install mtr; mtr "$h" ;;
            35) auto_install speedtest-cli; speedtest-cli --simple ;;
            36) read -p "URL: " u; wget "$u" ;;
            37) read -p "URL: " u; curl -I "$u" ;;
            38) auto_install nmap; nmap -sn 192.168.1.0/24 ;;
            39) auto_install nload; nload ;;
            40) nmcli dev wifi ;;
            0) return ;;
            *) echo "Invalid option"; sleep 1; continue ;;
        esac
        pause
    done
}

# ==================================================
#  CATEGORY 3: SECURITY
# ==================================================
menu_sec() {
    while true; do
        draw_header
        echo -e "${R} [ CATEGORY 3: SECURITY OPS ]${N}"
        printf "${GR}41.${W} %-25s ${GR}51.${W} %-25s\n" "Firewall Status" "Check Rootkits"
        printf "${GR}42.${W} %-25s ${GR}52.${W} %-25s\n" "Fail2Ban Status" "Audit SSH Config"
        printf "${GR}43.${W} %-25s ${GR}53.${W} %-25s\n" "Last Logins" "Check Sudo Users"
        printf "${GR}44.${W} %-25s ${GR}54.${W} %-25s\n" "Failed Auth Logs" "Passwd File Check"
        printf "${GR}45.${W} %-25s ${GR}55.${W} %-25s\n" "Current Users" "Open Ports (Nmap)"
        printf "${GR}46.${W} %-25s ${GR}56.${W} %-25s\n" "Password Expiry" "File Permissions"
        printf "${GR}47.${W} %-25s ${GR}57.${W} %-25s\n" "Lock User" "Lynis Audit"
        printf "${GR}48.${W} %-25s ${GR}58.${W} %-25s\n" "Unlock User" "SELinux Status"
        printf "${GR}49.${W} %-25s ${GR}59.${W} %-25s\n" "Kick User" "AppArmor Status"
        printf "${GR}50.${W} %-25s ${GR}60.${W} %-25s\n" "Kill User Procs" "History Cleaner"
        echo -e "${R} 0. Back to Main Menu${N}"
        read -p " Select Tool > " opt
        
        case $opt in
            41) sudo ufw status 2>/dev/null || echo "UFW not found" ;;
            42) sudo fail2ban-client status 2>/dev/null || echo "Fail2ban not found" ;;
            43) last -n 10 ;;
            44) sudo grep "Failed" /var/log/auth.log | tail -n 15 2>/dev/null || sudo journalctl _SYSTEMD_UNIT=ssh.service | grep "Failed" | tail -n 15 ;;
            45) who ;;
            46) read -p "Username: " u; chage -l "$u" ;;
            47) read -p "Username: " u; sudo passwd -l "$u" ;;
            48) read -p "Username: " u; sudo passwd -u "$u" ;;
            49) read -p "Username: " u; sudo pkill -u "$u" ;;
            50) read -p "Username: " u; sudo killall -u "$u" ;;
            51) auto_install rkhunter; sudo rkhunter --check --sk ;;
            52) grep -vE '^#|^$' /etc/ssh/sshd_config ;;
            53) grep '^sudo:.*' /etc/group ;;
            54) ls -l /etc/passwd /etc/shadow ;;
            55) auto_install nmap; nmap -v localhost ;;
            56) read -p "Path: " p; stat "$p" ;;
            57) auto_install lynis; sudo lynis audit system ;;
            58) sestatus 2>/dev/null || echo "SELinux not present" ;;
            59) aa-status 2>/dev/null || echo "AppArmor not present" ;;
            60) history -c && echo "Session history cleared." ;;
            0) return ;;
            *) echo "Invalid option"; sleep 1; continue ;;
        esac
        pause
    done
}

# ==================================================
#  MAIN MENU LOOP
# ==================================================
while true; do
    draw_header
    echo -e " ${W}MAIN CATEGORIES:${N}"
    echo -e " ${M}1.${N} System & Hardware Info      ${GR}(Tools 1-20)${N}"
    echo -e " ${B}2.${N} Network & Connectivity       ${GR}(Tools 21-40)${N}"
    echo -e " ${R}3.${N} Security & User Audit        ${GR}(Tools 41-60)${N}"
    echo -e " ${GR}─────────────────────────────────────────────────────────────${N}"
    echo -e " ${W}0.${N} Exit Titan Dashboard"
    echo ""
    read -p " Select Category > " main_opt

    case $main_opt in
        1) menu_sys ;;
        2) menu_net ;;
        3) menu_sec ;;
        0) clear; echo -e "${G}Titan Session Terminated.${N}"; exit 0 ;;
        *) echo -e "${R}Invalid Choice${N}"; sleep 1 ;;
    esac
done
