#/usr/bin/env bash

# Encrypt all keys
# Usage: encrypt-keys.sh

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

FILES_TO_ENCRYPT=(
  ${CARDANO_FILES}/payment.vkey
  ${CARDANO_FILES}/payment.skey
  ${CARDANO_FILES}/stake.vkey
  ${CARDANO_FILES}/stake.skey
  ${CARDANO_FILES}/cold.vkey
  ${CARDANO_FILES}/cold.skey
  ${CARDANO_FILES}/kes.vkey
  ${CARDANO_FILES}/kes.skey
  ${CARDANO_FILES}/vrf.vkey
  ${CARDANO_FILES}/vrf.skey
)

for file in ${FILES_TO_ENCRYPT[@]}
do
  [ -e "${file}" -a ! -e "${file}.gpg" ] && c=$(expr ${c:=0} + 1)
done

if [ "${c:=-1}" = "${#FILES_TO_ENCRYPT[@]}" ]; then
  echo "All keys are already decrypted"
  exit 0
fi

# First decrypt all keys
for file in ${FILES_TO_ENCRYPT[@]}
do
  echo -n "Decrypting: ${file}.gpg"
  gpg --quiet --decrypt -r "${GPG_RECIPIENT}" ${file}.gpg >${file} || exit -1
  echo_green " OK"
done

echo

# If did not exit, all is fine and we can delete encrypted files
for file in ${FILES_TO_ENCRYPT[@]}
do
  echo -n "Deleting: ${file}.gpg"
  rm -f ${file}.gpg
  echo_green " OK"
done

echo_green "Success"
