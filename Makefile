NAME = libtorrent-go
CC = gcc
CXX = g++
SWIG = swig
SED_I = sed -i
PKG_CONFIG = pkg-config

include platform_host.mk

ifeq ($(HOST_OS), darwin)
	SED_I := $(SED_I) ''
endif

ifneq ($(CROSS_PREFIX),)
	CC := $(CROSS_HOME)/bin/$(CROSS_PREFIX)-$(CC)
	CXX := $(CROSS_HOME)/bin/$(CROSS_PREFIX)-$(CXX)
else ifeq ($(HOST_OS), darwin)
	# clang on OS X
	CC = clang
	CXX = clang++
endif

include platform_target.mk

ifeq ($(TARGET_ARCH), x86)
	SWIG_INT_GO_SIZE = 32
else ifeq ($(TARGET_ARCH), x64)
	SWIG_INT_GO_SIZE = 64
else ifeq ($(TARGET_ARCH), arm)
	SWIG_INT_GO_SIZE = 32
endif

ifneq ($(CROSS_HOME),)
	CROSS_CFLAGS = -I$(CROSS_HOME)/include -I$(CROSS_HOME)/$(CROSS_PREFIX)/include
	CROSS_LDFLAGS = -L$(CROSS_HOME)/lib
	PKG_CONFIG := PKG_CONFIG_LIBDIR=$(CROSS_HOME)/lib/pkgconfig $(PKG_CONFIG)
endif

LIBTORRENT_CFLAGS = $(shell $(PKG_CONFIG) --cflags libtorrent-rasterbar)
LIBTORRENT_LDFLAGS = $(shell $(PKG_CONFIG) --static --libs libtorrent-rasterbar)

CFLAGS = -O2 -Wno-deprecated -Wno-deprecated-declarations $(CROSS_CFLAGS) $(LIBTORRENT_CFLAGS)
LDFLAGS = $(CROSS_LDFLAGS)

SWIG_FLAGS = -go -c++ -D__GNUC__\
	-soname dummy \
	-intgosize $(SWIG_INT_GO_SIZE) \
	$(CROSS_CFLAGS) \
	$(LIBTORRENT_CFLAGS)

ifeq ($(CROSS_HOME),)
	SWIG_FLAGS += -I/usr/include -I/usr/local/include
endif
ifeq ($(TARGET_OS), windows)
	EXT = dll
	SWIG_FLAGS += -D__MINGW32__ -D_WIN32_WINNT=0x0501 -DSWIGWIN
	CFLAGS += -mthreads
	LDFLAGS += -shared $(LIBTORRENT_LDFLAGS)
else ifeq ($(TARGET_OS), linux)
	SWIG_FLAGS += -D__linux__
	CFLAGS += -fPIC
	LDFLAGS += $(LIBTORRENT_LDFLAGS) -lm -lstdc++ -ldl
else ifeq ($(TARGET_OS), android)
	SWIG_FLAGS += -D__linux__ -D__android__
	CFLAGS += -fPIC -ggdb -fstack-protector-all
	LDFLAGS += -Wl,-Bstatic $(LIBTORRENT_LDFLAGS) -lm -Wl,-Bdynamic -lstdc++
else ifeq ($(TARGET_OS), darwin)
	SWIG_FLAGS += -D__APPLE__ -D__MACH__
	CFLAGS += -fPIC -mmacosx-version-min=10.6
	LDFLAGS += $(LIBTORRENT_LDFLAGS) -lm -lssl -lcrypto -lstdc++
endif

ifneq ($(CROSS_HOME),)
	LIB_SEARCH_PATH = $(CROSS_HOME)
else
	ifeq ($(HOST_OS), windows)
		ifeq ($(HOST_ARCH), x64)
			LIB_SEARCH_PATH = c:/windows/syswow64
		else
			LIB_SEARCH_PATH = c:/windows/system32
		endif
	else
		LIB_SEARCH_PATH = /usr/lib /usr/local/lib
	endif
endif


SWIG_FILES = libtorrent.i
SRCS = $(SWIG_FILES:%.i=%_wrap.cxx)
GOFILES = $(SWIG_FILES:%.i=%_gc.c) $(SWIG_FILES:%.i=%.go)
OBJS = $(SRCS:%.cxx=%.o)


BUILD_PATH = build/$(TARGET_OS)_$(TARGET_ARCH)
LIBRARY_NAME = $(NAME).$(EXT)

all: dist

re: clean all

$(BUILD_PATH):
	mkdir -p $(BUILD_PATH)

$(SRCS) $(GOFILES): $(SWIG_FILES)
	$(SWIG) $(SWIG_FLAGS) -o $@ -outdir . $<
# It should always be like this, according to https://code.google.com/p/go/source/browse/src/cmd/cgo/out.go#530
	$(SED_I) 's/} \*swig_a/} __attribute__((__packed__)) \*swig_a/g' $@
	$(SED_I) 's/} a/} __attribute__((__packed__)) a/g' $@
# Temp fix for https://code.google.com/p/go/issues/detail?id=6541
# See also https://code.google.com/p/go/issues/detail?id=5603
ifneq ($(findstring gcc, $(CC)),)
ifneq (,$(filter $(TARGET_ARCH),x86 x64))
	$(SED_I) 's/__attribute__((__packed__))/__attribute__((__packed__, __gcc_struct__))/g' $@
endif
endif

dist_linux dist_android dist_darwin: swig_static $(OBJS)

dist_windows: swig_shared shared_library

dist: dist_$(TARGET_OS)
	rm -rf libtorrent_wrap.cxx

swig_shared: $(SRCS) $(GOFILES)
# Patch SWIG generated files for succesful compilation on Windows.
# Based on https://groups.google.com/forum/#!topic/golang-nuts/9L0U4Q7AtyE
# Comment out externs
	$(SED_I) 's/\(extern void\)/\/\/\1/' libtorrent_wrap.cxx
# Insert dllmain
	cat dllmain.i libtorrent_wrap.cxx > libtorrent_wrap.cxx.tmp
	mv libtorrent_wrap.cxx.tmp libtorrent_wrap.cxx
	$(SED_I) 's/_wrap_/SWIGEXPORT _wrap_/g' libtorrent_wrap.cxx
# Fix imports by specifying them to the external dll, and commenting the x_wrap_* symbols
	$(SED_I) 's/\(#pragma dynimport _ _\)/\/\/\1/' libtorrent_gc.c
	$(SED_I) 's/\(#pragma dynimport.*\)\(""\)/\1"$(LIBRARY_NAME)"/g' libtorrent_gc.c
	$(SED_I) 's/\(static void (\*x_wrap_\)/\/\/\1/g' libtorrent_gc.c
	$(SED_I) 's/cgocall(x\(_wrap_.*\)/cgocall(\1/g' libtorrent_gc.c

shared_library: swig_shared $(OBJS) $(BUILD_PATH)
	$(CXX) -o $(BUILD_PATH)/$(LIBRARY_NAME) $(CFLAGS) $(OBJS) $(LDFLAGS)

swig_static: $(SRCS) $(GOFILES)
# Convert imports to static imports
	$(SED_I) 's/#pragma dynimport _ _ ".*"//g' libtorrent_gc.c
	$(SED_I) 's/#pragma dynimport \(.*\) .* ""/#pragma cgo_import_static \1/g' libtorrent_gc.c
# Ensure the ldflags are properly set for static compilation
	echo "#pragma cgo_ldflag \"$(shell pwd)/libtorrent_wrap.o\"" > libtorrent_gc.cgo
	for flag in $(CFLAGS) $(LDFLAGS); do\
		echo "#pragma cgo_ldflag \"$$flag\"" >> libtorrent_gc.cgo ;\
	done
	cat libtorrent_gc.c >> libtorrent_gc.cgo
# Overwrite the file
	mv libtorrent_gc.cgo libtorrent_gc.c

$(OBJS): $(SRCS)
	$(CXX) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(OBJS) $(SRCS) $(GOFILES) *.o $(BUILD_PATH)
