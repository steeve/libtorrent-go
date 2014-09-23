// It should always be like this, according to https://code.google.com/p/go/source/browse/src/cmd/cgo/out.go#530
// Temp fix for https://code.google.com/p/go/issues/detail?id=6541
// See also https://code.google.com/p/go/issues/detail?id=5603
// See Makefile.
#ifdef __clang__
#   define SWIG_PACKED_STRUCT __attribute__((__packed__))
#else
#   define SWIG_PACKED_STRUCT __attribute__((__packed__, __gcc_struct__))
#endif
