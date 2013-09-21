NAME = libtorrent-go
CC = cc
CXX = c++

LIBTORRENT_CFLAGS = $(shell pkg-config --cflags libtorrent-rasterbar)
LIBTORRENT_LDFLAGS = $(shell pkg-config --libs libtorrent-rasterbar)

HOMEBREW_DYLIB_PATH = /usr/local/lib
LIBTORRENT_DYLIB = libtorrent-rasterbar.7.dylib
LIBBOOST_DYLIB = libboost_system-mt.dylib

SWIG_FLAGS = -I/usr/local/include $(LIBTORRENT_CFLAGS)

SRCS = libtorrent_wrap.cxx
OBJS = $(SRCS:.cxx=.o)

CFLAGS = $(LIBTORRENT_CFLAGS) -Wno-deprecated -Wno-deprecated-declarations
LDFLAGS = $(LIBTORRENT_LDFLAGS) -lstdc++

ifeq ($(OS),Windows_NT)
	OS = Windows_NT
	LDFLAGS += -shared -lm -mthreads
    EXT = dll
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
    	OS = Linux
        LDFLAGS += -shared -lpthread -lm -Wl,-rpath=$ORIGIN
        EXT = so
    endif
    ifeq ($(UNAME_S),Darwin)
    	OS = Darwin
        LDFLAGS += -dynamiclib -Wl,-undefined,dynamic_lookup
        EXT = dylib
    endif
endif
DYLIB_NAME = $(NAME).$(EXT)

all: dylib fix_libs_$(OS)

swig:
	swig -go -intgosize 64 -c++ -soname $(DYLIB_NAME) $(SWIG_FLAGS) -I/usr/local/include libtorrent.i

dylib: $(OBJS)
	$(CXX) -o $(DYLIB_NAME) $(OBJS) $(LDFLAGS)

$(SRCS): swig

$(OBJS): $(SRCS)
	$(CXX) $(CFLAGS) -fPIC -c $< -o $@

fix_libs_Darwin:
	@for dylib in $(DYLIB_NAME) libtorrent-rasterbar.7.dylib; do \
		for dep in `otool -L $$dylib | grep -v $$dylib | grep /usr/local | awk '{print $$1}'`; do \
			cp -f $$dep .; \
			chmod 644 `basename $$dep`; \
			install_name_tool -change $$dep @executable_path/`basename $$dep` ./`basename $$dylib`; \
		done; \
	done

fix_libs_Linux:

