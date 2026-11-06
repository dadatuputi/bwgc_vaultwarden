FROM vaultwarden/server:latest-alpine

# apk upgrade first: the base image's own packages (apk-tools, for one) can lag
# the repository index, and the nightly rebuild only helps if it brings them up
# to date too.
# backup.sh needs GNU tar: busybox tar ignores all but the last -C.
RUN apk upgrade --no-cache && apk add --no-cache sqlite mutt rclone tar

COPY scripts/backup_init.sh /
COPY scripts/backup.sh /

ENTRYPOINT ["/backup_init.sh"]
CMD ["/start.sh"]
