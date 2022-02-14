#! /usr/bin/env bash

# Usage: sent-ada-from-payment.sh <ADA> <Destination address>

set -euo pipefail

trap error_handler ERR

error_handler()
{
  echo "An error occured at line ${LINENO} in command $BASH_COMMAND"
}

CARDANO_HOME=$(cd $(dirname $0)/..; /bin/pwd)

. ${CARDANO_HOME}/env
. ${CARDANO_HOME}/include/common.inc

cardano-cli query utxo \
  --address $(cat ${CARDANO_FILES}/payment.addr) \
  ${NET_PARAM} \
  --out-file ${CARDANO_TMP}/utxo.json

for TxHash in $(jq -r 'keys_unsorted[]' ${CARDANO_TMP}/utxo.json)
do
  lovelace=$(jq ".\"${TxHash}\".value.lovelace" ${CARDANO_TMP}/utxo.json)
  total=$(expr ${total:=0} + ${lovelace})
  ada=$(echo "scale=4; ${lovelace} / 1000000" |bc -l)
  printf "%s %15d lovelace\n" ${TxHash} ${lovelace}
done

ada=$(echo "${total} / 1000000" |bc -l)
printf "\nTotal %d lovelace, %.4f ada\n" ${total} ${ada}
