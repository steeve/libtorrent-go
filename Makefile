CC = gcc
CXX = g++
SWIG = swig
SED_I = sed -i

include platform_host.mk

ifeq ($(HOST_OS), darwin)
	SED_I := $(SED_I) ''
endif

ifneq ($(CROSS_PREFIX),)
	CC := $(CROSS_PREFIX)-$(CC)
	CXX := $(CROSS_PREFIX)-$(CXX)
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
	CROSS_LDFLAGS = -L$(CROSS_HOME)/lib -L$(CROSS_HOME)/$(CROSS_PREFIX)/lib
	PKG_CONFIG_PATH = $(CROSS_HOME)/lib/pkgconfig
endif

LIBTORRENT_CFLAGS = $(shell PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config --cflags libtorrent-rasterbar)
LIBTORRENT_LDFLAGS = $(shell PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config --libs libtorrent-rasterbar)

CFLAGS = -O2 -Wno-deprecated -Wno-deprecated-declarations $(CROSS_CFLAGS) $(LIBTORRENT_CFLAGS)
LDFLAGS = $(CROSS_LDFLAGS)

SWIG_FLAGS = -go -c++\
	-soname dummy \
	-intgosize $(SWIG_INT_GO_SIZE) \
	$(CROSS_CFLAGS) \
	$(LIBTORRENT_CFLAGS)

ifeq ($(CROSS_HOME),)
	SWIG_FLAGS += -I/usr/local/include
endif
ifeq ($(TARGET_OS), windows)
	CFLAGS += -mthreads
	LDFLAGS += -shared -lm -mthreads -ltorrent.dll -lboost_system
else ifeq ($(TARGET_OS), linux)
	CFLAGS += -fPIC
	LDFLAGS += -shared -lc -lm -lpthread -ltorrent -Wl,-rpath,\$$ORIGIN
else ifeq ($(TARGET_OS), android)
	CFLAGS += -fPIC
	LDFLAGS += $(LIBTORRENT_LDFLAGS) -lm -lssl -lcrypto -lstdc++
else ifeq ($(TARGET_OS), darwin)
	CFLAGS += -fPIC -mmacosx-version-min=10.6
	LDFLAGS += $(LIBTORRENT_LDFLAGS)
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

all: $(OBJS)

re: clean all

$(SRCS) $(GOFILES): $(SWIG_FILES)
	$(SWIG) $(SWIG_FLAGS) -o $@ -outdir . $<
# It should always be like this, according to https://code.google.com/p/go/source/browse/src/cmd/cgo/out.go#530
	$(SED_I) 's/} \*swig_a/} __attribute__((__packed__)) \*swig_a/g' $@
	$(SED_I) 's/} a/} __attribute__((__packed__)) a/g' $@
# Convert imports to static imports
	$(SED_I) 's/#pragma dynimport _ _ ".*"//g' $(<:%.i=%_gc.c)
	$(SED_I) 's/#pragma dynimport \(.*\) .* ""/#pragma cgo_import_static \1/g' $(<:%.i=%_gc.c)
# Ensure the ldflags are properly set for static compilation
	echo "#pragma cgo_ldflag \"$(shell pwd)/$(@:%.cxx=%.o)\"" > $(<:%.i=%_gc.cgo)
	for flag in $(LDFLAGS); do\
		echo "#pragma cgo_ldflag \"$$flag\"" >> $(<:%.i=%_gc.cgo) ;\
	done
	cat $(<:%.i=%_gc.c) >> $(<:%.i=%_gc.cgo)
# Overwrite the file
	mv $(<:%.i=%_gc.cgo) $(<:%.i=%_gc.c)
# Temp fix for https://code.google.com/p/go/issues/detail?id=6541
# See also https://code.google.com/p/go/issues/detail?id=5603
ifneq ($(findstring gcc, $(CC)),)
ifneq (,$(filter $(TARGET_ARCH),x86 x64))
	$(SED_I) 's/__attribute__((__packed__))/__attribute__((__packed__, __gcc_struct__))/g' $@
endif
endif

$(OBJS): $(SRCS)
	$(CXX) $(CFLAGS) -c $< -o $@
	rm -f $<

clean:
	rm -rf $(OBJS) $(SRCS) $(GOFILES) *.o
