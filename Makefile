NAME = libtorrent-go
CC = gcc
CXX = g++
SWIG = swig
LDD = ldd
OBJDUMP = objdump

include OS.inc
ifeq ($(OS),Darwin)
	# clang on OS X
	CC = clang
	CXX = clang++
endif
ifneq ($(CROSS_PREFIX),)
	CC := $(CROSS_PREFIX)-$(CC)
	CXX := $(CROSS_PREFIX)-$(CXX)
	LDD := $(CROSS_PREFIX)-$(LDD)
	OBJDUMP := $(CROSS_PREFIX)-$(OBJDUMP)
endif
include Arch.inc

ifeq ($(ARCH),x86)
	SWIG_INT_GO_SIZE = 32
endif
ifeq ($(ARCH),x64)
	SWIG_INT_GO_SIZE = 64
endif
ifeq ($(ARCH),arm)
	SWIG_INT_GO_SIZE = 32
endif

ifneq ($(CROSS_HOME),)
	CROSS_CFLAGS = -I$(CROSS_HOME)/include -I$(CROSS_HOME)/$(CROSS_PREFIX)/include
	CROSS_LDFLAGS = -L$(CROSS_HOME)/lib -L$(CROSS_HOME)/$(CROSS_PREFIX)/lib
endif

LIBTORRENT_CFLAGS = \
	-DTORRENT_USE_OPENSSL \
	-DWITH_SHIPPED_GEOIP_H \
	-DBOOST_ASIO_HASH_MAP_BUCKETS=1021 \
	-DBOOST_EXCEPTION_DISABLE \
	-DBOOST_ASIO_ENABLE_CANCELIO \
	-DBOOST_ASIO_DYN_LINK \
	-DTORRENT_LINKING_SHARED

CFLAGS = -g -O2 \
	-Wno-deprecated \
	-Wno-deprecated-declarations \
	$(CROSS_CFLAGS) \
	$(LIBTORRENT_CFLAGS)
LDFLAGS = $(CROSS_LDFLAGS)

SWIG_FLAGS = -go -c++\
	-soname $(LIBRARY_NAME) \
	-intgosize $(SWIG_INT_GO_SIZE) \
	$(CROSS_CFLAGS) \
	$(LIBTORRENT_CFLAGS)

ifeq ($(CROSS_HOME),)
	SWIG_FLAGS += -I/usr/local/include
endif
ifeq ($(OS),Windows_NT)
	EXT = dll
	CFLAGS += -mthreads
	LDFLAGS += -shared -lm -mthreads -ltorrent.dll -lboost_system
endif
ifeq ($(OS),Linux)
	EXT = so
	CFLAGS += -fPIC
	LDFLAGS += -shared -lpthread -lm -ltorrent -Wl,-rpath,\$$ORIGIN
endif
ifeq ($(OS),Darwin)
	EXT = dylib
	CFLAGS += -fPIC
	LDFLAGS += -dynamiclib -ltorrent-rasterbar -Wl,-undefined,dynamic_lookup -Wl,-rpath,@executable_path/ -install_name @rpath/$(NAME).$(EXT)
endif

ifneq ($(CROSS_HOME),)
	LIB_SEARCH_PATH = $(CROSS_HOME)
else
	ifeq ($(OS),Windows_NT)
		ifeq ($(ARCH),x86_64)
			LIB_SEARCH_PATH = c:/windows/syswow64
		else
			LIB_SEARCH_PATH = c:/windows/system32
		endif
	else
		LIB_SEARCH_PATH = /usr/lib /usr/local/lib
	endif
endif


BUILD_PATH = build/$(OS)_$(ARCH)
OBJ_PATH = build/$(OS)_$(ARCH)/obj
BIN_PATH = build/$(OS)_$(ARCH)/bin
SWIG_FILES = libtorrent.i
SRCS = $(SWIG_FILES:%.i=$(OBJ_PATH)/%_wrap.cxx)
GOFILES = $(SWIG_FILES:%.i=%_gc.c) $(SWIG_FILES:%.i=%.go)
OBJS = $(SRCS:%.cxx=%.o)
LIBRARY_NAME = $(NAME).$(EXT)

all: library vendor_libs_$(OS)

re: clean all

library: $(OBJS)
	$(CXX) -o $(BIN_PATH)/$(LIBRARY_NAME) $(OBJS) $(LDFLAGS)

$(SWIG_FILES): $(BUILD_PATH)

$(BUILD_PATH):
	mkdir -p $(BUILD_PATH)
	mkdir -p $(OBJ_PATH)
	mkdir -p $(BIN_PATH)

$(SRCS) $(GOFILES): $(SWIG_FILES)
	$(SWIG) $(SWIG_FLAGS) -o $@ -outdir . $<
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

$(OBJS): $(SRCS)
	$(CXX) $(CFLAGS) -c $< -o $@

vendor_libs_Darwin:
	@for dylib in $(BIN_PATH)/$(LIBRARY_NAME) $(BIN_PATH)/libtorrent-rasterbar.7.dylib; do \
		for dep in `otool -L $$dylib | grep -v $$dylib | grep /usr/local | awk '{print $$1}'`; do \
			cp -f $$dep $(BIN_PATH); \
			chmod 644 $(BIN_PATH)/`basename $$dep`; \
			install_name_tool -change $$dep @rpath/`basename $$dep` $(BIN_PATH)/`basename $$dylib`; \
		done; \
	done

vendor_libs_Linux:
ifneq ($(CROSS_HOME),)
	$(eval SEARCH_PATH = $(CROSS_HOME))
else
	$(eval SEARCH_PATH = /usr/lib /usr/local/lib)
endif
	@for dep in torrent boost_system boost_date_time ssl crypto; do \
		echo Copying lib$$dep to $(BIN_PATH); \
		find $(SEARCH_PATH)/ -type f -iname "lib$$dep.so*" -exec cp {} $(BIN_PATH) \; ; \
	done;
	@find $(BIN_PATH) -type f -exec chmod 644 {} \;
	@find $(BIN_PATH) -type d -exec chmod 755 {} \;

vendor_libs_Windows_NT:
	@for dll in $(BIN_PATH)/$(LIBRARY_NAME) $(BIN_PATH)/libtorrent.$(EXT); do \
		for dep in `$(OBJDUMP) -p $$dll | grep "DLL Name" | awk '{print $$3}'`; do \
			echo Copying $$dep to $(BIN_PATH); \
			find $(CROSS_HOME) -iname $$dep -exec cp {} $(BIN_PATH) \; ; \
		done; \
	done;

clean:
	rm -rf $(BUILD_PATH) $(OBJS) $(SRCS) $(GOFILES) *.$(EXT)

distclean: clean
	rm -rf build
