#! /usr/bin/env bash

# Stop on error
set -e

# Move the binary to $PATH
sudo mv /tmp/caddy /usr/bin/

# Make it executable
sudo chmod +x /usr/bin/caddy

# Create a group named caddy
sudo groupadd --system caddy

# Create a user named caddy, with a writeable home folder
sudo useradd --system \
    --gid caddy \
    --create-home \
    --home-dir /var/lib/caddy \
    --shell /usr/sbin/nologin \
    --comment "Caddy web server" \
    caddy

# Create the environment file
sudo echo "
AWS_ACCESS_KEY=$DYNAMO_DB_AWS_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=$DYNAMO_DB_AWS_SECRET_ACCESS_KEY
AWS_REGION=$DYNAMO_DB_AWS_REGION" | sudo tee /etc/environment

# Create the caddy directory & Caddyfile
sudo mkdir /etc/caddy
sudo mv /tmp/Caddyfile /etc/caddy/Caddyfile

# Move the caddy.service file into place
sudo mv /tmp/caddy.service /etc/systemd/system/caddy.service


# Start the service
sudo systemctl daemon-reload
sudo systemctl enable caddy
sudo systemctl start caddy

# Remember, when making changes to the config file, you need to run
#sudo systemctl reload caddy
