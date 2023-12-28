#!/bin/bash
set -e

update_system() {
  apt update -y
  apt install apt-transport-https -y
  apt-add-repository universe
  apt update
}

install_docker() {
  apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  apt-key fingerprint 0EBFCD88
  add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) \
     stable"

  apt-get update
  apt-get install -y docker-ce
  docker run hello-world

  groupadd docker
  usermod -aG docker $USER
  systemctl enable docker
}

git_clone() {
  git clone https://github.com/alvelive/jitsi-meet.git
  git clone https://github.com/alvelive/docker-jitsi-meet.git
  cp -R ./jitsi-meet/resources/prosody-plugins/ ./docker-jitsi-meet/prosody-plugins/
  cd docker-jitsi-meet
}

create_env() {
  echo <<EOT >.env
${env_file}
EOT
}

start_services() {
  docker compose up -d --build --profile ${profile}
}

update_system
install_docker
git_clone
finalize
