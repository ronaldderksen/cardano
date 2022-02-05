#! /usr/bin/env bash

# Submit the signed transaction in ${CARDANO_HOME}/tmp/tx.signed

set -uo pipefail

trap error_handler ERR

error_handler()
{
  echo "An error occured at line ${LINENO} in command $BASH_COMMAND"
}

CARDANO_HOME=$(cd $(dirname $0); /bin/pwd)

. ${CARDANO_HOME}/files/env

cardano-cli transaction submit \
--tx-file ${CARDANO_HOME}/tmp/tx.signed \
--mainnet
