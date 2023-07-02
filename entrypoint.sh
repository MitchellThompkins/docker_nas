#!/bin/bash

# Start Samba
/etc/init.d/samba start

# Start Nginx
nginx

# Start the cron service
crond -f -l 8

# Add any additional commands you want to run at startup

# Keep the container running
tail -f /dev/null

