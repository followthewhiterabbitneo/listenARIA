# listenARIA - OrekX/Oreka Enterprise Call Recording Upgrade

## Quick Start
```bash
# Download all OrecX components
./download_orecx.sh

# Components will be in downloads/
ls -la downloads/

# Install MariaDB 11.4 LTS (see MARIADB_11.4_LTS_INSTALL.md for details)
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version=11.4
sudo apt install mariadb-server mariadb-client  # Ubuntu/Debian
# OR
sudo yum install MariaDB-server MariaDB-client  # RHEL/CentOS
```

## JIRA Story Format Example

### Story: Upgrade OrekX Call Recording System

**Title**: As a system administrator, I need to upgrade the OrekX call recording environment to ensure continued support and improved performance

**Description**:
The current OrekX/Oreka call recording system requires modernization across three core components: the recording software, Apache Tomcat server, and database backend. This upgrade will ensure continued vendor support, security patches, and performance improvements.

**Acceptance Criteria**:
- [ ] Successfully download and stage all OrekX 6.50 components
- [ ] Document current system configuration and versions
- [ ] Create rollback plan with database backups
- [ ] Upgrade OrkAudio from 5.50 to 6.50
- [ ] Upgrade OrkUI and OrkTrack WAR files to 6.50-17994
- [ ] Update Apache Tomcat to supported version
- [ ] Migrate database schema if required
- [ ] Validate all existing recordings remain accessible
- [ ] Confirm recording functionality post-upgrade
- [ ] Performance metrics show improvement or no degradation

**Technical Details**:
- **Current Components**: 
  - OrkAudio Commercial 5.50
  - OrkUI/OrkTrack (version TBD)
  - Apache Tomcat (version TBD)
  - Database: MariaDB/MySQL (version TBD)

- **Target Components**:
  - OrkAudio Commercial 6.50 (RHEL9)
  - OrkUI 6.50-17994
  - OrkTrack 6.50-17994
  - Apache Tomcat 9.x or 10.x
  - Database: Latest stable MariaDB

**Definition of Done**:
- All components upgraded to target versions
- System passes smoke tests
- Recordings from past 30 days verified accessible
- New test recordings created successfully
- Documentation updated
- Monitoring alerts configured

## Project Structure
```
listenARIA/
├── downloads/          # OrekX installation files
├── backups/           # System backups before upgrade
├── configs/           # Configuration files (old/new)
├── scripts/           # Migration and deployment scripts
├── docs/              # Documentation and runbooks
└── tests/             # Validation scripts
```

## Questions to Clarify

Before proceeding with the upgrade, we need to determine:

1. **Current Environment**:
   - What OS version is running? (RHEL 7/8/9?)
   - Current OrkAudio version exactly?
   - Current Tomcat version?
   - Database type and version?
   - Number of concurrent recordings typically handled?

2. **Architecture**:
   - Single server or distributed deployment?
   - Where is Tomcat installed? (/opt/tomcat, /usr/local/tomcat?)
   - Database on same server or remote?
   - Any load balancers or reverse proxies?

3. **Business Requirements**:
   - Maintenance window available?
   - Zero-downtime requirement?
   - Compliance/retention requirements?
   - Integration with other systems?

4. **Backup Strategy**:
   - Current backup location?
   - How much historical data to preserve?
   - Test environment available?

## Next Steps

1. Run `./download_orecx.sh` to get all components
2. Check current system: `rpm -qa | grep -i ork`
3. Check Tomcat: `ps aux | grep tomcat`
4. Check database: `mysql --version` or `mariadb --version`
5. Document findings in `docs/current_state.md`