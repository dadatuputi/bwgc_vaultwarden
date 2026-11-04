# backup_init.sh is the ENTRYPOINT: it may install a cron entry, then must exec
# whatever command it was given, or the server never starts.
CRONTAB=/etc/crontabs/root
cp "$CRONTAB" /tmp/crontab.orig

# Without BACKUP, nothing is scheduled and the command still runs.
OUT=$(env -u BACKUP /backup_init.sh echo handed-off 2>&1); STATUS=$?
assert_status "$STATUS" 0 "init without BACKUP exits cleanly"
assert_contains "$OUT" "handed-off" "init without BACKUP execs its command"
assert_not_contains "$(cat "$CRONTAB")" "/backup.sh" "init without BACKUP adds no cron entry"

# With BACKUP, one entry for the given schedule and method.
OUT=$(BACKUP=local BACKUP_SCHEDULE="0 3 * * *" /backup_init.sh echo handed-off 2>&1); STATUS=$?
assert_status "$STATUS" 0 "init with BACKUP exits cleanly"
assert_contains "$OUT" "handed-off" "init with BACKUP execs its command"
assert_contains "$(cat "$CRONTAB")" "0 3 * * * ash /backup.sh local" "init with BACKUP adds the cron entry"

# A restart with a new schedule replaces the entry rather than adding another.
BACKUP=local BACKUP_SCHEDULE="30 4 * * *" /backup_init.sh true >/dev/null 2>&1
assert_eq "$(grep -c '/backup\.sh' "$CRONTAB")" "1" "a restart leaves exactly one cron entry"
assert_contains "$(cat "$CRONTAB")" "30 4 * * * ash /backup.sh local" "a restart applies the new schedule"

pkill crond 2>/dev/null || true
cp /tmp/crontab.orig "$CRONTAB"
