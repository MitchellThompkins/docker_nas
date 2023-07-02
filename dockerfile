# Use the latest Alpine Linux base image
FROM alpine:latest

# Install necessary packages
RUN apk --no-cache add samba mdadm rclone python3 py3-pip curl

# Configure RAID
# Replace /dev/sdX with the actual device names for your RAID setup
#RUN mdadm --create --verbose /dev/md0 --level=raid1 --raid-devices=2 /dev/sdX /dev/sdY \
#    && echo 'DEVICE /dev/sdX /dev/sdY' > /etc/mdadm.conf \
#    && mdadm --detail --scan >> /etc/mdadm.conf \
#    && mkfs.ext4 /dev/md0 \
#    && echo '/dev/md0 /mnt/raid ext4 defaults 0 0' >> /etc/fstab \
#    && mkdir /mnt/raid \
#    && mount -a

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

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Set the working directory
WORKDIR /app

# Copy the poetry files
COPY pyproject.toml poetry.lock /app/

# Install project dependencies
RUN poetry config virtualenvs.create false \
    && poetry install --no-dev --no-interaction --no-ansi

# Copy the web server code
COPY src/nas/web_server.py /app/web_server.py

# Expose the Samba and web server ports
EXPOSE 445 8000

# Start Samba, cron, and the web server
CMD ["sh", "-c", "nmbd --foreground --no-process-group && smbd --foreground --no-process-group && crond -f & poetry run python3 /app/web_server.py"]

