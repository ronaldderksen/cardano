#! /usr/bin/env bash

# Usage: sent-ada-from-payment.sh <ADA> <Destination address>

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

ada_to_sent=${1}
dest_address=${2}

cardano-cli query utxo \
  --address $(cat ${CARDANO_FILES}/payment.addr) \
  ${NET_PARAM} \
  --out-file ${CARDANO_TMP}/utxo.json

declare -A tx_hash
hashes=()
for TxHash in $(jq -r 'keys_unsorted[]' ${CARDANO_TMP}/utxo.json)
do
  lovelace=$(jq ".\"${TxHash}\".value.lovelace" ${CARDANO_TMP}/utxo.json)
  tx_hash["${TxHash}"]=${lovelace}
  hashes[${#hashes[@]}]=${TxHash}
  #echo "${TxHash} ${lovelace}"
done

inputs=1
while :
do
  declare -A tx_in
  while [ "${c:=0}" -lt "${inputs}" ]
  do
    tx_in[$c]="--tx-in ${hashes[$c]}"
    balance=$(expr ${balance:=0} + ${tx_hash[${hashes[$c]}]})
    c=$(expr $c + 1)
  done
  cardano-cli transaction build-raw \
    ${tx_in[@]} \
    --tx-out $(cat ${CARDANO_FILES}/payment.addr)+0 \
    --tx-out ${dest_address}+0 \
    --invalid-hereafter 0 \
    --fee 0 \
    --out-file ${CARDANO_TMP}/tx.draft

  fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file ${CARDANO_TMP}/tx.draft \
    --tx-in-count ${inputs} \
    --tx-out-count 2 \
    --witness-count 1 \
    --byron-witness-count 0 \
    ${NET_PARAM} \
    --protocol-params-file ${CARDANO_FILES}/protocol.json | awk -e '{print $1}')

  tip=$(cardano-cli query tip ${NET_PARAM} |jq -r '.slot')
  ttl=$(expr $tip + 2000)

  lovelace_to_sent=$(echo "${ada_to_sent} * 1000000" |bc |cut -d. -f1)

  remainder=$(expr ${balance} - ${lovelace_to_sent} - ${fee})
  [ "${remainder}" -gt 0 ] && break
  if [ "${inputs}" -eq "${#hashes[@]}" ]; then
    echo "Not enough funds"
    exit 1
  fi
  inputs=$(expr ${inputs} + 1)
done

echo inputs=$inputs fee=$fee tip=$tip ttl=$ttl lovelace_to_sent=$lovelace_to_sent remainder=$remainder balance=$balance

cardano-cli transaction build-raw \
  ${tx_in[@]} \
  --tx-out $(cat ${CARDANO_FILES}/payment.addr)+${remainder} \
  --tx-out ${dest_address}+${lovelace_to_sent} \
  --invalid-hereafter ${ttl} \
  --fee ${fee} \
  --out-file ${CARDANO_TMP}/tx.raw

tmp_decrypt payment.skey
cardano-cli transaction sign \
  --tx-body-file ${CARDANO_TMP}/tx.raw \
  --signing-key-file ${CARDANO_KEYS_DIR}/payment.skey \
  ${NET_PARAM} \
  --out-file ${CARDANO_TMP}/tx.signed

shred_tmp_keys
echo_green "run ${CARDANO_HOME}/submit.sh to sent ${ada_to_sent} ADA to ${dest_address}"
