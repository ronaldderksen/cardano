#! /usr/bin/env bash

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

for file in config.json byron-genesis.json shelley-genesis.json alonzo-genesis.json topology.json
do
  if [ ! -e ${CARDANO_FILES}/${CARDANO_NET}-${file} ]; then
    echo "Curling ${CARDANO_NET}-${file}"
    curl -s -L --max-redirs 5 -o ${CARDANO_FILES}/${CARDANO_NET}-${file} \
      https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/${CARDANO_NET}-${file}
  else
    echo "Skipping existing file ${file}"
  fi 
done
