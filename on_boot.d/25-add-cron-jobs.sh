#!/bin/bash

## Store crontab files in /data/cronjobs/ (you will need to create this folder).
## This script will re-add them on startup.

cp /data/cronjobs/* /etc/cron.d/
systemctl restart cron

exit 0
