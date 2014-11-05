FROM steeve/cross-compiler:linux-arm
MAINTAINER Steeve Morin "steeve.morin@gmail.com"

RUN mkdir -p /build
WORKDIR /build

# Install Boost.System
ENV BOOST_VERSION 1.57.0
RUN curl -L http://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION}/boost_`echo ${BOOST_VERSION} | sed 's/\\./_/g'`.tar.bz2/download | tar xvj && \
    cd boost_`echo ${BOOST_VERSION} | sed 's/\\./_/g'`/ && \
    ./bootstrap.sh --prefix=${CROSS_ROOT} && \
    echo "using gcc : linux : ${CROSS_TRIPLE}-c++ ;" > ${HOME}/user-config.jam && \
    ./b2 --with-date_time --with-system --prefix=${CROSS_ROOT} toolset=gcc-linux link=static variant=release threading=multi target-os=linux install && \
    ${CROSS_TRIPLE}-ranlib ${CROSS_ROOT}/lib/*.a && \
    rm -rf ${HOME}/user-config.jam && \
    rm -rf ../boost_`echo ${BOOST_VERSION} | sed 's/\\./_/g'`/

# Install OpenSSL
ENV OPENSSL_VERSION 1.0.1j
RUN curl -L http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz | tar xvz && \
    cd openssl-${OPENSSL_VERSION}/ && \
    CROSS_COMPILE=${CROSS_TRIPLE}- ./Configure threads no-shared linux-armv4 --prefix=${CROSS_ROOT} && \
    make && make install && \
    ${CROSS_TRIPLE}-ranlib ${CROSS_ROOT}/lib/*.a && \
    rm -rf ../openssl-${OPENSSL_VERSION}/

# Install libtorrent
ENV LIBTORRENT_VERSION 1.0.2
RUN curl -L http://sourceforge.net/projects/libtorrent/files/libtorrent/libtorrent-rasterbar-${LIBTORRENT_VERSION}.tar.gz/download | tar xvz && \
    cd libtorrent-rasterbar-${LIBTORRENT_VERSION}/ && \
    sed -i 's/$PKG_CONFIG openssl --libs-only-/$PKG_CONFIG openssl --static --libs-only-/' ./configure && \
    sed -i -e s/Windows.h/windows.h/ -e s/Wincrypt.h/wincrypt.h/ ./ed25519/src/seed.cpp && \
    \
    PKG_CONFIG_PATH=${CROSS_ROOT}/lib/pkgconfig/ \
    CC=${CROSS_TRIPLE}-gcc CXX=${CROSS_TRIPLE}-g++ \
    CFLAGS="${CFLAGS} -O2" \
    CXXFLAGS="${CXXFLAGS} ${CFLAGS}" \
    ./configure --enable-static --disable-shared --disable-deprecated-functions \
    --host=${CROSS_TRIPLE} --prefix=${CROSS_ROOT} \
    --with-boost=${CROSS_ROOT} --with-boost-libdir=${CROSS_ROOT}/lib && \
    \
    make && make install && \
    ${CROSS_TRIPLE}-ranlib ${CROSS_ROOT}/lib/*.a && \
    rm -rf ../libtorrent-rasterbar-${LIBTORRENT_VERSION}/

# Install SWIG
# Need to build from >3.0.2 because Go 1.4beta1
# Also, revert https://github.com/swig/swig/commit/255c929c5636f54c16261bd92b8eea2005d61b11 as it breaks boost
RUN apt-get update && apt-get install -y libpcre3-dev bison yodl
RUN curl -L https://github.com/swig/swig/archive/master.tar.gz | tar xvz && \
    cd swig-master/ && \
    curl -L https://github.com/swig/swig/commit/255c929c5636f54c16261bd92b8eea2005d61b11.diff | patch -Rp1 && \
    curl -L https://github.com/steeve/swig/commit/c9b687108ec3550103db6525b4860ba21a485ecd.diff | patch -p1 && \
    curl -L https://github.com/steeve/swig/commit/e70fce1c1cf928564f009ea512c6c3acb97ace16.diff | patch -p1 && \
    curl -L https://github.com/steeve/swig/commit/3ff0a187e8ed4bc406c17835db8a2bdb22bb0203.diff | patch -p1 && \
    ./autogen.sh && \
    ./configure && make && make install && \
    rm -rf ../swig-master/

# Install Golang
ENV GO_VERSION 1.4beta1
RUN cd /usr/local && \
    curl -L http://golang.org/dl/go${GO_VERSION}.src.tar.gz | tar xvz && \
    cd /usr/local/go/src && \
    GOOS=linux GOARCH=arm GOARM=6 ./make.bash
ENV PATH ${PATH}:/usr/local/go/bin

# Build CGO
RUN CC=${CROSS_TRIPLE}-cc GOOS=linux GOARCH=arm GOARM=6 CGO_ENABLED=1 go install -v runtime/cgo

WORKDIR /
RUN rm -rf /build
