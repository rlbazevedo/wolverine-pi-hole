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

2. Copy dns-watchdog.service and dns-watchdog.timer to /etc/systemd/system/:

   sudo cp dns-watchdog.service /etc/systemd/system/
   sudo cp dns-watchdog.timer /etc/systemd/system/

3. Enable and start the timer:

   sudo systemctl daemon-reload
   sudo systemctl enable --now dns-watchdog.timer

4. Configure email sending by copying msmtprc.template to ~/.msmtprc and editing with your credentials.

   cp msmtprc.template ~/.msmtprc
   nano ~/.msmtprc
   chmod 600 ~/.msmtprc

## Usage

The script runs automatically via systemd timer every 30 seconds.

To test manually:

   sudo /usr/local/bin/dns-watchdog.sh

## Troubleshooting

Ensure mailutils and msmtp are installed and properly configured.

Check the status of the timer and service with:

   systemctl status dns-watchdog.timer
   systemctl status dns-watchdog.service
   
Check logs via:

   journalctl -u dns-watchdog.service

## License

This project is licensed under the MIT License - see the LICENSE file for details.

Created by Billy Azevedo

---

If you want, I can help with the exact Git commands to initialize the repo, commit, and push it to GitHub. Just say the word!
