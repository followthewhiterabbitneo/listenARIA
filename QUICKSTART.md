# listenARIA Quick Start - Copy & Paste Setup

## 🚀 For Your Target Server

Hey Erik! Copy and paste these commands on your server where you want to upgrade OrecX:

### Step 1: Clone the Repository
```bash
# Go to your home directory (or wherever you want to work)
cd ~

# Clone the listenARIA repository
git clone https://github.com/followthewhiterabbitneo/listenARIA.git

# Enter the project directory
cd listenARIA

# See what's included
ls -la
```

### Step 2: Download OrecX Software (219MB)
```bash
# Run the download script to get all OrecX components
./download_orecx.sh
```
This downloads:
- OrkWebApps 6.00 installer (contains WAR files)
- OrkAudio 5.50 installer
- OrkAudio 6.50 RPM

### Step 3: Start the Interactive Upgrade
```bash
# Run the friendly upgrade assistant
./start_upgrade.sh
```

## 📦 What You Get

When you clone the repository, you'll have:
- `start_upgrade.sh` - Interactive upgrade assistant
- `download_orecx.sh` - Downloads all OrecX software
- `README.md` - Project overview
- `UPGRADE_PLAN.md` - Detailed upgrade plan
- `MARIADB_11.4_LTS_INSTALL.md` - MariaDB installation guide
- All documentation and scripts ready to go!

## 🎯 One-Liner Setup

Want to do it all in one command? Copy and paste this:

```bash
cd ~ && git clone https://github.com/followthewhiterabbitneo/listenARIA.git && cd listenARIA && echo -e "\n✅ Repository cloned!\n📁 You're now in: $(pwd)\n\n🎯 Next steps:\n1. Run: ./download_orecx.sh (downloads OrecX software)\n2. Run: ./start_upgrade.sh (starts interactive upgrade)\n"
```

## 💡 Prerequisites

Make sure your server has:
- Git installed (`sudo apt install git` or `sudo yum install git`)
- Internet connection to download from GitHub and OrecX
- sudo/root access for installation

## 🔧 If Git is Not Installed

### Ubuntu/Debian:
```bash
sudo apt update && sudo apt install -y git
```

### RHEL/CentOS/Rocky:
```bash
sudo yum install -y git
```

## 📞 Support

The repository is at: https://github.com/followthewhiterabbitneo/listenARIA

Everything you need is there - just clone and go!

---

*Created with ❤️ for Erik's OrecX upgrade project*