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

# Clone repository
git clone https://${github_token}@github.com/alvelive/docker-jitsi-meet.git
cd docker-jitsi-meet

# Create ENV
echo <<EOT >.env
PUBLIC_URL=https://${domain}
LOG_LEVEL=trace
CONFIG=~/.jitsi-meet-cfg
HTTP_PORT=8000
HTTPS_PORT=8443
TZ=UTC
ETHERPAD_TITLE="Alve"
ETHERPAD_DEFAULT_PAD_TEXT="Welcome to Alve!\n\n"
ETHERPAD_SKIN_NAME=colibris
ETHERPAD_SKIN_VARIANTS="super-light-toolbar super-light-editor light-background full-width-editor"

# Frontend (web service)
DEPLOYMENTINFO_ENVIRONMENT=production
DEPLOYMENTINFO_ENVIRONMENT_TYPE=cloud
DEPLOYMENTINFO_REGION=${region}
DEPLOYMENTINFO_SHARD=${shard}
DEPLOYMENTINFO_USERREGION=${region}

# Prosody
ENABLE_OCTO=true
ENABLE_AUTH=true
ENABLE_LETSENCRYPT=true
LETSENCRYPT_DOMAIN=${domain}
LETSENCRYPT_EMAIL=${email}

# XMPP server (prosody service)
ENABLE_S2S=true
XMPP_DOMAIN=${xmpp_domain}
XMPP_AUTH_DOMAIN=auth.${xmpp_domain}
XMPP_GUEST_DOMAIN=guest.${xmpp_domain}
XMPP_MUC_DOMAIN=muc.${xmpp_domain}
XMPP_INTERNAL_MUC_DOMAIN=internal-muc.${xmpp_domain}
JWT_APP_ID=alve-jitsi
JWT_APP_SECRET=${jwt_app_secret}
JWT_ALLOW_EMPTY=false

# Focus component (jicofo service)
JICOFO_OCTO_REGION=${region}
JICOFO_AUTH_PASSWORD=${jicofo_auth_password}
ENABLE_VISITORS=false

# Video Bridge (jvb service)
ENABLE_COLIBRI_WEBSOCKET=false
JVB_XMPP_SERVER=${xmpp_domain}
JVB_AUTH_PASSWORD=${jvb_auth_password}

# Secrets
JICOFO_COMPONENT_SECRET=${jicofo_component_secret}
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
