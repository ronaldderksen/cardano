#! /usr/bin/env bash

# This script creates new kes key and node.cert
# Usage: new-kes-key.sh

set -euo pipefail

trap error_handler ERR
trap shred_tmp_keys EXIT

error_handler()
{
  echo "An error occured at line ${LINENO} in command $BASH_COMMAND"
}

CARDANO_HOME=$(cd $(dirname $0)/..; /bin/pwd)

. ${CARDANO_HOME}/env
. ${CARDANO_HOME}/include/common.inc

echo "Creating kes.vkey and kes.skey"
cardano-cli node key-gen-KES \
  --verification-key-file ${CARDANO_FILES}/kes.vkey \
  --signing-key-file ${CARDANO_FILES}/kes.skey

tmp_decrypt cold.skey

echo "Creating node.cert"
tip=$(cardano-cli query tip ${NET_PARAM} |jq -r '.slot')
slotsPerKESPeriod=$(cat ${CARDANO_FILES}/${CARDANO_NET}-shelley-genesis.json |jq -r '.slotsPerKESPeriod')
kes_period=$(expr ${tip} / ${slotsPerKESPeriod})
cardano-cli node issue-op-cert \
  --kes-verification-key-file ${CARDANO_FILES}/kes.vkey \
  --cold-signing-key-file ${CARDANO_KEYS_DIR}/cold.skey \
  --operational-certificate-issue-counter ${CARDANO_FILES}/cold.counter \
  --kes-period ${kes_period} \
  --out-file ${CARDANO_FILES}/node.cert

${CARDANO_HOME}/scripts/encrypt-keys.sh kes.vkey kes.skey

echo_green "Success"
