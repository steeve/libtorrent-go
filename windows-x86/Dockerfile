FROM steeve/cross-compiler:windows-x86
MAINTAINER Steeve Morin "steeve.morin@gmail.com"

RUN mkdir -p /build
WORKDIR /build

# Install Boost.System
ENV BOOST_VERSION 1.58.0
RUN curl -L http://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION}/boost_`echo ${BOOST_VERSION} | sed 's/\\./_/g'`.tar.bz2/download | tar xvj && \
    cd boost_`echo ${BOOST_VERSION} | sed 's/\\./_/g'`/ && \
    ./bootstrap.sh --prefix=${CROSS_ROOT} && \
    echo "using gcc : mingw32 : ${CROSS_TRIPLE}-c++ ;" > ${HOME}/user-config.jam && \
    ./b2 --with-date_time --with-system --prefix=${CROSS_ROOT} toolset=gcc-mingw32 link=static variant=release threading=multi target-os=windows threadapi=win32 install && \
    rm -rf ${HOME}/user-config.jam && \
    rm -rf `pwd`

# Install OpenSSL
ENV OPENSSL_VERSION 1.0.2c
RUN curl -L http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz | tar xvz && \
    cd openssl-${OPENSSL_VERSION}/ && \
    CROSS_COMPILE=${CROSS_TRIPLE}- ./Configure threads no-shared mingw --prefix=${CROSS_ROOT} && \
    make && make install && \
    rm -rf `pwd`

# Somehow this is needed or libtorrent complains about boost
RUN ${CROSS_TRIPLE}-ranlib ${CROSS_ROOT}/lib/*.a

# Install libtorrent
# Changes:
# - define WIN32, _UNICODE, IPV6_TCLASS=39
ENV LIBTORRENT_VERSION 1.0.5
RUN curl -L http://sourceforge.net/projects/libtorrent/files/libtorrent/libtorrent-rasterbar-${LIBTORRENT_VERSION}.tar.gz/download | tar xvz && \
    cd libtorrent-rasterbar-${LIBTORRENT_VERSION}/ && \
    sed -i 's/$PKG_CONFIG openssl --libs-only-/$PKG_CONFIG openssl --static --libs-only-/' ./configure && \
    sed -i -e s/Windows.h/windows.h/ -e s/Wincrypt.h/wincrypt.h/ ./ed25519/src/seed.cpp && \
    \
    PKG_CONFIG_PATH=${CROSS_ROOT}/lib/pkgconfig/ \
    CC=${CROSS_TRIPLE}-cc CXX=${CROSS_TRIPLE}-c++ \
    CFLAGS="${CFLAGS} -O2 -DUNICODE -D_UNICODE -DWIN32 -DIPV6_TCLASS=39" \
    CXXFLAGS="${CXXFLAGS} ${CFLAGS}" \
    ./configure --enable-static --disable-shared --disable-deprecated-functions \
    --host=${CROSS_TRIPLE} --prefix=${CROSS_ROOT} \
    --with-boost=${CROSS_ROOT} --with-boost-libdir=${CROSS_ROOT}/lib && \
    \
    make && make install && \
    rm -rf `pwd`

# Install SWIG
# Need to build from >3.0.2 because Go 1.4.2
ENV SWIG_VERSION 5c57a8c877f88c9388b68067d665c63546244ba0
RUN apt-get update && apt-get install -y automake libpcre3-dev bison yodl
RUN curl -L https://github.com/swig/swig/archive/${SWIG_VERSION}.tar.gz | tar xvz && \
    cd swig-${SWIG_VERSION}/ && \
    curl -L https://github.com/steeve/swig/compare/swig:${SWIG_VERSION}...packed-struct-libtorrent.diff | patch -p1 && \
    curl -L https://github.com/steeve/swig/compare/swig:${SWIG_VERSION}...fix-windows.diff | patch -p1 && \
    ./autogen.sh && \
    ./configure && make && make install && \
    rm -rf `pwd`

# Install Golang
ENV GO_VERSION 1.4.2
RUN cd /usr/local && \
    curl -L http://golang.org/dl/go${GO_VERSION}.src.tar.gz | tar xvz && \
    cd /usr/local/go/src && \
    CC_FOR_TARGET=${CROSS_TRIPLE}-cc CXX_FOR_TARGET=${CROSS_TRIPLE}-c++ GOOS=windows GOARCH=386 CGO_ENABLED=1 ./make.bash
ENV PATH ${PATH}:/usr/local/go/bin

WORKDIR /
RUN rm -rf /build
