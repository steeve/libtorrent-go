# Detect OS

ifeq ($(OS), Windows_NT)
    # On Windows, detect arch via GCC target
    GCC_TARGET = $(shell gcc -dumpmachine)
    ifneq ($(filter x86_64%,$(GCC_TARGET)),)
        ARCH = x64
    endif
    ifneq ($(filter i686%,$(GCC_TARGET)),)
        ARCH = x86
    endif
else
    UNAME_S := $(shell uname -s)
    UNAME_M := $(shell uname -m)
    ifeq ($(UNAME_S), Linux)
        OS = Linux
    endif
    ifeq ($(UNAME_S), Darwin)
        OS = Darwin
    endif
    ifeq ($(UNAME_M), i386)
        ARCH = x86
    endif
    ifeq ($(UNAME_M), x86_64)
        ARCH = x64
    endif
endif
