NAME = libtorrent-go
MODULE_NAME = libtorrent
CC = cc
CXX = c++
SWIG = swig
SED = sed
PKG_CONFIG = pkg-config

include platform_host.mk

ifneq ($(CROSS_TRIPLE),)
	CC := $(CROSS_TRIPLE)-$(CC)
	CXX := $(CROSS_TRIPLE)-$(CXX)
endif

include platform_target.mk

ifeq ($(TARGET_ARCH), x86)
	SWIG_INT_GO_SIZE = 32
else ifeq ($(TARGET_ARCH), x64)
	SWIG_INT_GO_SIZE = 64
else ifeq ($(TARGET_ARCH), arm)
	SWIG_INT_GO_SIZE = 32
endif

ifneq ($(CROSS_ROOT),)
	CROSS_CFLAGS = -I$(CROSS_ROOT)/include -I$(CROSS_ROOT)/$(CROSS_TRIPLE)/include
	CROSS_LDFLAGS = -L$(CROSS_ROOT)/lib
	PKG_CONFIG := PKG_CONFIG_LIBDIR=$(CROSS_ROOT)/lib/pkgconfig $(PKG_CONFIG)
endif

LIBTORRENT_CFLAGS = $(shell $(PKG_CONFIG) --cflags libtorrent-rasterbar)
LIBTORRENT_LDFLAGS = $(shell $(PKG_CONFIG) --static --libs libtorrent-rasterbar)

DEFINE_IGNORES = __STDC__|_cdecl|__cdecl|_fastcall|__fastcall|_stdcall|__stdcall|__declspec

CC_DEFINES = $(shell echo | $(CC) -dM -E - | grep -v -E "$(DEFINE_IGNORES)" | sed -E "s/\#define[[:space:]]+([a-zA-Z0-9_()]+)[[:space:]]+(.*)/-D'\1'='\2'/g" | tr '\n' ' ')
CC_INCLUDES = $(shell $(CC) -x c++ -v -E /dev/null 2>&1 | sed -n "/search starts here/,/End of search list./p" | grep -e "^ .*" | sed -E "s/[[:space:]]+(.*)/-I'\1'/g" | tr '\n' ' ')
CFLAGS = -O2 -Wno-deprecated -Wno-deprecated-declarations $(CROSS_CFLAGS) $(CC_INCLUDES) $(LIBTORRENT_CFLAGS)
LDFLAGS = $(CROSS_LDFLAGS)

SWIG_FLAGS = -go -c++\
	-intgosize $(SWIG_INT_GO_SIZE) \
	$(CROSS_CFLAGS) \
	$(LIBTORRENT_CFLAGS) \
	$(CC_DEFINES) $(CC_INCLUDES)

ifeq ($(TARGET_OS), windows)
	EXT = dll
	SWIG_FLAGS += -D_WIN32_WINNT=0x0501 -DSWIGWIN
	ifeq ($(TARGET_ARCH), x64)
		SWIG_FLAGS += -DSWIGWORDSIZE32
	endif
	CFLAGS += -mthreads
	LDFLAGS += -shared -static-libgcc -static-libstdc++ $(LIBTORRENT_LDFLAGS)
else ifeq ($(TARGET_OS), linux)
	CFLAGS += -fPIC
	LDFLAGS += $(LIBTORRENT_LDFLAGS) -lm -lstdc++ -ldl
else ifeq ($(TARGET_OS), android)
	CFLAGS += -fPIC -ggdb -fstack-protector-all
	LDFLAGS += -Wl,-Bstatic $(LIBTORRENT_LDFLAGS) -lm -Wl,-Bdynamic -lstdc++
else ifeq ($(TARGET_OS), darwin)
	SWIG_FLAGS += -DSWIGMAC -DBOOST_HAS_PTHREADS
	CFLAGS += -fPIC -mmacosx-version-min=10.6
	LDFLAGS += $(LIBTORRENT_LDFLAGS) -lm -lssl -lcrypto -lstdc++
endif

ifneq ($(CROSS_ROOT),)
	LIB_SEARCH_PATH = $(CROSS_ROOT)
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
GCFILES = $(SWIG_FILES:%.i=%_gc.c)
GOFILES = $(SWIG_FILES:%.i=%.go)
OBJS = $(SRCS:%.cxx=%.o)

BUILD_PATH = build/$(TARGET_OS)_$(TARGET_ARCH)
LIBRARY_NAME = $(NAME).$(EXT)

all: dist

re: clean all

force:
	@true

$(BUILD_PATH):
	mkdir -p $(BUILD_PATH)

$(SRCS): $(SWIG_FILES)
	$(SWIG) $(SWIG_FLAGS) -o $@ -outdir . $<
# It should always be like this, according to https://code.google.com/p/go/source/browse/src/cmd/cgo/out.go#530
	$(SED) -i -E 's/} (\*swig_a|a)/} SWIG_PACKED_STRUCT \1/g' $@
	$(SED) -i -e 's/_wrap_/SWIGEXPORT _wrap_/g' $@
ifeq ($(TARGET_OS), windows)
	cat swig_packed_struct.h dllmain.h $@ > $@.tmp
	$(SED) -i -e 's/\(extern void\)/\/\/\1/' $@.tmp
else
	cat swig_packed_struct.h $@ > $@.tmp
endif
	mv $@.tmp $@

dist_linux dist_android dist_darwin: swig_static $(OBJS)

dist_windows: swig_shared shared_library

dist: dist_$(TARGET_OS)
	rm -rf libtorrent_wrap.cxx

fix_exports:
# Patch SWIG generated files for succesful compilation on Windows.
# Based on https://groups.google.com/forum/#!topic/golang-nuts/9L0U4Q7AtyE
# Comment out externs
# Insert packed struct definition

fix_imports:
# Fix imports by specifying them to the external dll, and commenting the x_wrap_* symbols
	$(SED) -i -e 's/\(#pragma dynimport _ _\)/\/\/\1/' \
			  -e 's/\(#pragma dynimport.*\)\(""\)/\1"$(LIBRARY_NAME)"/g' \
			  -e 's/\(static void (\*x_wrap_\)/\/\/\1/g' \
			  -e 's/cgocall(x\(_wrap_.*\)/cgocall(\1/g' libtorrent_gc.c

swig_shared: $(SRCS) $(GCFILES) $(GOFILES) fix_imports fix_exports

shared_library: swig_shared $(OBJS) $(BUILD_PATH)
	$(CXX) -o $(BUILD_PATH)/$(LIBRARY_NAME) $(CFLAGS) $(OBJS) $(LDFLAGS)

swig_static: $(SRCS) $(GCFILES) $(GOFILES)
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
