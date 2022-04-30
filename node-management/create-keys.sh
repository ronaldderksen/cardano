#! /usr/bin/env bash

# Create all keys needed to run and manage cardano nodes
# Usage: create-keys.sh

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

if [ ! -e ${CARDANO_FILES}/payment.vkey -a ! -e ${CARDANO_FILES}/payment.skey ]; then
  echo "Creating payment.vkey and payment.skey"
  cardano-cli address key-gen \
    --verification-key-file ${CARDANO_FILES}/payment.vkey \
    --signing-key-file ${CARDANO_FILES}/payment.skey
fi

if [ ! -e ${CARDANO_FILES}/stake.vkey -a ! -e ${CARDANO_FILES}/stake.skey ]; then
  echo "Creating stake.vkey and stake.skey"
  cardano-cli stake-address key-gen \
    --verification-key-file ${CARDANO_FILES}/stake.vkey \
    --signing-key-file ${CARDANO_FILES}/stake.skey
fi

if [ ! -e ${CARDANO_FILES}/payment.addr ]; then
  echo "Creating payment.addr"
  cardano-cli address build \
    --payment-verification-key-file ${CARDANO_FILES}/payment.vkey \
    --stake-verification-key-file ${CARDANO_FILES}/stake.vkey \
    --out-file ${CARDANO_FILES}/payment.addr \
    ${NET_PARAM}
fi

if [ ! -e ${CARDANO_FILES}/stake.addr ]; then
  echo "Creating stake.addr"
  cardano-cli stake-address build \
      --stake-verification-key-file ${CARDANO_FILES}/stake.vkey \
      --out-file ${CARDANO_FILES}/stake.addr \
      ${NET_PARAM}
fi

if [ ! -e ${CARDANO_FILES}/${CARDANO_NET}-shelley-genesis.json ]; then
  echo "Curling ${CARDANO_NET}-shelley-genesis.json"
  curl -s -L --max-redirs 5 -o ${CARDANO_FILES}/${CARDANO_NET}-shelley-genesis.json \
    https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/${CARDANO_NET}-shelley-genesis.json
fi

if [ ! -e ${CARDANO_FILES}/cold.vkey -a ! -e ${CARDANO_FILES}/cold.skey ]; then
  echo "Creating cold.vkey and cold.skey"
  cardano-cli node key-gen \
    --cold-verification-key-file ${CARDANO_FILES}/cold.vkey \
    --cold-signing-key-file ${CARDANO_FILES}/cold.skey \
    --operational-certificate-issue-counter-file ${CARDANO_FILES}/cold.counter
fi

if [ ! -e ${CARDANO_FILES}/vrf.vkey -a ! -e ${CARDANO_FILES}/vrf.skey ]; then
  echo "Creating vrf.vkey and vrf.skey"
  cardano-cli node key-gen-VRF \
    --verification-key-file ${CARDANO_FILES}/vrf.vkey \
    --signing-key-file ${CARDANO_FILES}/vrf.skey
fi

if [ ! -e ${CARDANO_FILES}/kes.vkey -a ! -e ${CARDANO_FILES}/kes.skey ]; then
  echo "Creating kes.vkey and kes.skey"
  cardano-cli node key-gen-KES \
    --verification-key-file ${CARDANO_FILES}/kes.vkey \
    --signing-key-file ${CARDANO_FILES}/kes.skey
fi

if [ ! -e ${CARDANO_FILES}/node.cert ]; then
  echo "Creating node.cert"
  tip=$(cardano-cli query tip ${NET_PARAM} |jq -r '.slot')
  slotsPerKESPeriod=$(cat ${CARDANO_FILES}/${CARDANO_NET}-shelley-genesis.json |jq -r '.slotsPerKESPeriod')
  kes_period=$(expr ${tip} / ${slotsPerKESPeriod})
  cardano-cli node issue-op-cert \
    --kes-verification-key-file ${CARDANO_FILES}/kes.vkey \
    --cold-signing-key-file ${CARDANO_FILES}/cold.skey \
    --operational-certificate-issue-counter ${CARDANO_FILES}/cold.counter \
    --kes-period ${kes_period} \
    --out-file ${CARDANO_FILES}/node.cert
fi

if [ ! -e ${CARDANO_FILES}/delegation.cert ]; then
  echo "Creating delegation.cert"
  cardano-cli stake-address delegation-certificate \
    --stake-verification-key-file ${CARDANO_FILES}/stake.vkey \
    --cold-verification-key-file ${CARDANO_FILES}/cold.vkey \
    --out-file ${CARDANO_FILES}/delegation.cert
fi

echo_green "Success"
