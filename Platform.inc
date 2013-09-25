# Detect OS
GCC_TARGET = $(shell gcc -dumpmachine)

ifneq ($(filter x86_64%,$(GCC_TARGET)),)
    ARCH = x64
endif
ifneq ($(filter i686%,$(GCC_TARGET)),)
    ARCH = x86
endif

ifneq ($(OS),Windows_NT)
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S), Linux)
        OS = Linux
    endif
    ifeq ($(UNAME_S), Darwin)
        OS = Darwin
    endif
endif
