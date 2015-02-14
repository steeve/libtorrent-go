libtorrent-go
=============

SWIG Go bindings for [libtorrent-rasterbar](http://www.libtorrent.org/)


#### Supported platforms
- Android (ARM)
- Linux (x64/x86/ARM)
- Mac OSX (x64)
- Windows (x64/x86)

## Building instructions
libtorrent-go uses [Docker](https://github.com/docker/docker) to simplify cross-compilation. On your development machine it requires:

- A working [Docker](https://github.com/docker/docker) setup (boot2docker is fine)
- A working [Go](https://github.com/golang/go) setup (GOPATH properly configured)
- Make

##### Build all supported platforms
```
git clone https://github.com/steeve/libtorrent-go
cd libtorrent-go
make
```
##### Build specific platform (ex: Linux/x64)
```
git clone https://github.com/steeve/libtorrent-go
cd libtorrent-go
make PLATFORMS=linux-x64
```
## Usage instructions
The simplest way to use libtorrent-go in your app is to build your code using the Docker images used when compiling the library. An example will soon be published.

When building for Windows, make sure you distribute libtorrent-go.dll along your executable. This is a current limitation when using native libraries on Windows. This will probably be fixed later.

- Windows/x64: ```$GOPATH/pkg/windows_amd64/github.com/steeve/libtorrent-go.dll```
- Windows/x86: ```$GOPATH/pkg/windows_386/github.com/steeve/libtorrent-go.dll```
