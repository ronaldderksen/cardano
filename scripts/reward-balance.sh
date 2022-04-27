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

cardano-cli query stake-address-info \
  --address $(cat ${CARDANO_FILES}/stake.addr) \
  ${NET_PARAM} \
  --out-file ${CARDANO_TMP}/stake-address-info.json

lovelace=$(jq -r '.[].rewardAccountBalance' ${CARDANO_TMP}/stake-address-info.json)
ada=$(echo "${lovelace} / 1000000" |bc -l)
printf "Reward balance %d lovelace, %.4f ada\n" ${lovelace} ${ada}
