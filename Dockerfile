FROM vaultwarden/server:latest-alpine

# apk upgrade first: the base image's own packages (apk-tools, for one) can lag
# the repository index, and the nightly rebuild only helps if it brings them up
# to date too.
#
# rclone comes from the Alpine community repository, so apk verifies its
# signature and the nightly package check sees when it falls behind. It used to
# be downloaded from downloads.rclone.org as "rclone-current" with no checksum,
# so whatever that URL served went into the vault's own container unchecked.
RUN apk upgrade --no-cache && apk add --no-cache sqlite mutt rclone

COPY scripts/backup_init.sh /
COPY scripts/backup.sh /

ENTRYPOINT ["/backup_init.sh"]
CMD ["/start.sh"]
