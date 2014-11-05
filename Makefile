NAME = libtorrent-go
GO_PACKAGE = github.com/steeve/$(NAME)
CC = cc
CXX = c++
PKG_CONFIG = pkg-config
DOCKER = docker
DOCKER_IMAGE = steeve/$(NAME)
PLATFORMS = android-arm \
			darwin-x64 \
			linux-x86 \
			linux-x64 \
			linux-arm \
			windows-x86 \
			windows-x64

include platform_host.mk

ifneq ($(CROSS_TRIPLE),)
	CC := $(CROSS_TRIPLE)-$(CC)
	CXX := $(CROSS_TRIPLE)-$(CXX)
endif

include platform_target.mk

ifeq ($(TARGET_ARCH),x86)
	GOARCH = 386
else ifeq ($(TARGET_ARCH),x64)
	GOARCH = amd64
else ifeq ($(TARGET_ARCH),arm)
	GOARCH = arm
	GOARM = 6
endif

ifeq ($(TARGET_OS), windows)
	GOOS = windows
else ifeq ($(TARGET_OS), darwin)
	GOOS = darwin
else ifeq ($(TARGET_OS), linux)
	GOOS = linux
else ifeq ($(TARGET_OS), android)
	GOOS = linux
	GOARM = 7
endif

ifneq ($(CROSS_ROOT),)
	CROSS_CFLAGS = -I$(CROSS_ROOT)/include -I$(CROSS_ROOT)/$(CROSS_TRIPLE)/include
	CROSS_LDFLAGS = -L$(CROSS_ROOT)/lib
	PKG_CONFIG_PATH = $(CROSS_ROOT)/lib/pkgconfig
endif

LIBTORRENT_CFLAGS = $(shell $(PKG_CONFIG) --cflags libtorrent-rasterbar)
DEFINE_IGNORES = __STDC__|_cdecl|__cdecl|_fastcall|__fastcall|_stdcall|__stdcall|__declspec|__LDBL_MAX__

all: install

compiler_defines.i:
	@PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) $(PKG_CONFIG) --cflags libtorrent-rasterbar | sed -E -e 's/-D+/\n#define /g' -e 's/-I[^ ]+//g' -e 's/=/ /g' > $@
	@echo | $(CC) -dM -E - | grep -v -E "$(DEFINE_IGNORES)" >> $@
ifeq ($(TARGET_OS), windows)
	@echo "#define _WIN32_WINNT 0x0501" >> $@
	@echo "#define SWIGWIN" >> $@
ifeq ($(TARGET_ARCH), x64)
	@echo "#define SWIGWORDSIZE32" >> $@
endif
else ifeq ($(TARGET_OS), darwin)
	@echo "#define SWIGMAC" >> $@
	@echo "#define BOOST_HAS_PTHREADS" >> $@
endif

install: compiler_defines.i
	CC=$(CC) CXX=$(CXX) \
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	CGO_ENABLED=1 \
	GOOS=$(GOOS) GOARCH=$(GOARCH) GOARM=$(GOARM) \
	go install -v

clean:
	rm -rf compiler_defines.i
	rm -rf $(shell go env GOPATH)/pkg/$(GOOS)_$(GOARCH)/$(GO_PACKAGE).a

re: clean all

build-envs:
	for i in $(PLATFORMS); do \
		$(DOCKER) build -t $(DOCKER_IMAGE):$$i $$i ; \
	done
