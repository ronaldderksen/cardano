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

[ "${1:-}" = deposit ] && DEPOSIT=1 || DEPOSIT=0

gen_hash()
{
  URL=$1
  curl 2>/dev/null ${URL} >${CARDANO_HOME}/tmp/md.json || exit
  cardano-cli stake-pool metadata-hash --pool-metadata-file ${CARDANO_HOME}/tmp/md.json
}

cardano-cli stake-pool registration-certificate \
  --cold-verification-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/cold.vkey \
  --vrf-verification-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/vrf.vkey \
  --pool-pledge ${POOL_PLEDGE} \
  --pool-cost ${POOL_COSTS} \
  --pool-margin ${POOL_MARGIN} \
  --pool-reward-account-verification-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/stake.vkey \
  --pool-owner-stake-verification-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/stake.vkey \
  ${NET_PARAM} \
  --pool-relay-ipv4 ${POOL_RELAY_IPV4} \
  --pool-relay-port ${POOL_RELAY_PORT} \
  --single-host-pool-relay ${SINGLE_HOST_POOL_RELAY} \
  --metadata-url ${META_DATA_URL} \
  --metadata-hash $(gen_hash ${META_DATA_URL}) \
  --out-file ${CARDANO_HOME}/files-${CARDANO_NET}/pool-registration.cert

cardano-cli >${CARDANO_HOME}/tmp/query.out \
  query utxo \
  --address $(cat ${CARDANO_HOME}/files-${CARDANO_NET}/payment.addr) \
  ${NET_PARAM}

TxHash=$(grep lovelace ${CARDANO_HOME}/tmp/query.out |head -1 |awk -e '{print $1}')
TxIx=$(grep lovelace ${CARDANO_HOME}/tmp/query.out |head -1 |awk -e '{print $2}')
Amount=$(grep lovelace ${CARDANO_HOME}/tmp/query.out |head -1 |awk -e '{print $3}')

cardano-cli transaction build-raw \
  --tx-in "${TxHash}#${TxIx}" \
  --tx-out $(cat ${CARDANO_HOME}/files-${CARDANO_NET}/payment.addr)+0 \
  --invalid-hereafter 0 \
  --fee 0 \
  --out-file ${CARDANO_HOME}/tmp/tx.draft \
  --certificate-file ${CARDANO_HOME}/files-${CARDANO_NET}/pool-registration.cert \
  --certificate-file ${CARDANO_HOME}/files-${CARDANO_NET}/delegation.cert

cardano-cli query protocol-parameters \
  ${NET_PARAM} \
  --out-file ${CARDANO_HOME}/tmp/protocol.json

fee=$(cardano-cli transaction calculate-min-fee \
  --tx-body-file ${CARDANO_HOME}/tmp/tx.draft \
  --tx-in-count 1 \
  --tx-out-count 1 \
  --witness-count 3 \
  --byron-witness-count 0 \
  ${NET_PARAM} \
  --protocol-params-file ${CARDANO_HOME}/tmp/protocol.json | awk -e '{print $1}')

tip=$(cardano-cli query tip ${NET_PARAM} |jq -r '.slot')
ttl=$(expr $tip + 2000)

if [ "${DEPOSIT}" = 1 ]; then
  stakePoolDeposit=$(cat ${CARDANO_HOME}/files-${CARDANO_NET}/protocol.json |jq -r '.stakePoolDeposit')
else
  stakePoolDeposit=0
fi

CHANGE=$(expr $Amount - $stakePoolDeposit - $fee)

cardano-cli transaction build-raw \
  --tx-in "${TxHash}#${TxIx}" \
  --tx-out $(cat ${CARDANO_HOME}/files-${CARDANO_NET}/payment.addr)+${CHANGE} \
  --invalid-hereafter ${ttl} \
  --fee ${fee} \
  --out-file ${CARDANO_HOME}/tmp/tx.raw \
  --certificate-file ${CARDANO_HOME}/files-${CARDANO_NET}/pool-registration.cert \
  --certificate-file ${CARDANO_HOME}/files-${CARDANO_NET}/delegation.cert

cardano-cli transaction sign \
  --tx-body-file ${CARDANO_HOME}/tmp/tx.raw \
  --signing-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/payment.skey \
  --signing-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/stake.skey \
  --signing-key-file ${CARDANO_HOME}/files-${CARDANO_NET}/cold.skey \
  ${NET_PARAM} \
  --out-file ${CARDANO_HOME}/tmp/tx.signed

echo "run ${CARDANO_HOME}/submit.sh to register pool on network (deposit=${stakePoolDeposit})"
