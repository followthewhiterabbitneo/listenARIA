# MariaDB 11.4 LTS Installation Guide for listenARIA

## Overview
MariaDB 11.4 LTS is the recommended database for the OrecX/Oreka upgrade project.
- **Current Stable Version**: 11.4.7 (Released: May 22, 2025)
- **Support Period**: Until May 2029
- **Type**: Long-Term Support (LTS) Release

## Quick Installation (All Linux Distributions)

### Method 1: Official Repository Setup Script (Recommended)
```bash
# Download and run the MariaDB repository setup script
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version=11.4

# Install MariaDB
sudo apt update && sudo apt install mariadb-server mariadb-client  # For Ubuntu/Debian
# OR
sudo yum install MariaDB-server MariaDB-client  # For RHEL/CentOS
```

## Distribution-Specific Installation

### Ubuntu/Debian (APT)

#### Step 1: Install Prerequisites
```bash
sudo apt update
sudo apt install apt-transport-https curl software-properties-common gnupg2
```

#### Step 2: Add MariaDB 11.4 Repository
```bash
# Import MariaDB GPG key
curl -fsSL https://mariadb.org/mariadb_release_signing_key.pgp | sudo gpg --dearmor -o /usr/share/keyrings/mariadb.gpg

# Add repository for Ubuntu
echo "deb [arch=amd64,arm64,ppc64el signed-by=/usr/share/keyrings/mariadb.gpg] https://mirror.mariadb.org/repo/11.4/ubuntu/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mariadb.list

# For Debian, use:
# echo "deb [arch=amd64,arm64,ppc64el signed-by=/usr/share/keyrings/mariadb.gpg] https://mirror.mariadb.org/repo/11.4/debian/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mariadb.list
```

#### Step 3: Install MariaDB 11.4
```bash
sudo apt update
sudo apt install mariadb-server mariadb-client mariadb-backup
```

### RHEL/CentOS/Rocky Linux/AlmaLinux

#### Step 1: Create Repository File
```bash
sudo tee /etc/yum.repos.d/MariaDB.repo <<EOF
[mariadb]
name = MariaDB
baseurl = https://rpm.mariadb.org/11.4/rhel/\$releasever/\$basearch
gpgkey = https://rpm.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck = 1
EOF
```

#### Step 2: Install MariaDB 11.4
```bash
# Clean cache
sudo yum clean all

# Install MariaDB
sudo yum install MariaDB-server MariaDB-client MariaDB-backup

# For RHEL 8+ or systems using DNF:
sudo dnf install MariaDB-server MariaDB-client MariaDB-backup
```

### SLES/OpenSUSE

```bash
# Run the setup script
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version=11.4

# Install MariaDB
sudo zypper install MariaDB-server MariaDB-client MariaDB-backup
```

## Post-Installation Configuration

### 1. Start and Enable MariaDB Service
```bash
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo systemctl status mariadb
```

### 2. Secure the Installation
```bash
sudo mysql_secure_installation

# Follow the prompts to:
# - Set root password
# - Remove anonymous users
# - Disallow root login remotely
# - Remove test database
# - Reload privilege tables
```

### 3. Create Oreka Database and User
```bash
sudo mysql -u root -p

# In the MariaDB prompt:
CREATE DATABASE oreka CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'oreka'@'localhost' IDENTIFIED BY 'YourSecurePassword';
GRANT ALL PRIVILEGES ON oreka.* TO 'oreka'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 4. Configure for OrecX Requirements
Edit `/etc/mysql/mariadb.conf.d/50-server.cnf` (Debian/Ubuntu) or `/etc/my.cnf.d/server.cnf` (RHEL/CentOS):

```ini
[mysqld]
# OrecX Recommended Settings
max_connections = 200
innodb_buffer_pool_size = 1G  # Adjust based on available RAM (50-70% of total)
innodb_log_file_size = 256M
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DIRECT

# For call recording metadata
query_cache_type = 1
query_cache_size = 128M
query_cache_limit = 2M

# Binary logging for backup/recovery
log_bin = /var/log/mysql/mariadb-bin
expire_logs_days = 7
max_binlog_size = 100M

# Slow query logging for performance tuning
slow_query_log = 1
slow_query_log_file = /var/log/mysql/mariadb-slow.log
long_query_time = 2
```

Restart MariaDB after configuration changes:
```bash
sudo systemctl restart mariadb
```

## Upgrade from Older MariaDB Versions

### From MariaDB 10.x to 11.4
```bash
# 1. Backup existing database
mysqldump -u root -p --all-databases > all_databases_backup.sql

# 2. Stop MariaDB
sudo systemctl stop mariadb

# 3. Add 11.4 repository (follow distribution-specific steps above)

# 4. Upgrade packages
sudo apt update && sudo apt upgrade  # Ubuntu/Debian
# OR
sudo yum update MariaDB-*  # RHEL/CentOS

# 5. Run upgrade script
sudo mysql_upgrade -u root -p

# 6. Restart MariaDB
sudo systemctl start mariadb
```

## Verification

### Check Version
```bash
mariadb --version
# Should show: mariadb from 11.4.7-MariaDB, client 15.2 for Linux (x86_64)
```

### Test Connection
```bash
mysql -u oreka -p oreka -e "SELECT VERSION();"
```

### Check Service Status
```bash
sudo systemctl status mariadb
sudo journalctl -u mariadb -n 50  # View recent logs
```

## Performance Tuning for OrecX

### Monitor Performance
```sql
-- Check current connections
SHOW STATUS LIKE 'Threads_connected';

-- Check slow queries
SHOW GLOBAL STATUS LIKE 'Slow_queries';

-- Check buffer pool usage
SHOW ENGINE INNODB STATUS;
```

### Create Maintenance Script
```bash
cat > /etc/cron.daily/mariadb-maintenance <<'EOF'
#!/bin/bash
# Daily MariaDB maintenance for OrecX

# Optimize tables
mysqlcheck -u root -p'YourRootPassword' --optimize oreka

# Analyze tables for better query planning
mysqlcheck -u root -p'YourRootPassword' --analyze oreka

# Rotate logs
mysql -u root -p'YourRootPassword' -e "FLUSH LOGS;"
EOF

chmod +x /etc/cron.daily/mariadb-maintenance
```

## Backup Strategy

### Daily Backup Script
```bash
cat > /usr/local/bin/backup-oreka-db.sh <<'EOF'
#!/bin/bash
BACKUP_DIR="/var/backups/mariadb"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="oreka"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Backup database
mysqldump -u root -p'YourRootPassword' \
  --single-transaction \
  --routines \
  --triggers \
  --events \
  $DB_NAME | gzip > $BACKUP_DIR/oreka_$DATE.sql.gz

# Keep only last 7 days of backups
find $BACKUP_DIR -name "oreka_*.sql.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/oreka_$DATE.sql.gz"
EOF

chmod +x /usr/local/bin/backup-oreka-db.sh

# Add to crontab for daily 2 AM backup
echo "0 2 * * * /usr/local/bin/backup-oreka-db.sh" | sudo crontab -
```

## Troubleshooting

### Common Issues

1. **Repository GPG Key Issues**
```bash
# Re-import the key
curl -fsSL https://mariadb.org/mariadb_release_signing_key.pgp | sudo gpg --dearmor -o /usr/share/keyrings/mariadb.gpg
```

2. **Package Conflicts**
```bash
# Remove old MySQL/MariaDB packages
sudo apt remove --purge mysql* mariadb*  # Ubuntu/Debian
sudo yum remove mysql* mariadb*  # RHEL/CentOS

# Clean package cache
sudo apt autoremove && sudo apt autoclean  # Ubuntu/Debian
sudo yum clean all  # RHEL/CentOS
```

3. **Service Won't Start**
```bash
# Check error log
sudo journalctl -xe | grep mariadb
sudo tail -100 /var/log/mysql/error.log

# Check for permission issues
sudo chown -R mysql:mysql /var/lib/mysql
sudo chmod 755 /var/lib/mysql
```

4. **Connection Issues**
```bash
# Check if listening on correct port
sudo netstat -tlnp | grep 3306

# Check firewall
sudo ufw allow 3306  # Ubuntu
sudo firewall-cmd --permanent --add-port=3306/tcp  # RHEL/CentOS
```

## Integration with OrecX

After MariaDB 11.4 is installed, configure OrecX components:

1. **OrkAudio Configuration** (`/etc/orkaudio/config.xml`):
```xml
<Database>
    <Host>localhost</Host>
    <Port>3306</Port>
    <Name>oreka</Name>
    <User>oreka</User>
    <Password>YourSecurePassword</Password>
</Database>
```

2. **OrkUI/OrkTrack Configuration** (in Tomcat webapp):
- Update database connection strings in web.xml or application.properties
- Test connection before starting services

## Notes
- MariaDB 11.4 LTS is supported until May 2029
- Current stable version: 11.4.7 (as of May 2025)
- Fully compatible with MySQL 5.7 and 8.0 protocols
- Includes performance improvements specifically beneficial for metadata-heavy applications like call recording systems