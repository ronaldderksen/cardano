#! /usr/bin/env bash

VERSION=$(curl -s https://api.github.com/repos/input-output-hk/cardano-node/releases/latest | jq -r .tag_name)
RELEASE=$(dnf 2>/dev/null info cardano-${VERSION} |grep "^Release" |grep -oP "(?<=: )\d+")
RELEASE=$(expr ${RELEASE} + 1)
[ "${RELEASE}" -gt 0 ] 2>/dev/null || RELEASE=1

echo VERSION=$VERSION RELEASE=$RELEASE
docker build --build-arg VERSION=${VERSION} --build-arg RELEASE=$RELEASE -t cardano . || exit 1

id=$(docker create cardano)
mkdir -p rpms
docker cp $id:/root/rpmbuild/RPMS/x86_64 rpms
docker rm -v $id

rpm --define "_gpg_name RPM Signing Key" --addsign rpms/x86_64/*
