# Use the latest Alpine Linux base image
FROM alpine:latest

# Install necessary packages
RUN apk --no-cache add samba mdadm rclone

# Configure RAID
# Replace /dev/sdX with the actual device names for your RAID setup
RUN mdadm --create --verbose /dev/md0 --level=raid1 --raid-devices=2 /dev/sdX /dev/sdY \
    && echo 'DEVICE /dev/sdX /dev/sdY' > /etc/mdadm.conf \
    && mdadm --detail --scan >> /etc/mdadm.conf \
    && mkfs.ext4 /dev/md0 \
    && echo '/dev/md0 /mnt/raid ext4 defaults 0 0' >> /etc/fstab \
    && mkdir /mnt/raid \
    && mount -a

# Configure Samba
RUN echo '[samba_share]' >> /etc/samba/smb.conf \
    && echo '    path = /mnt/raid' >> /etc/samba/smb.conf \
    && echo '    browseable = yes' >> /etc/samba/smb.conf \
    && echo '    read only = no' >> /etc/samba/smb.conf \
    && echo '    guest ok = yes' >> /etc/samba/smb.conf \
    && echo '    create mask = 0777' >> /etc/samba/smb.conf \
    && echo '    directory mask = 0777' >> /etc/samba/smb.conf

# Configure rclone
# Replace <remote> with the name of your rclone remote
RUN echo '[sync]' >> /root/.config/rclone/rclone.conf \
    && echo 'type = <remote>' >> /root/.config/rclone/rclone.conf \
    && echo 'env_auth = false' >> /root/.config/rclone/rclone.conf

# Add crontab jobs
RUN echo '0 * * * * rclone sync /mnt/raid sync:' >> /var/spool/cron/crontabs/root

# Expose the Samba port
EXPOSE 445

# Start Samba and cron services
CMD ["sh", "-c", "nmbd --foreground --no-process-group && smbd --foreground --no-process-group && crond -f"]
