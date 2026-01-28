#!/bin/bash
set -e  # Exit on any command failure

# Check if the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

# Prompt for a username until a non-existing user is provided
while true; do
    read -r -p "Enter new username: " USERNAME
    if [ -z "$USERNAME" ]; then
        echo "Username cannot be empty."
        continue
    fi
    if id -u "$USERNAME" >/dev/null 2>&1; then
        echo "User '$USERNAME' already exists. Choose another."
        continue
    fi
    break
done

# Determine the path to the authorized_keys file based on the invoking user
# If the invoking user is not root, set AUTH_KEYS to their authorized_keys
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo ~"$SUDO_USER")
    AUTH_KEYS="${USER_HOME}/.ssh/authorized_keys"
fi

# Output the determined AUTH_KEYS path for debugging
echo "$AUTH_KEYS"

# Fallback: If the invoking user's authorized_keys is missing, try root's authorized_keys
if [ ! -f "$AUTH_KEYS" ]; then
    AUTH_KEYS="/root/.ssh/authorized_keys"
fi

# Final check: Prompt for a key if no authorized_keys file exists
AUTH_KEYS_CONTENT=""
if [ ! -f "$AUTH_KEYS" ]; then
    echo "No authorized_keys file found. Paste a public key (or press Enter to abort):"
    read -r AUTH_KEYS_CONTENT
    if [ -z "$AUTH_KEYS_CONTENT" ]; then
        echo "Error: No public key provided."
        exit 1
    fi
fi


# Create the user if it doesn’t exist
adduser --disabled-password --gecos "" "$USERNAME"

# Add the user to the sudo group
usermod -aG sudo "$USERNAME"

sleep 1

# Enable passwordless sudo for the user
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

# Create the .ssh directory in the user's home
mkdir -p /home/"$USERNAME"/.ssh

# Copy or write the SSH authorized_keys to the new user
if [ -n "$AUTH_KEYS_CONTENT" ]; then
    echo "$AUTH_KEYS_CONTENT" > /home/"$USERNAME"/.ssh/authorized_keys
else
    cp "$AUTH_KEYS" /home/"$USERNAME"/.ssh/authorized_keys
fi

sleep 1 

# Set ownership and permissions
chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh
chmod 700 /home/"$USERNAME"/.ssh
chmod 600 /home/"$USERNAME"/.ssh/authorized_keys

# Clean up root's authorized_keys if copied from there
if [ "$AUTH_KEYS" = "/root/.ssh/authorized_keys" ]; then
    rm /root/.ssh/authorized_keys
fi

sleep 1

# Ensure PasswordAuthentication is set to "no"
read -r -p "Disable SSH password authentication? (y/n): " DISABLE_SSH_PASSWORDS
if [ "$DISABLE_SSH_PASSWORDS" = "y" ]; then
    sed -E -i 's|^#?(PasswordAuthentication)\s.*|\1 no|' /etc/ssh/sshd_config
    if ! grep '^PasswordAuthentication\s' /etc/ssh/sshd_config; then 
        echo 'PasswordAuthentication no' | tee -a /etc/ssh/sshd_config
    fi
fi
sleep 3
# Update and upgrade system packages
apt update && apt upgrade -y

# Restart SSH service to apply configuration changes
systemctl restart ssh