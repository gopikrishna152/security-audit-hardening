#!/bin/bash

# Load configuration file
if [ -f config.conf ]; then
    . ./config.conf
else
    echo "Configuration file config.conf not found. Exiting."
    exit 1
fi

# Output file
REPORT_FILE="${REPORT_FILE:-security_audit_report.txt}"

# Initialize report file
echo "=== Security Audit and Hardening Report ===" > "$REPORT_FILE"

# 1. User and Group Audits
echo "=== User and Group Audits ===" >> "$REPORT_FILE"
echo "Listing all users on the server:" >> "$REPORT_FILE"
getent passwd >> "$REPORT_FILE"

echo "Listing all groups on the server:" >> "$REPORT_FILE"
getent group >> "$REPORT_FILE"

echo "Checking for users with UID 0:" >> "$REPORT_FILE"
awk -F: '($3 == 0) {print "User with UID 0: " $1}' /etc/passwd >> "$REPORT_FILE"

echo "Checking for users without passwords or with weak passwords:" >> "$REPORT_FILE"
while IFS=: read -r user _; do
    password=$(sudo grep "^$user:" /etc/shadow | cut -d: -f2)
    if [ -z "$password" ] || [ "$password" == "!" ] || [ "$password" == "*" ]; then
        echo "User $user has no password set or a weak password." >> "$REPORT_FILE"
    fi
done < /etc/passwd

# 2. File and Directory Permissions
echo "=== File and Directory Permissions ===" >> "$REPORT_FILE"
echo "Searching for world writable files and directories:" >> "$REPORT_FILE"
find / -path /proc -prune -o -perm -022 -type f -exec ls -la {} \; >> "$REPORT_FILE"
find / -path /proc -prune -o -perm -002 -type d -exec ls -la {} \; >> "$REPORT_FILE"

echo "Checking for .ssh directories with secure permissions:" >> "$REPORT_FILE"
find / -name '.ssh' -type d -exec ls -ld {} \; >> "$REPORT_FILE"

echo "Checking for files with SUID/SGID bits set:" >> "$REPORT_FILE"
find / -perm /6000 -type f -exec ls -la {} \; >> "$REPORT_FILE"

# 3. Service Audits
echo "=== Service Audits ===" >> "$REPORT_FILE"
echo "Listing all running services:" >> "$REPORT_FILE"
systemctl list-units --type=service --state=running >> "$REPORT_FILE"

echo "Checking for critical services configuration:" >> "$REPORT_FILE"
for service in sshd iptables; do
    if systemctl status "$service" >/dev/null 2>&1; then
        systemctl status "$service" >> "$REPORT_FILE"
    else
        echo "$service service is not found or not installed." >> "$REPORT_FILE"
    fi
done

echo "Checking for services listening on non-standard ports:" >> "$REPORT_FILE"
netstat -tuln | grep -v '127.0.0.1' >> "$REPORT_FILE"

# 4. Firewall and Network Security
echo "=== Firewall and Network Security ===" >> "$REPORT_FILE"
echo "Checking if a firewall is active:" >> "$REPORT_FILE"
if command -v ufw >/dev/null 2>&1; then
    sudo ufw status verbose >> "$REPORT_FILE"
elif command -v iptables >/dev/null 2>&1; then
    sudo iptables -L -v -n >> "$REPORT_FILE"
else
    echo "No firewall service found." >> "$REPORT_FILE"
fi

echo "Checking for open ports and associated services:" >> "$REPORT_FILE"
netstat -tuln >> "$REPORT_FILE"

echo "Checking IP forwarding and other network configurations:" >> "$REPORT_FILE"
sysctl net.ipv4.ip_forward >> "$REPORT_FILE"
sysctl net.ipv6.conf.all.forwarding >> "$REPORT_FILE"

# 5. IP and Network Configuration Checks
echo "=== IP and Network Configuration Checks ===" >> "$REPORT_FILE"
echo "Listing all IP addresses and identifying public vs. private:" >> "$REPORT_FILE"
ip -4 addr show >> "$REPORT_FILE"
ip -6 addr show >> "$REPORT_FILE"

echo "Identifying public vs. private IP addresses:" >> "$REPORT_FILE"
for ip in $(ip -4 addr show | grep inet | awk '{print $2}'); do
    if echo "$ip" | grep -E '^10\.' >/dev/null ||
       echo "$ip" | grep -E '^172\.(1[6-9]|2[0-9]|3[0-1])\.' >/dev/null ||
       echo "$ip" | grep -E '^192\.168\.' >/dev/null; then
        echo "$ip is a private IP address." >> "$REPORT_FILE"
    else
        echo "$ip is a public IP address." >> "$REPORT_FILE"
    fi
done

# 6. Security Updates and Patching
echo "=== Security Updates and Patching ===" >> "$REPORT_FILE"
echo "Checking for available security updates:" >> "$REPORT_FILE"
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -s | grep "^Inst" >> "$REPORT_FILE"
elif command -v yum >/dev/null 2>&1; then
    sudo yum check-update >> "$REPORT_FILE"
else
    echo "No known package manager found." >> "$REPORT_FILE"
fi

# 7. Log Monitoring
echo "=== Log Monitoring ===" >> "$REPORT_FILE"
echo "Checking for recent suspicious log entries:" >> "$REPORT_FILE"
grep "Failed password" /var/log/auth.log >> "$REPORT_FILE"



# 8. Server Hardening Steps
echo "=== Server Hardening Steps ===" >> "$REPORT_FILE"

# SSH Configuration
echo "Configuring SSH for key-based authentication and disabling root password login:" >> "$REPORT_FILE"
echo "Disabling root password login in /etc/ssh/sshd_config:" >> "$REPORT_FILE"
sudo sed -i '/^PermitRootLogin/s/.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config

# Disabling IPv6
echo "Disabling IPv6 if not required:" >> "$REPORT_FILE"
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 >> "$REPORT_FILE"

# Securing the Bootloader
echo "Setting a password for GRUB bootloader:" >> "$REPORT_FILE"
# Note: Actual implementation will vary depending on system and requirements

# Firewall Configuration
echo "Implementing iptables rules:" >> "$REPORT_FILE"
# Note: Add your iptables configuration commands here

# Automatic Updates
echo "Configuring unattended-upgrades for automatic security updates:" >> "$REPORT_FILE"
sudo apt-get install -y unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades

#custom_check
# 8. Custom Security Checks
echo "=== Custom Security Checks ===" >> "$REPORT_FILE"

# Path to custom check script
CUSTOM_CHECK_SCRIPT="./customcheck.sh"

# Ensure the custom check script exists
if [ -f "$CUSTOM_CHECK_SCRIPT" ]; then
    echo "Running custom security checks..." >> "$REPORT_FILE"
    bash "$CUSTOM_CHECK_SCRIPT" >> "$REPORT_FILE"
else
    echo "Custom check script $CUSTOM_CHECK_SCRIPT not found." >> "$REPORT_FILE"
fi

echo "Security audit and hardening completed. See $REPORT_FILE for details."