#! /usr/bin/env bash

# Stop on error
set -e

export DEBIAN_FRONTEND="noninteractive"

DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=$DATADOG_API_KEY DD_SITE="datadoghq.com" DD_HOST_TAGS="env:$INFRA_ENV,project:caddy-proxy,app:proxy-server,ManagedBy:packer" DD_INSTALL_ONLY=true DD_LOGS_ENABLED=true bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

sudo sed -i 's/# logs_enabled: false/logs_enabled: true/g' /etc/datadog-agent/datadog.yaml

sudo usermod -a -G systemd-journal dd-agent

sudo echo "logs:
    - type: journald
      exclude_units:
        - datadog-agent.service
        - datadog-agent-trace.service
        - datadog-agent-process.service
        - datadog-agent-sysprobe.service
      log_processing_rules:
        - type: mask_sequences
          name: redact_keys
          replace_placeholder: '[VALUE REDACTED]'
          pattern: (?:ACCESS_KEY=[A-Za-z0-9\s_\/\\]*)" | sudo tee /etc/datadog-agent/conf.d/journald.d/conf.yaml

sudo -u dd-agent cp /etc/datadog-agent/system-probe.yaml.example /etc/datadog-agent/system-probe.yaml
sudo sed -i 's/# network_config:/network_config:\
 enabled: true/g' /etc/datadog-agent/system-probe.yaml

sudo sed -i 's/# process_config:/process_config:\
 enabled: true/g' /etc/datadog-agent/datadog.yaml

sudo sed -i 's/  # scrub_args: true/scrub_args: true/g' /etc/datadog-agent/datadog.yaml
sudo sed -i 's/  # custom_sensitive_words:/custom_sensitive_words:/g' /etc/datadog-agent/datadog.yaml
sudo sed -i "s/  #   - 'personal_key'/  - 'AWS_*_KEY'/g" /etc/datadog-agent/datadog.yaml

sudo service datadog-agent stop
