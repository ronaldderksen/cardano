#! /usr/bin/env bash

# Run a cardano-node

set -euo pipefail

trap error_handler ERR

error_handler()
{
  echo "An error occured at line ${LINENO} in command $BASH_COMMAND"
}

# Adjust for mainnet
CARDANO_NET=testnet

CARDANO_DIR=/opt/cardano
export CARDANO_NODE_SOCKET_PATH=${CARDANO_DIR}/run/cardano-node.socket

PATH=${CARDANO_DIR}/bin:/usr/bin:/usr/sbin

if [ -e ${CARDANO_DIR}/keys/kes.skey -a -e ${CARDANO_DIR}/keys/vrf.skey -a -e ${CARDANO_DIR}/keys/node.cert ]; then
  EXTRA_PARAMS="--shelley-kes-key ${CARDANO_DIR}/keys/kes.skey \
    --shelley-vrf-key ${CARDANO_DIR}/keys/vrf.skey \
    --shelley-operational-certificate ${CARDANO_DIR}/keys/node.cert"
fi

cardano-node run \
    --config ${CARDANO_DIR}/config/${CARDANO_NET}-config.json \
    --database-path ${CARDANO_DIR}/data/db \
    --topology ${CARDANO_DIR}/config/${CARDANO_NET}-topology.json \
    --host-addr 0.0.0.0 \
    --port 3001 \
    --socket-path ${CARDANO_NODE_SOCKET_PATH} ${EXTRA_PARAMS:-}
