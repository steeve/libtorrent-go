NAME = libtorrent-go
CC = cc
CXX = c++
SWIG = swig

include Platform.inc

LIBTORRENT_CFLAGS = -DTORRENT_USE_OPENSSL -DWITH_SHIPPED_GEOIP_H -DBOOST_ASIO_HASH_MAP_BUCKETS=1021 -DBOOST_EXCEPTION_DISABLE -DBOOST_ASIO_ENABLE_CANCELIO -DBOOST_ASIO_DYN_LINK -DTORRENT_LINKING_SHARED

ifeq ($(ARCH),x86)
	INT_GO_SIZE = 32
endif
ifeq ($(ARCH),x64)
	INT_GO_SIZE = 64
endif
SWIG_FLAGS = -go -intgosize $(INT_GO_SIZE) -c++ -soname $(LIBRARY_NAME) -I/usr/include -I/usr/local/include $(LIBTORRENT_CFLAGS)

CFLAGS = -g -Wno-deprecated -Wno-deprecated-declarations $(LIBTORRENT_CFLAGS)
LDFLAGS =

SWIG_FILES = libtorrent.i
SRCS = $(wildcard *.cxx)
OBJS = $(SRCS:.cxx=.o)

ifeq ($(OS),Windows_NT)
	CC = gcc # MinGW
	CXX = g++
	EXT = dll
	CFLAGS += -I/usr/include -I/usr/local/include
	LDFLAGS += -shared -L/usr/local/lib -ltorrent.dll -lboost_system-mgw48-mt-1_54.dll -lm -mthreads -lstdc++
endif
ifeq ($(OS),Linux)
	EXT = so
	CFLAGS += -fPIC
	LDFLAGS += -shared -ltorrent-rasterbar -lpthread -lm -Wl,-rpath,\$$ORIGIN
endif
ifeq ($(OS),Darwin)
	EXT = dylib
	CFLAGS += -fPIC
	LDFLAGS += -dynamiclib -ltorrent-rasterbar -lpthread -lm -Wl,-undefined,dynamic_lookup -Wl,-rpath,@executable_path/ -install_name @rpath/$(NAME).$(EXT)
endif

LIBRARY_NAME = $(NAME).$(EXT)
BUILD_PATH = build/$(OS)_$(ARCH)

all: library fix_libs_$(OS)

re: clean all

swig: $(SWIG_FILES)
ifeq ($(OS),Windows_NT)
	# Needs a special patched SWIG version, sorry!
	$(SWIG) -windows $(SWIG_FLAGS) -I/usr/local/include $<
else
	$(SWIG) $(SWIG_FLAGS) -I/usr/local/include $<
endif

library: swig $(OBJS) $(BUILD_PATH)
	$(CXX) -o $(BUILD_PATH)/$(LIBRARY_NAME) $(OBJS) $(LDFLAGS)

$(BUILD_PATH):
	mkdir -p $(BUILD_PATH)

%.o: %.cxx
	$(CXX) $(CFLAGS) -c $< -o $@

fix_libs_Darwin:
	@for dylib in $(BUILD_PATH)/$(LIBRARY_NAME) $(BUILD_PATH)/libtorrent-rasterbar.7.dylib; do \
		for dep in `otool -L $$dylib | grep -v $$dylib | grep /usr/local | awk '{print $$1}'`; do \
			cp -f $$dep $(BUILD_PATH); \
			chmod 644 $(BUILD_PATH)/`basename $$dep`; \
			install_name_tool -change $$dep @rpath/`basename $$dep` $(BUILD_PATH)/`basename $$dylib`; \
		done; \
	done

fix_libs_Linux:
	cp -u `ldd $(BUILD_PATH)/libtorrent-go.so | grep -E "libtorrent-rasterbar|libboost_system" | awk '{print $$3}'` $(BUILD_PATH)

fix_libs_Windows_NT:
	cp -u /usr/local/lib/libboost_system-mgw48-mt-1_54.dll $(BUILD_PATH)
	cp -u /usr/local/lib/libtorrent.dll $(BUILD_PATH)
	cp -u /usr/local/bin/libeay32.dll $(BUILD_PATH)
	cp -u /usr/local/bin/ssleay32.dll $(BUILD_PATH)
ifeq ($(ARCH),x86)
	cp -u /opt/mingw32/bin/libgcc_s_dw2-1.dll $(BUILD_PATH)
	cp -u /opt/mingw32/bin/libstdc++-6.dll $(BUILD_PATH)
	cp -u /opt/mingw32/bin/libwinpthread-1.dll $(BUILD_PATH)
endif
ifeq ($(ARCH),x64)
	cp -u /opt/mingw64/bin/libgcc_s_seh-1.dll $(BUILD_PATH)
	cp -u /opt/mingw64/bin/libstdc++-6.dll $(BUILD_PATH)
	cp -u /opt/mingw64/bin/libwinpthread-1.dll $(BUILD_PATH)
endif

clean:
	rm -rf $(BUILD_PATH) *.o *.go *.cxx *.c *.$(EXT)

distclean: clean
	rm -rf build
