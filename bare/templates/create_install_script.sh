#!/bin/bash
set -e

cat <<'INSTALL_SCRIPT' >/home/ubuntu/install-jitsi.sh
${install_script}
INSTALL_SCRIPT

chown ubuntu:ubuntu /home/ubuntu/install-jitsi.sh
chmod +x /home/ubuntu/install-jitsi.sh
sudo -u ubuntu /home/ubuntu/install-jitsi.sh
