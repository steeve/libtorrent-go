%{
#include <libtorrent/ed25519.hpp>
%}

%apply unsigned char *INOUT { unsigned char *public_key, unsigned char *private_key, const unsigned char *seed };
%include <libtorrent/ed25519.hpp>
