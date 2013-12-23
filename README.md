libtorrent-go
=============

SWIG Go bindings for libtorrent-rasterbar


Windows
=======
```
export CROSSHOST=i586-mingw32
export CROSSHOME=/usr/local/gcc-4.8.0-mingw32
export PATH=$CROSSHOME/bin:$PATH
export PKG_CONFIG_LIBDIR=$CROSSHOME/lib/pkgconfig
export PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR
export CFLAGS="-I$CROSSHOME/include -D_WIN32_WINNT=0x0501"
export CPPFLAGS=$CFLAGS
```

Boost
*****
```
./bootstrap.sh
echo "using gcc : mingw32 : $CROSSHOST-g++ ;" >! tools/build/v2/user-config.jam
./b2 -j2 --with-date_time --with-system --prefix=$CROSSHOME toolset=gcc-mingw32 link=static variant=release threading=multi target-os=windows threadapi=win32 install
```

OpenSSL
*******
```
CROSS_COMPILE=$CROSSHOST- ./configure threads no-shared mingw --prefix=$CROSSHOME
make clean && make && make install
```

libtorrent
**********
```
sed -i 's/$PKG_CONFIG openssl --libs-only-l/$PKG_CONFIG openssl --static --libs-only-l/' ./configure
make clean
./configure --host=$CROSSHOST --prefix=$CROSSHOME --with-boost=$CROSSHOME --with-boost-libdir=$CROSSHOME/lib --enable-static --disable-shared
make -j2 && make install
```




Linux x86
=========
```
export CROSSHOST=i586-pc-linux
export CROSSHOME=/usr/local/gcc-4.8.1-for-linux32/
export PATH=$CROSSHOME/bin:$PATH
export PKG_CONFIG_LIBDIR=$CROSSHOME/lib/pkgconfig
export PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR
unset CFLAGS
unset CPPFLAGS
```

Boost
*****
```
./bootstrap.sh
echo "using gcc : linux32 : $CROSSHOST-g++ ;" >! tools/build/v2/user-config.jam
./b2 -j2 --with-date_time --with-system --prefix=$CROSSHOME toolset=gcc-linux32 link=static variant=release threading=multi target-os=linux install
```

OpenSSL
*******
```
CROSS_COMPILE=$CROSSHOST- ./configure threads no-shared linux-elf --prefix=$CROSSHOME
make clean && make && make install
```

libtorrent
**********
```
sed -i 's/$PKG_CONFIG openssl --libs-only-l/$PKG_CONFIG openssl --static --libs-only-l/' ./configure
make clean
./configure --host=$CROSSHOST --prefix=$CROSSHOME --with-boost=$CROSSHOME --with-boost-libdir=$CROSSHOME/lib --enable-static --disable-shared
make -j2 && make install
```



Linux x86_64
============
```
export CROSSHOST=x86_64-pc-linux
export CROSSHOME=/usr/local/gcc-4.8.0-linux64
export PATH=$CROSSHOME/bin:$PATH
export PKG_CONFIG_LIBDIR=$CROSSHOME/lib/pkgconfig
export PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR
unset CFLAGS
unset CPPFLAGS
```

Boost
*****
```
./bootstrap.sh
echo "using gcc : linux64 : $CROSSHOST-g++ ;" >! tools/build/v2/user-config.jam
./b2 -j2 --with-date_time --with-system --prefix=$CROSSHOME toolset=gcc-linux64 link=static variant=release threading=multi target-os=linux install
```

OpenSSL
*******
```
CROSS_COMPILE=$CROSSHOST- ./configure threads no-shared linux-x86_64 --prefix=$CROSSHOME
make clean && make && make install
```

libtorrent
**********
```
sed -i 's/$PKG_CONFIG openssl --libs-only-l/$PKG_CONFIG openssl --static --libs-only-l/' ./configure
make clean
./configure --host=$CROSSHOST --prefix=$CROSSHOME --with-boost=$CROSSHOME --with-boost-libdir=$CROSSHOME/lib --enable-static --disable-shared
make -j2 && make install
```

Linux ARM
=========
```
export CROSSHOST=arm-linux-gnueabihf
export CROSSHOME=/usr/local/gcc-linaro-arm-linux-gnueabihf-raspbian
export PATH=$CROSSHOME/bin:$PATH
export PKG_CONFIG_LIBDIR=$CROSSHOME/lib/pkgconfig
export PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR
unset CFLAGS
unset CPPFLAGS
```

Boost
*****
```
./bootstrap.sh
echo "using gcc : linuxarm : $CROSSHOST-g++ ;" > tools/build/v2/user-config.jam
./b2 -j2 --with-date_time --with-system --prefix=$CROSSHOME toolset=gcc-linuxarm link=static variant=release threading=multi target-os=linux install
```

OpenSSL
*******
```
make clean
CROSS_COMPILE=$CROSSHOST- ./configure threads no-shared linux-elf no-asm --prefix=$CROSSHOME
make && make install
```

libtorrent
**********
```
sed -i 's/$PKG_CONFIG openssl --libs-only-l/$PKG_CONFIG openssl --static --libs-only-l/' ./configure
make clean
./configure --host=$CROSSHOST --prefix=$CROSSHOME --with-boost=$CROSSHOME --with-boost-libdir=$CROSSHOME/lib --enable-static --disable-shared
make -j2 && make install
```


Android ARM
===========
```
export CROSSHOST=x86_64-pc-linux
export CROSSHOME=/usr/local/gcc-4.8.0-linux64
export PATH=$CROSSHOME/bin:$PATH
export PKG_CONFIG_LIBDIR=$CROSSHOME/lib/pkgconfig
export PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR
unset CFLAGS
unset CPPFLAGS
```

Boost
*****
```
./bootstrap.sh
echo "using gcc : linux64 : $CROSSHOST-g++ ;" >! tools/build/v2/user-config.jam
./b2 -j2 --with-date_time --with-system --prefix=$CROSSHOME toolset=gcc-linux64 link=static variant=release threading=multi target-os=linux install
```

OpenSSL
*******
```
CROSS_COMPILE=$CROSSHOST- ./configure threads no-shared linux-x86_64 --prefix=$CROSSHOME
make clean && make && make install
```

libtorrent
**********
```
sed -i 's/$PKG_CONFIG openssl --libs-only-l/$PKG_CONFIG openssl --static --libs-only-l/' ./configure
make clean
./configure --host=$CROSSHOST --prefix=$CROSSHOME --with-boost=$CROSSHOME --with-boost-libdir=$CROSSHOME/lib --enable-static --disable-shared
make -j2 && make install
```
