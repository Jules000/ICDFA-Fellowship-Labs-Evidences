#!/bin/bash
# onboard_user.sh — creates a lab-only group + user + protected home-style directory
# Usage: sudo ./onboard_user.sh <username> <groupname>

set -u

# 1. Require root
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: this script must be run with sudo/root privileges." >&2
    exit 1
fi

USERNAME="${1:-}"
GROUPNAME="${2:-}"

if [[ -z "$USERNAME" || -z "$GROUPNAME" ]]; then
    read -rp "Enter new username: " USERNAME
    read -rp "Enter new group name: " GROUPNAME
fi

# 2. Check duplicate group
if getent group "$GROUPNAME" >/dev/null 2>&1; then
    echo "ERROR: group '$GROUPNAME' already exists." >&2
    exit 2
fi

# 3. Check duplicate user
if getent passwd "$USERNAME" >/dev/null 2>&1; then
    echo "ERROR: user '$USERNAME' already exists." >&2
    exit 3
fi

# 4. Create group and user
groupadd "$GROUPNAME" || { echo "ERROR: failed to create group." >&2; exit 4; }
useradd -m -s /bin/bash -g "$GROUPNAME" "$USERNAME" || { echo "ERROR: failed to create user." >&2; exit 5; }

# 5. Set password securely (prompts, never echoed/logged)
passwd "$USERNAME"

# 6. Create protected directory
USERDIR="/srv/wadf-userdirs/$USERNAME"
mkdir -p "$USERDIR"
chown "$USERNAME":"$GROUPNAME" "$USERDIR"
chmod 2770 "$USERDIR"
chmod +t "$USERDIR"

echo "SUCCESS: user '$USERNAME' created with group '$GROUPNAME' and protected directory '$USERDIR'."
exit 0
