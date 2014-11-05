package libtorrent

// #cgo pkg-config: libtorrent-rasterbar openssl
// #cgo CFLAGS: -mthreads
// #cgo LDFLAGS: -shared -static-libgcc -static-libstdc++
import "C"
