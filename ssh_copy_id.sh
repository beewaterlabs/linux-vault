#!/bin/bash

# Purpose: This script automates copying SSH keys to multiple servers using passwords from a file
# The script reads server information from a file named "server.txt"
# Each line in server.txt should follow the format: username@server:password

# Check if the server list file exists
# If not, show an error message and instructions on how to create it
if [ ! -f "server.txt" ]; then
    echo "Error: server.txt file not found!"
    echo "Please create a file named server.txt with each line in the format: username@server:password"
    exit 1  # Exit with error status 1
fi

# Check if sshpass utility is installed
# sshpass is required to provide passwords non-interactively to ssh-copy-id
if ! command -v sshpass &> /dev/null; then
    echo "Error: sshpass is not installed. Please install it first:"
    echo "For Debian/Ubuntu: sudo apt-get install sshpass"
    echo "For CentOS/RHEL: sudo yum install sshpass"
    exit 1  # Exit with error status 1
fi

# Read server.txt line by line
# IFS= prevents trimming of leading/trailing whitespace
# -r prevents backslash escapes from being interpreted
# || [ -n "$line" ] ensures the last line is processed even if it doesn't end with a newline
while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines and comment lines that start with #
    if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
        continue  # Skip to the next iteration of the loop
    fi
    
    # Check if the line contains a colon separator between server info and password
    if [[ "$line" =~ : ]]; then
        # Split the line into server info (everything before the colon)
        # and password (everything after the colon)
        server_info=${line%:*}  # Remove everything from the last colon to the end
        password=${line#*:}     # Remove everything from the start to the first colon
        
        echo "Copying SSH key to $server_info"
        
        # Use sshpass to provide the password non-interactively to ssh-copy-id
        # -p "$password" provides the password to sshpass
        # -o StrictHostKeyChecking=no prevents prompts about unknown hosts
        sshpass -p "$password" ssh-copy-id -o StrictHostKeyChecking=no "$server_info"
        
        # Check the exit status of the previous command
        # $? contains the exit status of the most recently executed command
        if [ $? -eq 0 ]; then
            echo "Successfully copied SSH key to $server_info"
        else
            echo "Failed to copy SSH key to $server_info"
        fi
        
        echo "-----------------------------------"
    else
        # If the line doesn't contain a colon separator, it's in an invalid format
        echo "Warning: Invalid format in line: $line"
        echo "Expected format: username@server:password"
    fi
done < "server.txt"  # Redirect server.txt as input to the while loop

echo "SSH key copy process completed"
