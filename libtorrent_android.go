// +build android

package libtorrent

// #cgo pkg-config: libtorrent-rasterbar openssl
// #cgo linux LDFLAGS: -lm -lgnustl_shared -ldl
import "C"
