#!/bin/bash
set -e

EMAIL="${email_address}"
SETUP_TYPE="${setup_type}"
HOSTNAME="${hostname}"
JVB_SECRET="${jvb_secret}"
XMPP_SERVER="${xmpp_server}"
XMPP_PASSWORD="${xmpp_password}"
ADMIN_USER="${admin_username}"
ADMIN_PASSWORD="${admin_password}"
PUBLIC_IP=$(curl -s http://icanhazip.com)

function update_system() {
  sudo apt update -y
  sudo apt install apt-transport-https -y
  sudo apt-add-repository universe
  sudo apt update
}

function set_host() {
  sudo hostnamectl set-hostname $HOSTNAME
  echo "$(curl http://icanhazip.com) $HOSTNAME" | sudo tee -a /etc/hosts
}

function add_prosody_repository() {
  sudo curl -sL https://prosody.im/files/prosody-debian-packages.key -o /etc/apt/keyrings/prosody-debian-packages.key
  echo "deb [signed-by=/etc/apt/keyrings/prosody-debian-packages.key] http://packages.prosody.im/debian $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/prosody-debian-packages.list
  sudo apt install lua5.2
}

function add_jitsi_repository() {
  curl -sL https://download.jitsi.org/jitsi-key.gpg.key | sudo sh -c 'gpg --dearmor > /usr/share/keyrings/jitsi-keyring.gpg'
  echo "deb [signed-by=/usr/share/keyrings/jitsi-keyring.gpg] https://download.jitsi.org stable/" | sudo tee /etc/apt/sources.list.d/jitsi-stable.list
  sudo apt update
}

function configure_jitsi() {
  cat <<EOF | sudo debconf-set-selections
jitsi-videobridge   jitsi-videobridge/jvb-hostname  string  $HOSTNAME
jitsi-meet  jitsi-meet/jvb-serve    boolean false
jitsi-meet-prosody  jitsi-videobridge/jvb-hostname  string  $XMPP_SERVER
jitsi-meet-web-config jitsi-meet/cert-choice select 'Generate a new self-signed certificate (You will later get a chance to obtain a Let's encrypt certificate)'
jitsi-meet-web-config   jitsi-meet/cert-path-crt    string  /etc/ssl/$XMPP_SERVER.crt
jitsi-meet-web-config   jitsi-meet/cert-path-key    string  /etc/ssl/$XMPP_SERVER.key
jitsi-meet-web-config   jitsi-meet/jaas-choice  boolean false
EOF
  sudo apt install jitsi-meet -y
}

function configure_prosody() {
  # Add s2s configuration in Prosody
  PROSODY_CONF_FILE=/etc/prosody/conf.d/$HOSTNAME.cfg.lua
  sed -e 's/authentication \= "anonymous"/authentication \= "internal_plain"/' -i $PROSODY_CONF_FILE
  echo "s2s_ports = { 5269 }" | sudo tee -a $PROSODY_CONF_FILE
  echo "s2s_secure_auth = true" | sudo tee -a $PROSODY_CONF_FILE
}

function configure_jitsi_videobridge() {
  # Jitsi Videobridge configuration
  cat <<EOT | sudo tee /etc/jitsi/videobridge/config
    # Jitsi Videobridge settings
    JVB_HOSTNAME=$HOSTNAME
    JVB_HOST=$HOSTNAME
    JVB_PORT=5347
    JVB_SECRET=$JVB_SECRET
    JVB_OPTS="--apis=,"
    JAVA_SYS_PROPS="-Dconfig.file=/etc/jitsi/videobridge/jvb.conf -Dnet.java.sip.communicator.SC_HOME_DIR_LOCATION=/etc/jitsi -Dnet.java.sip.communicator.SC_HOME_DIR_NAME=videobridge -Dnet.java.sip.communicator.SC_LOG_DIR_LOCATION=/var/log/"
EOT

  cat <<EOT | sudo tee -a /etc/jitsi/videobridge/jvb.conf
      org.jitsi.videobridge.octo.BIND_ADDRESS=0.0.0.0
      org.jitsi.videobridge.octo.PUBLIC_ADDRESS=$PUBLIC_IP
      org.jitsi.videobridge.octo.REGION=$REGION
      org.jitsi.videobridge.xmpp.user.shard.HOSTNAME=$XMPP_SERVER
      org.jitsi.videobridge.xmpp.user.shard.DOMAIN=auth.$XMPP_SERVER
      org.jitsi.videobridge.xmpp.user.shard.USERNAME=jvb
      org.jitsi.videobridge.xmpp.user.shard.PASSWORD=$XMPP_PASSWORD
      org.jitsi.videobridge.xmpp.user.shard.MUC_JIDS=JvbBrewery@internal.auth.$XMPP_SERVER
EOT
}

function update_jicofo_config() {
  # Update Jicofo configuration
  cat <<EOT | sudo tee -a /etc/jitsi/jicofo/jicofo.conf
    jicofo {
        xmpp: {
            client: {
                client-proxy: "focus.$XMPP_SERVER"
                xmpp-domain: "$XMPP_SERVER"
                domain: "auth.$XMPP_SERVER"
                username: "focus"
                password: "nxp1K4TL7nwiomQR"
            }
            trusted-domains: [ "recorder.$XMPP_SERVER" ]
        }
        bridge: {
            brewery-jid: "JvbBrewery@internal.auth.$XMPP_SERVER"
        }
    }
EOT
}

function enable_moderator_credentials() {
  prosodyctl register $ADMIN_USER $XMPP_SERVER $ADMIN_PASSWORD
}

function install_letsencrypt() {
  echo $EMAIL | /usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh
}

function finalize_script() {
  case $SETUP_TYPE in
  "meet")
    # Stop and disable all Jitsi services except Prosody
    systemctl stop jitsi-videobridge2.service
    systemctl disable jitsi-videobridge2.service
    systemctl stop jicofo.service
    systemctl disable jicofo.service

    # Ensure Prosody is enabled and restarted with the new configuration
    systemctl enable prosody.service
    systemctl restart prosody.service
    ;;
  "jicofo")
    # Stop and disable all Jitsi services except jicofo
    systemctl stop jitsi-videobridge2.service
    systemctl disable jitsi-videobridge2.service
    systemctl stop prosody.service
    systemctl disable prosody.service

    # Ensure Jicofo is enabled and started
    systemctl enable jicofo.service
    systemctl restart jicofo.service
    ;;
  "jvb")

    # Specific setup for Jitsi Videobridge
    systemctl stop prosody.service
    systemctl disable prosody.service
    systemctl stop jicofo.service
    systemctl disable jicofo.service

    # Ensure Jitsi Videobridge is enabled and started
    systemctl enable jitsi-videobridge2.service
    systemctl restart jitsi-videobridge2.service
    ;;
  *)
    echo "Unknown setup type: $SETUP_TYPE"
    exit 1
    ;;
  esac
}

# Execute functions
update_system
set_host
add_prosody_repository
add_jitsi_repository
configure_jitsi
configure_prosody
configure_jitsi_videobridge
update_jicofo_config
enable_moderator_credentials
finalize_script
