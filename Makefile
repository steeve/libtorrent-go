NAME = libtorrent-go
CC = $(CROSS_PREFIX)-gcc
CXX = $(CROSS_PREFIX)-g++
SWIG = swig

include Platform.inc

LIBTORRENT_CFLAGS = \
	-DTORRENT_USE_OPENSSL \
	-DWITH_SHIPPED_GEOIP_H \
	-DBOOST_ASIO_HASH_MAP_BUCKETS=1021 \
	-DBOOST_EXCEPTION_DISABLE \
	-DBOOST_ASIO_ENABLE_CANCELIO \
	-DBOOST_ASIO_DYN_LINK \
	-DTORRENT_LINKING_SHARED

CFLAGS = -g -O2 -Wno-deprecated -Wno-deprecated-declarations $(LIBTORRENT_CFLAGS)
LDFLAGS =

SWIG_FILES = libtorrent.i
SRCS = $(SWIG_FILES:%.i=%_wrap.cxx)
OBJS = $(SRCS:%.cxx=%.o)

ifeq ($(ARCH),x86)
	SWIG_INT_GO_SIZE = 32
	SWIGWORDSIZE = 32
endif
ifeq ($(ARCH),x64)
	SWIG_INT_GO_SIZE = 64
	SWIGWORDSIZE = 64
endif

SWIG_FLAGS = -go -intgosize $(SWIG_INT_GO_SIZE) -DSWIGWORDSIZE$(SWIGWORDSIZE) -c++ -soname $(LIBRARY_NAME) $(LIBTORRENT_CFLAGS)

ifneq ($(CROSS_HOME),)
	CROSS_CFLAGS = -I$(CROSS_HOME)/include -I$(CROSS_HOME)/$(CROSS_PREFIX)/include
	CROSS_LDFLAGS = -L$(CROSS_HOME)/lib -L$(CROSS_HOME)/$(CROSS_PREFIX)/lib
	SWIG_FLAGS += $(CROSS_CFLAGS)
	CFLAGS += $(CROSS_CFLAGS)
	LDFLAGS += $(CROSS_LDFLAGS)
else
	SWIG_FLAGS += -I/usr/local/include
endif

ifeq ($(OS),Windows_NT)
	EXT = dll
	CFLAGS += -mthreads
	LDFLAGS += -shared -ltorrent.dll -lboost_system -lm -mthreads -lstdc++
endif
ifeq ($(OS),Linux)
	EXT = so
	CFLAGS += -fPIC
	LDFLAGS += -shared -ltorrent-rasterbar -lpthread -lm -Wl,-rpath,\$$ORIGIN
endif
ifeq ($(OS),Darwin)
	# clang on OS X
	CC = $(CROSS_PREFIX)-cc
	CXX = $(CROSS_PREFIX)-c++
	EXT = dylib
	CFLAGS += -fPIC
	LDFLAGS += -dynamiclib -ltorrent-rasterbar -lpthread -lm -Wl,-undefined,dynamic_lookup -Wl,-rpath,@executable_path/ -install_name @rpath/$(NAME).$(EXT)
endif


LIBRARY_NAME = $(NAME).$(EXT)
BUILD_PATH = build/$(OS)_$(ARCH)

all: library fix_libs_$(OS)

re: clean all

echo:

library: $(BUILD_PATH) $(OBJS)
	$(CXX) -o $(BUILD_PATH)/$(LIBRARY_NAME) $(OBJS) $(LDFLAGS)

$(BUILD_PATH):
	mkdir -p $(BUILD_PATH)

%_gc.c %.go %_wrap.cxx: %.i
	$(SWIG) $(SWIG_FLAGS) $<
ifeq ($(OS), Windows_NT)
	# Patch SWIG generated files for succesful compilation on Windows.
	# Based on https://groups.google.com/forum/#!topic/golang-nuts/9L0U4Q7AtyE
	sed -i '' 's/\(extern void\)/\/\/\1/' $@
	cat dllmain.i $@ > $@.tmp
	mv $@.tmp $@
	sed -i '' 's/\(#pragma dynimport _ _\)/\/\/\1/' libtorrent_gc.c
	sed -i '' 's/\(#pragma dynimport.*\)\(""\)/\1"$(LIBRARY_NAME)"/g' libtorrent_gc.c
	sed -i '' 's/\(static void (\*x_wrap_\)/\/\/\1/g' libtorrent_gc.c
	sed -i '' 's/cgocall(x\(_wrap_.*\)/cgocall(\1/g' libtorrent_gc.c
endif
	cp $@ $@.tmp

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
	cp $(CROSS_HOME)/lib/libboost_system.dll $(BUILD_PATH)
	cp $(CROSS_HOME)/lib/libtorrent.dll $(BUILD_PATH)
	cp $(CROSS_HOME)/bin/libeay32.dll $(BUILD_PATH)
	cp $(CROSS_HOME)/bin/ssleay32.dll $(BUILD_PATH)

clean:
	rm -rf $(BUILD_PATH) *.o *.go *.cxx *.c *.$(EXT)

distclean: clean
	rm -rf build
