if [ "${CARDANO_NET}" = mainnet ]; then
  NET_PARAM="--mainnet"
elif [ "${CARDANO_NET}" = testnet ]; then
  NET_PARAM="--testnet-magic 1097911063"
fi

# CARDANO_FILES and CARDANO_TMP can be overwritten in env
[ -z "${CARDANO_FILES:-}" ] && CARDANO_FILES="${CARDANO_HOME}/files-${CARDANO_NET}"
[ -z "${CARDANO_TMP:-}" ] && CARDANO_TMP="${CARDANO_HOME}/tmp"

[ ! -d "${CARDANO_FILES}" ] && mkdir -p ${CARDANO_FILES} || true
[ ! -d "${CARDANO_TMP}" ] && mkdir -p ${CARDANO_TMP} || true

[ -z "$(ls 2>/dev/null ${CARDANO_FILES}/*.gpg)" ] && CARDANO_KEYS_DIR=${CARDANO_FILES} || CARDANO_KEYS_DIR=${CARDANO_TMP}

echo_red()
{
  echo -e "\033[0;31m$*\033[0m"
}

echo_green()
{
  echo -e "\033[0;32m$*\033[0m"
}

shred_tmp_keys()
{
  for file in $(ls 2>/dev/null ${CARDANO_TMP}/*key)
  do
    echo -n "Shredding: ${file}"
    shred --force --remove ${file}
    echo_green " OK"
  done
}

tmp_decrypt()
{
  for arg in "$@"
  do
    file=${CARDANO_FILES}/${arg}
    echo -n "Decrypting: ${file}"
    gpg --quiet --decrypt -r "${GPG_RECIPIENT}" ${file}.gpg >${CARDANO_TMP}/${arg}
    echo_green " OK"
  done
}
