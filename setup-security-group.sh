#!/bin/bash

set -e
set -u

cf login -a "${CF_API_URL}" -u "${CF_USERNAME}" -p "${CF_PASSWORD}" -o "${CF_ORGANIZATION}" -s "${CF_SPACE}"

RIEMANN_ADDR=$(getent hosts "${RIEMANN_HOST}" | awk '{ print $1 }')

cat << EOF > metrics-network.json
[
  {
    "destination": "${RIEMANN_ADDR}",
    "ports": "${RIEMANN_PORT:-5555}",
    "protocol": "tcp"
  }
]
EOF

cf create-security-group metrics-network ./metrics-network.json
cf update-security-group metrics-network ./metrics-network.json
cf bind-security-group metrics-network "${CF_ORGANIZATION}" "${CF_SPACE}"
