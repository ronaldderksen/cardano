#! /usr/bin/env bash

# Submit the signed transaction in ${CARDANO_TMP}/tx.signed
# the file tx.signed is removed when transaction was successful

set -euo pipefail

trap error_handler ERR

error_handler()
{
  echo "An error occured at line ${LINENO} in command $BASH_COMMAND"
}

CARDANO_HOME=$(cd $(dirname $0); /bin/pwd)

. ${CARDANO_HOME}/env
. ${CARDANO_HOME}/include/common.inc

cardano-cli transaction submit \
  --tx-file ${CARDANO_TMP}/tx.signed \
  ${NET_PARAM} && rm -f ${CARDANO_TMP}/tx.signed
