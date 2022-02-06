if [ "${CARDANO_NET}" = mainnet ]; then
  NET_PARAM="--mainnet"
elif [ "${CARDANO_NET}" = testnet ]; then
  NET_PARAM="--testnet-magic 1097911063"
fi
