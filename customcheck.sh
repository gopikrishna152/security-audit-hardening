#!/bin/bash

# Output file for custom checks
CUSTOM_REPORT_FILE="custom_security_check_report.txt"

# Configuration file with custom checks
CONFIG_FILE="custom_checks.conf"

# Initialize custom report file
echo "=== Custom Security Checks Report ===" > "$CUSTOM_REPORT_FILE"

# Load custom checks from configuration file
if [ -f "$CONFIG_FILE" ]; then
    echo "Loading custom checks from $CONFIG_FILE" >> "$CUSTOM_REPORT_FILE"
    
    while IFS='=' read -r check_name command; do
        # Skip empty lines or lines starting with #
        [[ -z "$check_name" || "$check_name" =~ ^# ]] && continue
        
        # Report the check name
        echo "=== $check_name ===" >> "$CUSTOM_REPORT_FILE"
        
        # Execute the command and write output to the report
        eval "$command" >> "$CUSTOM_REPORT_FILE"
        
    done < "$CONFIG_FILE"
else
    echo "Configuration file $CONFIG_FILE not found." >> "$CUSTOM_REPORT_FILE"
fi

echo "Custom security checks completed. See $CUSTOM_REPORT_FILE for details."
