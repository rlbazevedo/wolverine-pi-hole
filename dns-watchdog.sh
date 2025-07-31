#!/bin/bash

# CONFIGURATION
FAIL_LIMIT=3
COUNTER_FILE="/tmp/dns_watchdog_failcount"
ADMIN_EMAIL="user@email.com"  # <-- Your email here

# FUNCTION: Permanently check internet connectivity
check_connectivity() {
    ping -c 2 1.1.1.1 > /dev/null || ping -c 2 8.8.8.8 > /dev/null
    return $?
}

# FUNCTION: Restart DNS services
restart_services() {
    echo "[Watchdog] Restarting Pi-hole and Unbound..."
    systemctl restart unbound
    systemctl restart pihole-FTL
    sleep 5
}

# FUNCTION: Check if services are running
services_healthy() {
    [[ "$(systemctl is-active unbound)" == "active" ]] && [[ "$(systemctl is-active pihole-FTL)" == "active" ]]
    return $?
}

# MAIN LOGIC

# Step 1: Check Internet and services
check_connectivity
PING_OK=$?
services_healthy
SERVICES_OK=$?

# Step 2: If all OK, reset failure counter
if [[ $PING_OK -eq 0 && $SERVICES_OK -eq 0 ]]; then
    echo 0 > "$COUNTER_FILE"
    exit 0 
fi

# Step 3: Attempt to recover
restart_services

# Step 4: Re-check
check_connectivity
PING_OK=$?
services_healthy
SERVICES_OK=$?

# Step 5: If recovery worked, reset counter
if [[ $PING_OK -eq 0 && $SERVICES_OK -eq 0 ]]; then
    echo 0 > "$COUNTER_FILE"
    exit 0
fi

# Step 6: Increment failure count
COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
COUNT=$((COUNT+1))
echo $COUNT > "$COUNTER_FILE"

# Step 7: Escalate after 3 consecutive failures
if [[ $COUNT -ge $FAIL_LIMIT ]]; then
    echo "[Watchdog] HARD FAIL: $COUNT consecutive issues detected"

    # Change routing DNS to public resolver
    echo "nameserver 8.8.8.8" > /etc/resolv.conf

    # Send email alert (requires mailutils installed and configured)
    echo -e "Subject: Pi-hole/Unbound Crash Detected\n\nDNS watchdog has detected $COUNT consecutive failures.\nSystem will reboot now to restore connectivity." | mail -s "Pi DNS Crash Alert" "$ADMIN_EMAIL"

    # Reboot system
    reboot
fi
