# Detect the build OS, if not supplied
ifneq ($(OS), Windows_NT)
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S), Linux)
        OS = Linux
    endif
    ifeq ($(UNAME_S), Darwin)
        OS = Darwin
    endif
endif
