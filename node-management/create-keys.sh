#! /usr/bin/env bash

# Register the staking node
# Usage: register.sh [deposit]
# Add the deposit parameter when registering for the first time.

set -euo pipefail

trap error_handler ERR

error_handler()
{
  echo "An error occured at line ${LINENO} in command $BASH_COMMAND"
}

CARDANO_HOME=$(cd $(dirname $0)/..; /bin/pwd)

. ${CARDANO_HOME}/env
. ${CARDANO_HOME}/include/common.inc

if [ ! -e ${CARDANO_HOME}/files-${CARDANO_NET}/payment.vkey -a ! -e ${CARDANO_HOME}/files-${CARDANO_NET}/payment.skey ]; then
  echo "Creating payment.vkey and payment.skey"
  cardano-cli address key-gen \
    --verification-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/payment.vkey \
    --signing-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/payment.skey
fi

if [ ! -e ${CARDANO_HOME}/files-${CARDANO_NET}/stake.vkey -a ! -e ${CARDANO_HOME}/files-${CARDANO_NET}/stake.skey ]; then
  echo "Creating stake.vkey and stake.skey"
  cardano-cli stake-address key-gen \
    --verification-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/stake.vkey \
    --signing-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/stake.skey
fi

if [ ! -e ${CARDANO_HOME}/files-${CARDANO_NET}/payment.addr ]; then
  echo "Creating payment.addr"
  cardano-cli address build \
    --payment-verification-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/payment.vkey \
    --stake-verification-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/stake.vkey \
    --out-file ${CARDANO_HOME}/files-${CARDANO_NET}/payment.addr \
    ${NET_PARAM}
fi

if [ ! -e ${CARDANO_HOME}/files-${CARDANO_NET}/stake.addr ]; then
  echo "Creating stake.addr"
  cardano-cli stake-address build \
      --stake-verification-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/stake.vkey \
      --out-file ${CARDANO_HOME}/files-${CARDANO_NET}/stake.addr \
      ${NET_PARAM}
fi

if [ ! -e ${CARDANO_HOME}/files-${CARDANO_NET}/${CARDANO_NET}-shelley-genesis.json ]; then
  echo "Curling ${CARDANO_NET}-shelley-genesis.json"
  curl -s -L --max-redirs 5 -o ${CARDANO_HOME}/files-${CARDANO_NET}/${CARDANO_NET}-shelley-genesis.json \
    https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/${CARDANO_NET}-shelley-genesis.json
fi

if [ ! -e ${CARDANO_HOME}/files-${CARDANO_NET}/cold.vkey -a ! -e ${CARDANO_HOME}/files-${CARDANO_NET}/cold.skey ]; then
  echo "Creating cold.vkey and cold.skey"
  cardano-cli node key-gen \
    --cold-verification-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/cold.vkey \
    --cold-signing-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/cold.skey \
    --operational-certificate-issue-counter-file ${CARDANO_HOME}/files-${CARDANO_NET}/cold.counter
fi

if [ ! -e ${CARDANO_HOME}/files-${CARDANO_NET}/vrf.vkey -a ! -e ${CARDANO_HOME}/files-${CARDANO_NET}/vrf.skey ]; then
  echo "Creating vrf.vkey and vrf.skey"
  cardano-cli node key-gen-VRF \
    --verification-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/vrf.vkey \
    --signing-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/vrf.skey
fi

if [ ! -e ${CARDANO_HOME}/files-${CARDANO_NET}/kes.vkey -a ! -e ${CARDANO_HOME}/files-${CARDANO_NET}/kes.skey ]; then
  echo "Creating kes.vkey and kes.skey"
  cardano-cli node key-gen-KES \
    --verification-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/kes.vkey \
    --signing-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/kes.skey
fi

if [ ! -e ${CARDANO_HOME}/files-${CARDANO_NET}/node.cert ]; then
  echo "Creating node.cert"
  tip=$(cardano-cli query tip ${NET_PARAM} |jq -r '.slot')
  slotsPerKESPeriod=$(cat ${CARDANO_HOME}/files-${CARDANO_NET}/${CARDANO_NET}-shelley-genesis.json |jq -r '.slotsPerKESPeriod')
  kes_period=$(expr ${tip} / ${slotsPerKESPeriod})
  cardano-cli node issue-op-cert \
    --kes-verification-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/kes.vkey \
    --cold-signing-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/cold.skey \
    --operational-certificate-issue-counter ${CARDANO_HOME}/files-${CARDANO_NET}/cold.counter \
    --kes-period ${kes_period} \
    --out-file ${CARDANO_HOME}/files-${CARDANO_NET}/node.cert
fi

if [ ! -e ${CARDANO_HOME}/files-${CARDANO_NET}/delegation.cert ]; then
  echo "Creating delegation.cert"
  cardano-cli stake-address delegation-certificate \
    --stake-verification-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/stake.vkey \
    --cold-verification-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/cold.vkey \
    --out-file ${CARDANO_HOME}/files-${CARDANO_NET}/delegation.cert
fi

