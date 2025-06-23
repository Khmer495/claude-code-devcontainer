#!/bin/bash

# Script to update domain whitelist from inside the container

set -e

WHITELIST_FILE="/etc/squid/domain-whitelist.txt"
SQUID_PID_FILE="/var/run/squid.pid"

# Function to display usage
usage() {
    echo "Usage: update-whitelist [COMMAND] [DOMAIN]"
    echo ""
    echo "Commands:"
    echo "  add DOMAIN     Add a domain to the whitelist"
    echo "  remove DOMAIN  Remove a domain from the whitelist"
    echo "  list           List all whitelisted domains"
    echo "  edit           Open the whitelist in an editor"
    echo "  reload         Reload Squid configuration"
    echo ""
    echo "Examples:"
    echo "  update-whitelist add .example.com"
    echo "  update-whitelist remove .badsite.com"
    echo "  update-whitelist list"
}

# Function to add domain
add_domain() {
    local domain="$1"
    if [ -z "$domain" ]; then
        echo "Error: Domain not specified"
        usage
        exit 1
    fi
    
    # Check if domain already exists
    if grep -qF "$domain" "$WHITELIST_FILE" 2>/dev/null; then
        echo "Domain '$domain' is already in the whitelist"
        return
    fi
    
    # Add domain to whitelist with proper newline
    # First check if file ends with newline
    if [ -f "$WHITELIST_FILE" ] && [ -n "$(tail -c 1 "$WHITELIST_FILE")" ]; then
        # File doesn't end with newline, add one
        echo "" | sudo tee -a "$WHITELIST_FILE" > /dev/null
    fi
    echo "$domain" | sudo tee -a "$WHITELIST_FILE" > /dev/null
    echo "Added '$domain' to whitelist"
    
    # Reload Squid
    reload_squid
}

# Function to remove domain
remove_domain() {
    local domain="$1"
    if [ -z "$domain" ]; then
        echo "Error: Domain not specified"
        usage
        exit 1
    fi
    
    # Create temporary file
    temp_file=$(mktemp)
    
    # Remove domain from whitelist
    if grep -vF "$domain" "$WHITELIST_FILE" > "$temp_file" 2>/dev/null; then
        sudo mv "$temp_file" "$WHITELIST_FILE"
        echo "Removed '$domain' from whitelist"
        reload_squid
    else
        rm -f "$temp_file"
        echo "Domain '$domain' not found in whitelist"
    fi
}

# Function to list domains
list_domains() {
    echo "=== Current Whitelisted Domains ==="
    if [ -f "$WHITELIST_FILE" ]; then
        cat "$WHITELIST_FILE" | grep -v '^#' | grep -v '^$' | sort
    else
        echo "Whitelist file not found"
    fi
}

# Function to edit whitelist
edit_whitelist() {
    # Use the default editor or nano if not set
    EDITOR="${EDITOR:-nano}"
    
    # Create a temporary copy
    temp_file=$(mktemp)
    cp "$WHITELIST_FILE" "$temp_file"
    
    # Edit the temporary file
    $EDITOR "$temp_file"
    
    # If the file was modified, update the whitelist
    if ! cmp -s "$temp_file" "$WHITELIST_FILE"; then
        sudo cp "$temp_file" "$WHITELIST_FILE"
        echo "Whitelist updated"
        reload_squid
    else
        echo "No changes made"
    fi
    
    rm -f "$temp_file"
}

# Function to reload Squid
reload_squid() {
    echo "Reloading Squid configuration..."
    
    # Check if Squid is running using pgrep
    if pgrep -x "squid" > /dev/null; then
        # Try to reload as current user, fall back to sudo if needed
        if squid -k reconfigure 2>/dev/null; then
            echo "Squid configuration reloaded"
        elif sudo squid -k reconfigure 2>/dev/null; then
            echo "Squid configuration reloaded (with sudo)"
        else
            echo "Error: Unable to reload Squid configuration"
            echo "You may need to run as root or use: sudo squid -k reconfigure"
        fi
    else
        echo "Warning: Squid doesn't appear to be running"
        echo "You may need to start it with: sudo /usr/local/bin/start-proxy.sh"
    fi
}

# Main script logic
case "$1" in
    add)
        add_domain "$2"
        ;;
    remove)
        remove_domain "$2"
        ;;
    list)
        list_domains
        ;;
    edit)
        edit_whitelist
        ;;
    reload)
        reload_squid
        ;;
    *)
        usage
        exit 1
        ;;
esac