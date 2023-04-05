#! /bin/sh

LOG=/var/log/backup.log

# If BACKUP is set, put the backup script in crontab

if [ -n "$BACKUP" ]; then
  ln -sf /proc/1/fd/1 /var/log/backup.log
  printf "Redirecting backup log output to docker\n" >> $LOG
  sed -i "/ash \\/backup\\.sh /d" /etc/crontabs/root
  printf "Removing any existing crontab entries for backup.sh\n" >> $LOG
  echo "$BACKUP_SCHEDULE ash /backup.sh $BACKUP" >> /etc/crontabs/root
  printf "Adding backup.sh crontab entry (%b)\n" "$BACKUP_SCHEDULE" >> $LOG
  crond -d 8;
  printf "Starting the cron daemon\n" >> $LOG
else
  printf "Backup is not configured\n" >> $LOG
fi

# Execute the base image entrypoint
exec "$@"
