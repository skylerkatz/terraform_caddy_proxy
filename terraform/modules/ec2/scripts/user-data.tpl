#!/usr/bin/env bash

INFRA_ENV="${infra_env}"
INFRA_ROLE="${infra_role}"
INFRA_PROJECT="${infra_project}"

>&2 echo "[$INFRA_ENV:$INFRA_ROLE] Setting up $INFRA_PROJECT server"

>&2 echo "[$INFRA_ENV:$INFRA_ROLE] Preparing Datadog Agent"
sudo service datadog-agent stop
sudo service datadog-agent start

>&2 echo "[$INFRA_ENV:$INFRA_ROLE] Preparing Caddy"
sudo systemctl stop caddy
sudo systemctl start caddy

>&2 echo "[$INFRA_ENV:$INFRA_ROLE] Finished setting up $INFRA_PROJECT server!"
