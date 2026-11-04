# The base image is vaultwarden/server:latest-alpine, which moves under this
# repository on every rebuild. These are the pieces the backup and the
# entrypoint rely on; if a base change dropped one, the image would still build.
for tool in sqlite3 mutt rclone crond; do
	command -v "$tool" >/dev/null 2>&1 && pass "$tool is on PATH" || fail "$tool is on PATH"
done
VER=$(rclone version 2>/dev/null | head -1)
assert_contains "$VER" "rclone v" "rclone runs ($VER)"

# The ENTRYPOINT hands off to the base image's own start script, which in turn
# runs the server binary. Both must still be where the CMD expects them.
[ -x /start.sh ]    && pass "base /start.sh is executable"    || fail "base /start.sh is executable"
[ -x /vaultwarden ] && pass "base /vaultwarden is executable" || fail "base /vaultwarden is executable"
[ -x /backup_init.sh ] && pass "/backup_init.sh is executable" || fail "/backup_init.sh is executable"
assert_file /backup.sh "/backup.sh is present"
