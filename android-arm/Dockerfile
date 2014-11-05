FROM steeve/cross-compiler:android-arm
MAINTAINER Steeve Morin "steeve.morin@gmail.com"

RUN mkdir -p /build
WORKDIR /build

# Install Boost.System
RUN curl -L http://sourceforge.net/projects/boost/files/boost/1.56.0/boost_1_56_0.tar.bz2/download | tar xvj && \
    cd boost_1_56_0/ && \
    ./bootstrap.sh --prefix=${CROSS_ROOT} && \
    echo "using gcc : android : ${CROSS_TRIPLE}-c++ ;" > ${HOME}/user-config.jam && \
    ./b2 --with-date_time --with-system --prefix=${CROSS_ROOT} toolset=gcc-android link=static variant=release threading=multi target-os=linux install && \
    ${CROSS_TRIPLE}-ranlib ${CROSS_ROOT}/lib/*.a && \
    rm -rf ${HOME}/user-config.jam && \
    rm -rf ../boost_1_56_0/

# Install OpenSSL
RUN curl -L http://www.openssl.org/source/openssl-1.0.1i.tar.gz | tar xvz && \
    cd openssl-1.0.1i/ && \
    CROSS_COMPILE=${CROSS_TRIPLE}- ./Configure threads no-shared linux-armv4 --prefix=${CROSS_ROOT} && \
    make && make install && \
    ${CROSS_TRIPLE}-ranlib ${CROSS_ROOT}/lib/*.a && \
    rm -rf ../openssl-1.0.1i/

# Install libtorrent
RUN curl -L http://sourceforge.net/projects/libtorrent/files/libtorrent/libtorrent-rasterbar-1.0.2.tar.gz/download | tar xvz && \
    cd libtorrent-rasterbar-1.0.2/ && \
    sed -i 's/$PKG_CONFIG openssl --libs-only-/$PKG_CONFIG openssl --static --libs-only-/' ./configure && \
    sed -i -e s/Windows.h/windows.h/ -e s/Wincrypt.h/wincrypt.h/ ./ed25519/src/seed.cpp && \
    \
    PKG_CONFIG_PATH=${CROSS_ROOT}/lib/pkgconfig/ \
    CC=${CROSS_TRIPLE}-gcc CXX=${CROSS_TRIPLE}-g++ \
    CFLAGS="${CFLAGS} -O2 -DINT64_MAX=0x7fffffffffffffffLL -DINT16_MAX=32767 -DINT16_MIN=-32768" \
    CXXFLAGS="${CXXFLAGS} ${CFLAGS}" \
    ./configure --enable-static --disable-shared --disable-pool-allocators --disable-deprecated-functions \
    --host=${CROSS_TRIPLE} --prefix=${CROSS_ROOT} \
    --with-boost=${CROSS_ROOT} --with-boost-libdir=${CROSS_ROOT}/lib && \
    \
    make && make install && \
    ${CROSS_TRIPLE}-ranlib ${CROSS_ROOT}/lib/*.a && \
    rm -rf ../libtorrent-rasterbar-1.0.2/

# Install SWIG
RUN apt-get update && apt-get install -y libpcre3-dev && \
    curl -L http://sourceforge.net/projects/swig/files/swig/swig-3.0.2/swig-3.0.2.tar.gz/download | tar xvz && \
    cd swig-3.0.2/ && \
    ./configure && make && make install && \
    rm -rf ../swig-3.0.2/

# Install Golang
RUN cd /usr/local && \
    curl -L http://golang.org/dl/go1.3.3.src.tar.gz | tar xvz && \
    cd /usr/local/go/src && \
    GOOS=linux GOARCH=arm GOARM=6 ./make.bash
ENV PATH ${PATH}:/usr/local/go/bin

WORKDIR /
RUN rm -rf /build
