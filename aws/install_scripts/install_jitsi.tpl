#!/bin/bash
set -e

# Install Docker
sudo apt update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt-get -y install docker-ce
sudo usermod -a -G docker $(whoami)
sudo apt-get install docker-compose -y

# Add user 'jitsi'
sudo adduser jitsi
sudo usermod -a -G docker jitsi

# Grant sudo privileges to the user 'jitsi'
# sudo usermod -aG sudo jitsi

# Switch to the user 'jitsi'
su - jitsi
cd ~

# Clone repository
git clone https://${github_token}@github.com/alvelive/docker-jitsi-meet.git
cd docker-jitsi-meet

# Create ENV
cat <<EOT >.env
${env_file}
EOT

# Export env to current session
export $(cat .env | xargs)

# Copy custom plugins to config dir
mkdir -p ~/$CONFIG/prosody
cp -R ./custom-prosody-plugins ~/$CONFIG/prosody/prosody-plugins-custom

# Generate required config directories
mkdir -p ~/$CONFIG/{web,transcripts,prosody/config,jicofo,jvb,jigasi,jibri}

# Start services in selected profiles
docker compose up --profile ${profile} -d --build
