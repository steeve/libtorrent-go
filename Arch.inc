GCC_TARGET = $(shell $(CC) -dumpmachine)

ifneq ($(findstring x86_64, $(GCC_TARGET)),)
    ARCH = x64
endif
ifneq ($(findstring i386, $(GCC_TARGET)),)
    ARCH = x86
endif
ifneq ($(findstring i586, $(GCC_TARGET)),)
    ARCH = x86
endif
ifneq ($(findstring i686, $(GCC_TARGET)),)
    ARCH = x86
endif
ifneq ($(findstring arm, $(GCC_TARGET)),)
    ARCH = arm
endif
