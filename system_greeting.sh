#!/usr/bin/env bash
# system_greeting.sh
# Purpose: print a friendly system status line for the current user/host/date.
# Author: Tjahe Essomba Jules Renaud — Week 3 Lab 5A

current_user="$(whoami)"
current_host="$(hostname)"
current_date="$(date '+%Y-%m-%d %H:%M:%S')"

echo "Hello, $current_user!"
echo "You are logged into: $current_host"
echo "Current date/time: $current_date"
