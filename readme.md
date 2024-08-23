# Security Audit and Hardening Scripts

This repository contains scripts for automating security audits and server hardening on Linux servers. The scripts are designed to help ensure servers meet stringent security standards, with customizable checks and hardening measures.

## Overview

The repository includes:
- `security_audit_hardening.sh`: The main script for performing a comprehensive security audit and hardening process.
- `customcheck.sh`: A script for executing custom security checks based on the configurations defined in `customcheck.conf`.
- `custom_checks.conf`: Configuration file where custom security checks are defined.
- `README.md`: Documentation for setting up and using the scripts.

## Prerequisites

- **Linux Server**: The scripts are designed to run on Linux servers (Ubuntu/Debian recommended).
- **Permissions**: Scripts need to be executed with `sudo` privileges.
- **Package Manager**: Ensure `apt-get` or `yum` is available depending on your distribution.

## Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/gopikrishna152/security-audit-hardening.git
   cd security-audit-hardening

## Make Scripts Executable
```bash
chmod +x security_audit_hardening.sh
chmod +x customcheck.sh
```


This script will perform a comprehensive security audit and apply hardening measures. It will generate a report in security_audit_report.txt


## Custom Security Checks
### Edit Custom Checks

Modify the customcheck.conf file to define your custom security checks. Use the provided template to add or adjust checks based on your organizational requirements.

## Run Custom Checks

```
sudo bash customcheck.sh
```
This script will execute the custom checks defined in customcheck.conf and produce a report with findings.


### Configuration
#### customcheck.conf
This configuration file defines the custom security checks that will be executed by customcheck.sh. Each entry in the file corresponds to a specific check or set of checks.

\
Example configuration file:

```bash
# Example custom checks configuration

# Check for users with UID 0 (root privileges) and report non-standard users
check_uid0=true

# Check for users without shell access
check_no_shell_access=true

# Check for open ports that should not be exposed
check_open_ports=true
```

Modify this file according to your security policies and requirements.



## Troubleshooting
#### Common Issues
find Command Errors: \
Ensure that the script is run with sufficient permissions. Errors related to /proc directories are typically benign. 

awk Command Errors: Ensure that the syntax used in awk commands is correct. Double-check the formatting and options used in awk statements. 

Package Manager Errors: Make sure your package manager is properly configured and that there are no issues with the repository sources. 

Reporting Issues
If you encounter any issues, please create a new issue on the GitHub Issues page.

## Project Structure
Here's a suggested directory structure for this project:
```bash
security-audit-hardening/
│
├── config.conf
│
├── custom_checks.conf
│
├── customcheck.sh
│
├── security_audit_report.txt
│
├── custom_security_check_report.txt
│── security_audit_hardening.sh
│
├── LICENSE
├── README.md

```

## Participate and Contribute
Contributions are welcome! Please submit a pull request with your changes or improvements. Ensure that your changes are well-tested and documented.







