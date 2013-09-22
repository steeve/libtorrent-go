NAME = libtorrent-go
CC = cc
CXX = c++

# Detect OS
ifeq ($(OS), Windows_NT)
	OS = Windows_NT
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S), Linux)
		OS = Linux
	endif
	ifeq ($(UNAME_S), Darwin)
		OS = Darwin
	endif
endif


#LIBTORRENT_CFLAGS = $(shell pkg-config --cflags libtorrent-rasterbar)
LIBTORRENT_CFLAGS = -DTORRENT_USE_OPENSSL -DWITH_SHIPPED_GEOIP_H -DBOOST_ASIO_HASH_MAP_BUCKETS=1021 -DBOOST_EXCEPTION_DISABLE -DBOOST_ASIO_ENABLE_CANCELIO -DBOOST_ASIO_DYN_LINK -DTORRENT_LINKING_SHARED
SWIG_FLAGS = -I/usr/include -I/usr/local/include $(LIBTORRENT_CFLAGS)

CFLAGS = -Wno-deprecated -Wno-deprecated-declarations $(LIBTORRENT_CFLAGS)
LDFLAGS = -ltorrent-rasterbar

SRCS = libtorrent_wrap.cxx
OBJS = $(SRCS:.cxx=.o)

ifeq ($(OS),Windows_NT)
	EXT = dll
	LDFLAGS += -shared -lm -mthreads
endif
ifeq ($(OS),Linux)
	EXT = so
	LDFLAGS += -shared -lpthread -lm -Wl,-rpath,\$$ORIGIN
endif
ifeq ($(OS),Darwin)
	EXT = dylib
	LDFLAGS += -dynamiclib -Wl,-undefined,dynamic_lookup -Wl,-rpath,@executable_path/ -install_name @rpath/$(NAME).$(EXT)
endif

LIBRARY_NAME = $(NAME).$(EXT)
BUILD_PATH = build/$(OS)

all: library fix_libs_$(OS)

re: clean all

swig:
	swig -go -intgosize 64 -c++ -soname $(LIBRARY_NAME) $(SWIG_FLAGS) -I/usr/local/include libtorrent.i

library: $(OBJS)
	mkdir -p $(BUILD_PATH)
	$(CXX) -o $(BUILD_PATH)/$(LIBRARY_NAME) $(OBJS) $(LDFLAGS)

$(SRCS): swig

$(OBJS): $(SRCS)
	$(CXX) $(CFLAGS) -fPIC -c $< -o $@

fix_libs_Darwin:
	@for dylib in $(BUILD_PATH)/$(LIBRARY_NAME) $(BUILD_PATH)/libtorrent-rasterbar.7.dylib; do \
		for dep in `otool -L $$dylib | grep -v $$dylib | grep /usr/local | awk '{print $$1}'`; do \
			cp -f $$dep $(BUILD_PATH); \
			chmod 644 $(BUILD_PATH)/`basename $$dep`; \
			install_name_tool -change $$dep @rpath/`basename $$dep` $(BUILD_PATH)/`basename $$dylib`; \
		done; \
	done

fix_libs_Linux:
	cp -f `ldd build/Linux/libtorrent-go.so | grep -E "libtorrent-rasterbar|libboost_system" | awk '{print $$3}'` $(BUILD_PATH)

clean:
	rm -rf build *.o *.go *.cxx *.c *.$(EXT)
