###############################################################################
# Common
###############################################################################
NAME = libtorrent-go

###############################################################################
# Development environment
###############################################################################
PLATFORMS = android-arm		\
			darwin-x64 		\
			linux-x86 		\
			linux-x64 		\
			linux-arm 		\
			windows-x86 	\
			windows-x64

DOCKER 		 = docker
DOCKER_IMAGE = steeve/$(NAME)
DOCKER_FILES = $(addsuffix /Dockerfile, $(PLATFORMS))

all: build

build: $(DOCKER_FILES)
	for i in $(PLATFORMS); do 																													\
		$(DOCKER) build -t $(DOCKER_IMAGE):$$i $$i || exit 1;																					\
		$(DOCKER) run -ti --rm -v $(HOME):$(HOME) -e GOPATH=$(shell go env GOPATH) -w $(shell pwd) $(DOCKER_IMAGE):$$i make cc-build || exit 1;	\
	done

clean:
	for i in $(PLATFORMS); do 							\
		$(DOCKER) rmi $(DOCKER_IMAGE):$$i || exit 1;	\
	done

###############################################################################
# Cross-compilation environment (inside each Docker image)
###############################################################################
GO_PACKAGE = github.com/steeve/$(NAME)

CC 		   = cc
CXX		   = c++
PKG_CONFIG = pkg-config

ifneq ($(CROSS_TRIPLE),)
	CC 	:= $(CROSS_TRIPLE)-$(CC)
	CXX := $(CROSS_TRIPLE)-$(CXX)
endif

ifneq ($(CROSS_ROOT),)
	CROSS_CFLAGS 	= -I$(CROSS_ROOT)/include -I$(CROSS_ROOT)/$(CROSS_TRIPLE)/include
	CROSS_LDFLAGS	= -L$(CROSS_ROOT)/lib
	PKG_CONFIG_PATH = $(CROSS_ROOT)/lib/pkgconfig
endif

LIBTORRENT_CFLAGS  = $(shell PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) $(PKG_CONFIG) --cflags libtorrent-rasterbar)
LIBTORRENT_LDFLAGS = $(shell PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) $(PKG_CONFIG) --static --libs libtorrent-rasterbar)
DEFINE_IGNORES 	   = __STDC__|_cdecl|__cdecl|_fastcall|__fastcall|_stdcall|__stdcall|__declspec
CC_DEFINES 		   = $(shell echo | $(CC) -dM -E - | grep -v -E "$(DEFINE_IGNORES)" | sed -E "s/\#define[[:space:]]+([a-zA-Z0-9_()]+)[[:space:]]+(.*)/-D\1="\2"/g" | tr '\n' ' ')

ifeq ($(CROSS_GOOS), windows)
	CC_DEFINES += -DSWIGWIN
	CC_DEFINES += -D_WIN32_WINNT=0x0501
	ifeq ($(CROSS_GOARCH), amd64)
		CC_DEFINES += -DSWIGWORDSIZE32
	endif
else ifeq ($(CROSS_GOOS), darwin)
	CC_DEFINES += -DSWIGMAC
	CC_DEFINES += -DBOOST_HAS_PTHREADS
endif

OUT_PATH    = $(shell go env GOPATH)/pkg/$(CROSS_GOOS)_$(CROSS_GOARCH)
OUT_LIBRARY = $(OUT_PATH)/$(GO_PACKAGE).a
ifeq ($(CROSS_GOOS), windows)
	OUT_LIBRARY_SHARED = $(OUT_PATH)/$(GO_PACKAGE).dll
	SONAME 			   = $(shell basename $(OUT_LIBRARY_SHARED))
endif

ifeq ($(CROSS_GOOS), windows)
cc-build: $(OUT_LIBRARY_SHARED)
else
cc-build: $(OUT_LIBRARY)
endif

$(OUT_LIBRARY):
	SWIG_FLAGS='$(CC_DEFINES) $(LIBTORRENT_CFLAGS)'					\
	SONAME=$(SONAME)												\
	CC=$(CC) CXX=$(CXX)												\
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)								\
	CGO_ENABLED=1													\
	GOOS=$(CROSS_GOOS) GOARCH=$(CROSS_GOARCH) GOARM=$(CROSS_GOARM)	\
	PATH=.:$$PATH  													\
	go install -v -x

$(OUT_LIBRARY_SHARED): cc-clean $(OUT_LIBRARY)
	cp $(OUT_LIBRARY) $(OUT_LIBRARY).raw
	cd `mktemp -d` &&																								\
		pwd && 																										\
		ar x $(OUT_LIBRARY).raw && 																					\
		go tool pack r $(OUT_LIBRARY) `ar t $(OUT_LIBRARY).raw | grep -v _wrap` && 									\
		$(CXX) -shared -static-libgcc -static-libstdc++ -o $(OUT_LIBRARY_SHARED) *_wrap $(LIBTORRENT_LDFLAGS) &&	\
		rm -rf `pwd`
	rm -rf $(OUT_LIBRARY).raw

cc-clean:
	rm -rf $(OUT_LIBRARY) $(OUT_LIBRARY_SHARED)
