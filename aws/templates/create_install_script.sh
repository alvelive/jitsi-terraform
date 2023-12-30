#!/bin/bash
set -e

cd /root
cat <<'INSTALL_SCRIPT' >install-jitsi.sh
${install_script}
INSTALL_SCRIPT

source ./install-jitsi.sh
