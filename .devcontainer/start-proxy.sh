#!/bin/bash
# Startup script for Squid proxy

echo "Starting Squid proxy service..."

# Clean up any existing processes
pkill -f squid 2>/dev/null || true
rm -f /run/squid.pid /var/run/squid.pid 2>/dev/null || true

# Setup directories
mkdir -p /var/log/squid /var/spool/squid /etc/squid

# Copy configuration files
cp /usr/local/bin/squid.conf /etc/squid/squid.conf
cp /usr/local/bin/domain-whitelist.txt /etc/squid/domain-whitelist.txt

# Remove default Debian config
rm -f /etc/squid/conf.d/debian.conf

# Set permissions
chown -R proxy:proxy /var/log/squid /var/spool/squid

# Start Squid
if pgrep -x "squid" > /dev/null; then
    echo "Squid is already running, reloading configuration..."
    squid -k reconfigure
else
    squid -f /etc/squid/squid.conf
fi

# Check if started
sleep 2
if pgrep -x "squid" > /dev/null; then
    echo "✓ Squid proxy started successfully on port 3128"
    echo "✓ Domain whitelist filtering is active"
else
    echo "✗ Failed to start Squid proxy"
    exit 1
fi