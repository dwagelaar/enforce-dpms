#!/bin/bash
set -ueo pipefail

DIRNAME=$(dirname $0)

echo "Installing enforce-dpms"
cp "$DIRNAME/enforce-dpms.sh" /usr/local/sbin/
cp "$DIRNAME/enforce-dpms.service" /etc/systemd/user/
systemctl daemon-reload
echo "Please execute the following command:"
echo "  systemctl --user daemon-reload"
