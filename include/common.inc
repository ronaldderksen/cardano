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
