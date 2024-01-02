#!/bin/bash
set -e

# Redirect all output to a log file
exec > >(tee -i install-jitsi.log)
exec 2>&1

echo "Starting Jitsi Meet installation..."

# Check and install Docker
if ! command -v docker &>/dev/null; then
  echo "Docker not found, installing Docker..."
  sudo apt update
  sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt update
  sudo apt-get -y install docker-ce docker-compose
  sudo usermod -aG docker $(whoami)
  sudo chmod 777 /var/run/docker.sock
else
  echo "Docker is already installed, skipping installation."
fi

cd /home/ubuntu

# Clone or update the Git repository
if [ ! -d "docker-jitsi-meet" ]; then
  echo "Cloning the Jitsi Meet repository..."
  # Replace this with your secure method of using GitHub token
  git clone https://${github_token}@github.com/alvelive/docker-jitsi-meet.git
  cd docker-jitsi-meet
else
  echo "Repository already exists. Updating..."
  cd docker-jitsi-meet
  git pull
fi

sudo chown -R ubuntu:ubuntu /home/ubuntu/docker-jitsi-meet

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
