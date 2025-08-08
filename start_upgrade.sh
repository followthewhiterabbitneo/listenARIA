#!/bin/bash
# listenARIA - Interactive OrecX Upgrade Assistant
# Created for Erik by Claude

set -e  # Exit on any error

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
else
    echo "Cannot detect OS!"
    exit 1
fi

clear
echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║            🎵 listenARIA - OrecX Upgrade Assistant 🎵        ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo

echo -e "${GREEN}${BOLD}Hey Erik!${NC} 👋"
echo
echo -e "Welcome to your ${PURPLE}OrecX/Oreka${NC} upgrade journey!"
echo "I'll guide you through each step. Let's make this smooth and easy."
echo
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Check if we're in the right directory
EXPECTED_DIR="/home/ecsti/listenARIA"
CURRENT_DIR=$(pwd)

if [ "$CURRENT_DIR" != "$EXPECTED_DIR" ]; then
    echo -e "${RED}Hold up!${NC} You're in: ${YELLOW}$CURRENT_DIR${NC}"
    echo -e "Please run this from: ${GREEN}$EXPECTED_DIR${NC}"
    echo
    echo -e "${CYAN}Copy and paste this:${NC}"
    echo -e "${BOLD}cd /home/ecsti/listenARIA && ./start_upgrade.sh${NC}"
    echo
    exit 1
fi

echo -e "${GREEN}✓${NC} Perfect! You're in the right directory."
echo

# Function to wait for user
wait_for_user() {
    echo
    echo -e "${CYAN}➜ $1${NC}"
    echo -e "${YELLOW}Press ENTER when you're ready to continue...${NC}"
    read -r
}

# Function to run command with description
run_command() {
    local desc="$1"
    local cmd="$2"
    echo
    echo -e "${BLUE}▶ $desc${NC}"
    echo -e "${BOLD}Command:${NC} ${YELLOW}$cmd${NC}"
    echo
    echo -e "${CYAN}Run this? (y/n):${NC} "
    read -r response
    if [[ "$response" == "y" || "$response" == "Y" ]]; then
        echo -e "${GREEN}Running...${NC}"
        eval "$cmd"
        echo -e "${GREEN}✓ Done!${NC}"
        return 0
    else
        echo -e "${YELLOW}⊘ Skipped${NC}"
        return 1
    fi
}

# Function for manual steps
manual_step() {
    local desc="$1"
    local cmd="$2"
    echo
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}MANUAL STEP:${NC} $desc"
    echo
    echo -e "${CYAN}Copy and run this command:${NC}"
    echo
    echo -e "${YELLOW}${BOLD}$cmd${NC}"
    echo
    echo -e "${GREEN}Tell me when you're done! Type 'done' and press ENTER:${NC}"
    while true; do
        read -r response
        if [[ "${response,,}" == "done" ]]; then
            echo -e "${GREEN}✓ Awesome! Moving on...${NC}"
            break
        else
            echo -e "${YELLOW}Type 'done' when you've completed this step:${NC}"
        fi
    done
}

# Start the upgrade process
echo -e "${BOLD}${PURPLE}📋 PHASE 1: SYSTEM CHECK${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo
echo "First, let's see what we're working with..."
echo

# Check current system
echo -e "${BLUE}Your System:${NC}"
echo "• OS: $PRETTY_NAME"
echo "• Hostname: $(hostname)"
echo "• Current directory: $(pwd)"
echo "• Current user: $(whoami)"
echo

wait_for_user "Let's check your current OrecX installation"

# Check current OrecX versions
echo -e "${BOLD}Checking installed OrecX components...${NC}"
echo

if command -v rpm &> /dev/null; then
    echo "RPM-based system detected. Checking packages..."
    rpm -qa | grep -i ork 2>/dev/null || echo "No OrecX packages found via RPM"
else
    echo "Non-RPM system. Checking for OrecX in common locations..."
    ls -la /opt/ork* 2>/dev/null || echo "No OrecX found in /opt"
fi

echo
ps aux | grep -i ork | grep -v grep || echo "No OrecX processes currently running"

wait_for_user "Now let's check your database"

# Check database
echo -e "${BOLD}Checking database...${NC}"
if command -v mysql &> /dev/null; then
    mysql --version
elif command -v mariadb &> /dev/null; then
    mariadb --version
else
    echo -e "${YELLOW}No MySQL/MariaDB client found${NC}"
fi

wait_for_user "Let's check Tomcat"

# Check Tomcat
echo -e "${BOLD}Checking Tomcat...${NC}"
if [ -n "$CATALINA_HOME" ]; then
    echo "CATALINA_HOME: $CATALINA_HOME"
    if [ -f "$CATALINA_HOME/bin/version.sh" ]; then
        $CATALINA_HOME/bin/version.sh | head -5
    fi
else
    echo "CATALINA_HOME not set. Checking common locations..."
    for dir in /opt/tomcat /usr/share/tomcat /var/lib/tomcat; do
        if [ -d "$dir" ]; then
            echo "Found Tomcat directory: $dir"
            ls -la "$dir/webapps/" 2>/dev/null | grep -E "(ork|ui|track)" || true
        fi
    done
fi

echo
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}PHASE 1 COMPLETE!${NC} System check done."
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"

wait_for_user "Ready for Phase 2: Backups"

# PHASE 2: BACKUPS
echo
echo -e "${BOLD}${PURPLE}💾 PHASE 2: BACKUPS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo -e "${RED}${BOLD}⚠️  CRITICAL: Always backup before upgrading!${NC}"
echo

# Create backup directory
BACKUP_DIR="/home/ecsti/listenARIA/backups/$(date +%Y%m%d_%H%M%S)"
run_command "Create backup directory" "mkdir -p $BACKUP_DIR"

echo
echo -e "${YELLOW}Now I need you to run some backup commands manually.${NC}"
echo -e "${YELLOW}These need your database password, so you'll run them yourself.${NC}"

# Database backup
manual_step "Backup your Oreka database" \
    "mysqldump -u root -p oreka > $BACKUP_DIR/oreka_database.sql"

# Check for config files to backup
if [ -d "/etc/orkaudio" ]; then
    run_command "Backup OrkAudio configuration" \
        "sudo tar -czf $BACKUP_DIR/orkaudio_config.tar.gz /etc/orkaudio/"
fi

if [ -n "$CATALINA_HOME" ] && [ -d "$CATALINA_HOME/webapps" ]; then
    run_command "Backup Tomcat webapps" \
        "sudo tar -czf $BACKUP_DIR/tomcat_webapps.tar.gz $CATALINA_HOME/webapps/"
fi

echo
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}PHASE 2 COMPLETE!${NC} Backups created in:"
echo -e "${CYAN}$BACKUP_DIR${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"

wait_for_user "Ready for Phase 3: MariaDB 11.4 LTS Installation"

# PHASE 3: MARIADB INSTALLATION
echo
echo -e "${BOLD}${PURPLE}🗄️  PHASE 3: MARIADB 11.4 LTS INSTALLATION${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

echo -e "${BLUE}We'll install MariaDB 11.4 LTS (supported until 2029)${NC}"
echo

# Determine package manager and install MariaDB
if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
    echo -e "${GREEN}Detected Ubuntu/Debian system${NC}"
    
    manual_step "Add MariaDB 11.4 repository and install" \
        "curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version=11.4 && sudo apt update && sudo apt install -y mariadb-server mariadb-client mariadb-backup"
    
elif [[ "$OS" == "rhel" ]] || [[ "$OS" == "centos" ]] || [[ "$OS" == "rocky" ]] || [[ "$OS" == "almalinux" ]]; then
    echo -e "${GREEN}Detected RHEL/CentOS/Rocky/AlmaLinux system${NC}"
    
    manual_step "Add MariaDB 11.4 repository and install" \
        "curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version=11.4 && sudo yum install -y MariaDB-server MariaDB-client MariaDB-backup"
else
    echo -e "${YELLOW}Unknown OS. Please install MariaDB 11.4 manually.${NC}"
    echo "Visit: https://mariadb.org/download/"
fi

# Start and secure MariaDB
echo
echo -e "${BOLD}Starting MariaDB service...${NC}"
run_command "Start MariaDB" "sudo systemctl start mariadb"
run_command "Enable MariaDB at boot" "sudo systemctl enable mariadb"

echo
echo -e "${YELLOW}${BOLD}Time to secure your MariaDB installation!${NC}"
manual_step "Run the security script (set root password, remove test database, etc.)" \
    "sudo mysql_secure_installation"

# Create Oreka database
echo
echo -e "${BOLD}Creating Oreka database and user...${NC}"
cat > /tmp/create_oreka_db.sql << 'EOF'
CREATE DATABASE IF NOT EXISTS oreka CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'oreka'@'localhost' IDENTIFIED BY 'OrekaPass2024!';
GRANT ALL PRIVILEGES ON oreka.* TO 'oreka'@'localhost';
FLUSH PRIVILEGES;
EOF

echo -e "${CYAN}I've prepared the SQL commands. You'll need to run them.${NC}"
manual_step "Create Oreka database and user" \
    "sudo mysql -u root -p < /tmp/create_oreka_db.sql"

# Verify MariaDB installation
echo
run_command "Verify MariaDB version" "mariadb --version"

echo
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}PHASE 3 COMPLETE!${NC} MariaDB 11.4 LTS installed!"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"

wait_for_user "Ready for Phase 4: OrecX Installation"

# PHASE 4: ORECX INSTALLATION
echo
echo -e "${BOLD}${PURPLE}📞 PHASE 4: ORECX INSTALLATION${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

echo -e "${BLUE}Available OrecX installers:${NC}"
echo
ls -lah downloads/*.rpm downloads/*.sh 2>/dev/null | grep -E "(ork|orec)"
echo

echo -e "${YELLOW}Which version would you like to install?${NC}"
echo "1) OrkAudio 6.50 (Latest - Recommended)"
echo "2) OrkAudio 5.50 (Older stable)"
echo "3) Skip OrkAudio installation"
echo
echo -n "Enter choice (1-3): "
read -r choice

case $choice in
    1)
        if [[ "$OS" == "rhel" ]] || [[ "$OS" == "centos" ]] || [[ "$OS" == "rocky" ]]; then
            manual_step "Install OrkAudio 6.50" \
                "sudo rpm -Uvh downloads/orkaudio-commercial-6.50_2652x13398.x86_64.rhel9.gcc11.rpm"
        else
            echo -e "${YELLOW}RPM package needs conversion for Debian/Ubuntu${NC}"
            manual_step "Convert and install OrkAudio 6.50" \
                "sudo alien -i downloads/orkaudio-commercial-6.50_2652x13398.x86_64.rhel9.gcc11.rpm"
        fi
        ;;
    2)
        manual_step "Install OrkAudio 5.50" \
            "cd downloads && sudo ./orkaudio-commercial-5.50-2479.x12325.x86_64.rhel9.gcc11-installer.sh"
        ;;
    3)
        echo "Skipping OrkAudio installation"
        ;;
esac

# Install web applications
echo
echo -e "${BOLD}Installing OrecX Web Applications (OrkUI, OrkTrack)...${NC}"
echo -e "${YELLOW}The installer needs unzip. Let's make sure it's installed.${NC}"

run_command "Install unzip" "sudo apt install -y unzip || sudo yum install -y unzip"

echo
echo -e "${CYAN}The web installer will ask for:${NC}"
echo "• Tomcat location (usually /opt/tomcat or /usr/share/tomcat)"
echo "• Database details (host: localhost, name: oreka, user: oreka)"
echo "• Admin credentials for the web interface"
echo

manual_step "Run OrecX Web Applications installer" \
    "cd downloads && sudo ./orkwebapps-6.00-17473-x64-linux-installer.sh"

echo
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}PHASE 4 COMPLETE!${NC} OrecX components installed!"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"

wait_for_user "Ready for Phase 5: Verification"

# PHASE 5: VERIFICATION
echo
echo -e "${BOLD}${PURPLE}✅ PHASE 5: VERIFICATION${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

echo -e "${BOLD}Let's verify everything is working...${NC}"
echo

# Check services
run_command "Check MariaDB status" "sudo systemctl status mariadb | head -10"
run_command "Check OrkAudio status" "sudo systemctl status orkaudio 2>/dev/null | head -10 || echo 'OrkAudio service not found'"
run_command "Check Tomcat status" "sudo systemctl status tomcat 2>/dev/null | head -10 || echo 'Tomcat service not found'"

# Check ports
echo
echo -e "${BOLD}Checking network ports...${NC}"
sudo netstat -tlnp | grep -E "(3306|8080|59140)" || sudo ss -tlnp | grep -E "(3306|8080|59140)"

echo
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}🎉 CONGRATULATIONS ERIK! 🎉${NC}"
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo
echo -e "${CYAN}${BOLD}Your OrecX upgrade is complete!${NC}"
echo
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Test the web interface: http://$(hostname -I | awk '{print $1}'):8080/orkui"
echo "2. Make a test recording to verify audio capture"
echo "3. Check that historical recordings are still accessible"
echo "4. Monitor logs for any errors:"
echo "   • OrkAudio: /var/log/orkaudio/"
echo "   • Tomcat: $CATALINA_HOME/logs/"
echo "   • MariaDB: /var/log/mysql/"
echo
echo -e "${GREEN}Your backups are safely stored in:${NC}"
echo -e "${CYAN}$BACKUP_DIR${NC}"
echo
echo -e "${PURPLE}${BOLD}Thanks for using listenARIA!${NC}"
echo -e "${PURPLE}Rock on! 🎸${NC}"
echo