# Detect OS
ifeq ($(OS),Windows_NT)
    ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
        ARCH = x64
    endif
    ifeq ($(PROCESSOR_ARCHITECTURE),x86)
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
    ifeq ($(UNAME_M),x86_64)
        ARCH = x64
    endif
    ifeq ($(UNAME_M),I386)
        ARCH = x86
    endif
    ifeq ($(UNAME_M),arm)
        ARCH = arm
    endif
endif
