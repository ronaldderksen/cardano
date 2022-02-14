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

rm -f ${CARDANO_TMP}/test.gpg ${CARDANO_TMP}/test

echo -n "Testing encrypt and decrypt"

gpg --quiet --encrypt -r "${GPG_RECIPIENT}" -o - ${0} >${CARDANO_TMP}/test.gpg || exit -1

gpg --quiet --decrypt -r "${GPG_RECIPIENT}" ${CARDANO_TMP}/test.gpg >${CARDANO_TMP}/test || exit -1

diff -q ${CARDANO_TMP}/test ${0} || exit -1
echo_green " OK"

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
  [ -e "${file}.gpg" -a ! -e "${file}" ] && c=$(expr ${c:=0} + 1)
done

if [ "${c:=-1}" = "${#FILES_TO_ENCRYPT[@]}" ]; then
  echo "All keys are already encrypted"
  exit 0
fi

# First encrypt all keys
for file in ${FILES_TO_ENCRYPT[@]}
do
  echo -n "Encrypting: ${file}"
  [ -e "${file}" -a -e "${file}.gpg" ] && rm -f ${file}.gpg
  gpg --quiet --encrypt -r "${GPG_RECIPIENT}" -o ${file}.gpg ${file} || exit -1
  echo_green " OK"
done

echo

# Second decrypt all keys
for file in ${FILES_TO_ENCRYPT[@]}
do
  echo -n "Decrypting: ${file}.gpg"
  gpg --quiet --decrypt -r "${GPG_RECIPIENT}" ${file}.gpg >/dev/null || exit -1
  echo_green " OK"
done

echo

# If we still did not exit, all is fine and we can shred the keys
for file in ${FILES_TO_ENCRYPT[@]}
do
  echo -n "Shredding: ${file}"
  shred --force --remove ${file}
  echo_green " OK"
done

echo_green "Success"
