FROM vaultwarden/server:latest-alpine

RUN apk --update --no-cache add sqlite mutt

RUN curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip
RUN unzip rclone-current-linux-amd64.zip
RUN cp rclone-*-linux-amd64/rclone /usr/bin/rclone
RUN chown root:root /usr/bin/rclone
RUN chmod 755 /usr/bin/rclone
RUN rm -f rclone-current-linux-amd64.zip
RUN rm -rf rclone-*-linux-amd64/

COPY scripts/backup_init.sh /
COPY scripts/backup.sh /

ENTRYPOINT ["/backup_init.sh"]
CMD ["/start.sh"]
