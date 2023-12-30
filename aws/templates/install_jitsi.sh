#!/bin/bash
set -e

# Redirect all output to a log file
exec > >(tee -i install-jitsi.log)
exec 2>&1

if ! command -v docker &>/dev/null; then
  echo "Command docker not found, installing Docker"

  # Install Docker
  sudo apt update
  sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt update
  sudo apt-get -y install docker-ce
  sudo usermod -aG docker $(whoami)
  sudo apt-get install docker-compose -y

  sudo usermod -aG sudo ubuntu
  sudo usermod -aG docker ubuntu
else
  echo "Docker is already installed, skipping installation"
fi

cd /home/ubuntu

if [ ! -d "$REPO_DIR" ]; then
  # Clone repository
  git clone https://${github_token}@github.com/alvelive/docker-jitsi-meet.git
  cd docker-jitsi-meet
else
  # Directory exists, no need to clone
  echo "Repository already exists. Updating permissions."
  sudo chown -R ubuntu:ubuntu docker-jitsi-meet
fi

# Create ENV
cat <<ENV_FILE >.env
${env_file}
ENV_FILE

# Export env to current session
export $(cat .env | xargs)

# Copy custom plugins to config dir
mkdir -p $CONFIG/prosody
cp -R ./custom-prosody-plugins $CONFIG/prosody/prosody-plugins-custom

# Generate required config directories
mkdir -p $CONFIG/{web,transcripts,prosody/config,jicofo,jvb,jigasi,jibri}

# Start services in selected profiles
docker compose --profile ${profile} up -d --build
