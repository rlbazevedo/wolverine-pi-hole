# wolverine-pi-hole

A self-healing watchdog script for Raspberry Pi setups running Pi-hole and Unbound.

## Features

- Periodically checks internet connectivity (Cloudflare and Google DNS)
- Verifies that `unbound` and `pihole-FTL` services are running
- Attempts automatic service restart on failure
- After configurable failure limit (default: 3), switches DNS to public resolver (8.8.8.8), sends an alert email, and reboots
- Runs as a systemd timer every 30 seconds for reliable uptime monitoring

## Requirements

- Raspberry Pi with Pi-hole and Unbound installed
- `mailutils` and `msmtp` configured for sending emails
- systemd for timer/service management

## Installation

1. Copy `dns-watchdog.sh` to `/usr/local/bin/` and make executable:

   ```bash
   sudo cp dns-watchdog.sh /usr/local/bin/
   sudo chmod +x /usr/local/bin/dns-watchdog.sh
