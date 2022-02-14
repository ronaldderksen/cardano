#! /usr/bin/env bash

# Register the staking node
# Usage: register.sh [deposit]
# Add the deposit parameter when registering for the first time.

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

cardano-cli query tip ${NET_PARAM}
