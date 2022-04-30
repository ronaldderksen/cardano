#! /usr/bin/env bash

# Withdraw rewards to payment address
# Usage: withdraw-reward.sh

set -euo pipefail

trap error_handler ERR
trap shred_tmp_keys EXIT

error_handler()
{
  echo "An error occured in command $BASH_COMMAND"
}

CARDANO_HOME=$(cd $(dirname $0)/..; /bin/pwd)

. ${CARDANO_HOME}/env
. ${CARDANO_HOME}/include/common.inc

cardano-cli query stake-address-info \
  --address $(cat ${CARDANO_FILES}/stake.addr) \
  ${NET_PARAM} \
  --out-file ${CARDANO_TMP}/stake-address-info.json

rewardBalance=$(jq -r '.[].rewardAccountBalance' ${CARDANO_TMP}/stake-address-info.json)
ada=$(echo "${rewardBalance} / 1000000" |bc -l)
printf "Reward balance %d lovelace, %.4f ada\n" ${rewardBalance} ${ada}

cardano-cli >${CARDANO_TMP}/query.out \
  query utxo \
  --address $(cat ${CARDANO_FILES}/payment.addr) \
  ${NET_PARAM}

TxHash=$(grep lovelace ${CARDANO_TMP}/query.out |head -1 |awk -e '{print $1}')
TxIx=$(grep lovelace ${CARDANO_TMP}/query.out |head -1 |awk -e '{print $2}')
Amount=$(grep lovelace ${CARDANO_TMP}/query.out |head -1 |awk -e '{print $3}')

cardano-cli transaction build-raw \
  --tx-in ${TxHash}#${TxIx} \
  --tx-out $(cat ${CARDANO_FILES}/payment.addr)+0 \
  --invalid-hereafter 0 \
  --fee 0 \
  --out-file ${CARDANO_TMP}/tx.draft \
  --certificate-file ${CARDANO_FILES}/stake.cert

fee=$(cardano-cli transaction calculate-min-fee \
  --tx-body-file ${CARDANO_TMP}/tx.draft \
  --tx-in-count 1 \
  --tx-out-count 1 \
  --witness-count 2 \
  --byron-witness-count 0 \
  ${NET_PARAM} \
  --protocol-params-file ${CARDANO_FILES}/protocol.json | awk -e '{print $1}')

CHANGE=$(expr ${Amount} - ${fee} + ${rewardBalance})

tip=$(cardano-cli query tip ${NET_PARAM} |jq -r '.slot')
ttl=$(expr $tip + 2000)

#echo fee=$fee Amount=$Amount CHANGE=$CHANGE tip=$tip ttl=$ttl rewardBalance=$rewardBalance

cardano-cli transaction build-raw \
  --tx-in "${TxHash}#${TxIx}" \
  --tx-out $(cat ${CARDANO_FILES}/payment.addr)+${CHANGE} \
  --withdrawal $(cat ${CARDANO_FILES}/stake.addr)+${rewardBalance} \
  --invalid-hereafter ${ttl} \
  --fee ${fee} \
  --out-file ${CARDANO_TMP}/tx.raw

tmp_decrypt payment.skey stake.skey
cardano-cli transaction sign \
  --tx-body-file ${CARDANO_TMP}/tx.raw \
  --signing-key-file ${CARDANO_KEYS_DIR}/payment.skey \
  --signing-key-file ${CARDANO_KEYS_DIR}/stake.skey \
  ${NET_PARAM} \
  --out-file ${CARDANO_TMP}/tx.signed

shred_tmp_keys
echo_green "run ${CARDANO_HOME}/submit.sh to withdraw rewards on network"
