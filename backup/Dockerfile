FROM alpine:3.19

RUN apk add --no-cache postgresql16-client dcron gzip

COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Create the crontab: run every 5 minutes
RUN echo '*/5 * * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1' > /etc/crontabs/root

# Create backup directory
RUN mkdir -p /backups

# Run crond in foreground
CMD ["crond", "-f", "-l", "2"]
