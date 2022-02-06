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
