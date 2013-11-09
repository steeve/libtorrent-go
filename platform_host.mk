ifeq ($(OS), Windows_NT)
    HOST_OS = windows
    ifeq ($(PROCESSOR_ARCHITECTURE), AMD64)
        ARCH = x64
    else ifeq ($(PROCESSOR_ARCHITECTURE), x86)
        ARCH = x86
    endif
else
    UNAME_S := $(shell uname -s)
    UNAME_M := $(shell uname -m)
    ifeq ($(UNAME_S), Linux)
        HOST_OS = linux
    else ifeq ($(UNAME_S), Darwin)
        HOST_OS = darwin
    endif
    ifeq ($(UNAME_M), x86_64)
        HOST_ARCH = x64
    else ifneq ($(filter %86, $(UNAME_M)),)
        HOST_ARCH = x86
    else ifneq ($(findstring arm, $(UNAME_M)),)
        HOST_ARCH = arm
    endif
endif
