#!/bin/sh
set -ueo pipefail
set -x

DIRNAME=$(dirname $0)

echo "Installing enforce-dpms"
cp "$DIRNAME/enforce-dpms.sh" /usr/local/sbin/
cp "$DIRNAME/enforce-dpms.service" /etc/systemd/user/
