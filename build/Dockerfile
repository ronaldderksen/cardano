FROM rockylinux:latest

ARG VERSION
ARG RELEASE

RUN yum update -y && \
    yum -y install git gcc gcc-c++ tmux gmp-devel make tar xz wget zlib-devel libtool autoconf && \
    yum -y install systemd-devel ncurses-devel ncurses-compat-libs which jq openssl-devel && \
    yum -y install rpm-build

RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

ENV PATH=/bin:/usr/bin:/sbin:/usr/sbin:/root/.ghcup/bin:/root/.cabal/bin
RUN ghcup --version

RUN ghcup install ghc 8.10.7 && ghcup set ghc 8.10.7
RUN ghcup install cabal 3.6.2.0 && ghcup set cabal 3.6.2.0

RUN ghc --version
RUN cabal --version

RUN mkdir -p $HOME/src
RUN cd $HOME/src && \
    git clone https://github.com/input-output-hk/libsodium && \
    cd libsodium && \
    git checkout 66f017f1 && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"

RUN cd $HOME/src && \
    git clone https://github.com/bitcoin-core/secp256k1 && \
    cd secp256k1 && \
    git checkout ac83be33 && \
    ./autogen.sh && \
    ./configure --enable-module-schnorrsig --enable-experimental && \
    make && \
    make install

RUN cd $HOME/src && \
    git clone https://github.com/input-output-hk/cardano-node.git && \
    cd cardano-node && \
    git fetch --all --recurse-submodules --tags && \
    git checkout $VERSION && \
    echo "package cardano-crypto-praos" >cabal.project.local && \
    echo "    flags: -external-libsodium-vrf" >>cabal.project.local && \
    echo "with-compiler: ghc-8.10.7" >> cabal.project.local && \
    cabal configure --with-compiler=ghc-8.10.7 && \
    cabal build all && \
    mkdir -p $HOME/.local/bin && \
    cp -p "$(./scripts/bin-path.sh cardano-node)" $HOME/.local/bin/ && \
    cp -p "$(./scripts/bin-path.sh cardano-cli)" $HOME/.local/bin/

COPY cardano.spec /root/

RUN sed -i "s|_VERSION_|$VERSION|" /root/cardano.spec
RUN sed -i "s|_RELEASE_|$RELEASE|" /root/cardano.spec

RUN rpmbuild -bb /root/cardano.spec
