#! /usr/bin/env bash

# This script copies the keys/cert (kes.skey vrf.skey node.cert)
# to the block producing node.
# set variable 'PRODUCER_NODE', in env file, to producer host name or IP
# Usage: copy-producer-keys.sh

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

tmp_decrypt kes.skey vrf.skey

REMOTE_KEYS_DIR=${PRODUCER_KEYS_DIR:-/opt/cardano/keys}
for file in kes.skey vrf.skey node.cert
do
  [ "${file}" = "node.cert" ] && FROM=${CARDANO_FILES}/${file} || FROM=${CARDANO_KEYS_DIR}/${file}
  TO=${PRODUCER_NODE}:${REMOTE_KEYS_DIR}
  echo "Copy ${FROM} to ${TO}"
  scp -q ${FROM} ${TO}
done

shred_tmp_keys
echo_green "Success"
