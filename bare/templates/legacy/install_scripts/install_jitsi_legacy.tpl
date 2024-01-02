#!/bin/bash
set -e

export HOSTNAME="${domain_name}"
export EMAIL="${email_address}"
ADMIN_USER="${admin_username}"
ADMIN_PASSWORD="${admin_password}"

function set_dns() {
  echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" >>/etc/resolv.conf
}

function disable_ipv6() {
  sysctl -w net.ipv6.conf.all.disable_ipv6=1
  sysctl -w net.ipv6.conf.default.disable_ipv6=1
}

function set_hostname() {
  hostnamectl set-hostname $HOSTNAME
  echo -e "127.0.0.1 localhost $HOSTNAME" >>/etc/hosts
}

function update_packages() {
  apt update
}

function install_java() {
  apt install -y openjdk-8-jre-headless
  echo "JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")" | sudo tee -a /etc/profile
  source /etc/profile
}

function install_nginx() {
  apt install -y nginx
  systemctl start nginx.service
  systemctl enable nginx.service
}

function add_jitsi_sources() {
  wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | sudo apt-key add -
  sh -c "echo 'deb https://download.jitsi.org stable/' > /etc/apt/sources.list.d/jitsi-stable.list"
}

function configure_system() {
  echo -e "DefaultLimitNOFILE=65000\nDefaultLimitNPROC=65000\nDefaultTasksMax=65000" >>/etc/systemd/system.conf
  systemctl daemon-reload
}

function configure_jitsi_install() {
  debconf-set-selections <<<$(echo 'jitsi-videobridge jitsi-videobridge/jvb-hostname string '$HOSTNAME)
  debconf-set-selections <<<'jitsi-meet-web-config   jitsi-meet/cert-choice  select  "Generate a new self-signed certificate"'
}

function debug_info() {
  echo $EMAIL >>/debug.txt
  echo $HOSTNAME >>/debug.txt
  cat /etc/resolv.conf >>/debug.txt
  whoami >>/debug.txt
  cat /etc/hosts >>/debug.txt
}

function install_jitsi() {
  apt install -y jitsi-meet >>/debug.txt
  echo $EMAIL | /usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh >>/debug.txt
}

function configure_prosody() {
  PROSODY_CONF_FILE=/etc/prosody/conf.d/$HOSTNAME.cfg.lua
  sed -e 's/authentication \= "anonymous"/authentication \= "internal_plain"/' -i $PROSODY_CONF_FILE
  # ... (add other configuration lines)
}

function configure_jitsi() {
  # ... (add other Jitsi configurations)
}

function enable_moderator_credentials() {
  prosodyctl --config /etc/prosody/prosody.cfg.lua register $ADMIN_USER $HOSTNAME $ADMIN_PASSWORD
}

function restart_services() {
  prosodyctl restart &>>/debug.txt
  /etc/init.d/jitsi-videobridge2 restart &>>/debug.txt
  /etc/init.d/jicofo restart &>>/debug.txt
}

function setup_complete() {
  echo "Setup completed" >>/debug.txt
  ${reboot_script}
}

# Execute functions
set_dns
disable_ipv6
set_hostname
update_packages
install_java
install_nginx
add_jitsi_sources
configure_system
configure_jitsi_install
debug_info
install_jitsi
configure_prosody
configure_jitsi
enable_moderator_credentials
restart_services
setup_complete
