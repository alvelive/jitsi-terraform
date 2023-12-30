a#!/bin/bash
set -e

sudo su - ubuntu
cd ~

cat <<INSTALL_SCRIPT >install-jitsi.sh
${install_script}
INSTALL_SCRIPT

chmod +x install-jitsi.sh
. install-jitsi.sh
