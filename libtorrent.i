%module libtorrent

%include "std_string.i"
%include "stdint.i"

namespace libtorrent {
  typedef uint64_t size_type;
}

#define BOOST_POSIX_API

%ignore libtorrent::throw_invalid_handle;

%include <boost/preprocessor/cat.hpp>

%include "libtorrent/config.hpp"
%include "libtorrent/version.hpp"
%include "libtorrent/build_config.hpp"

%include "error_code.i"

%include "common.i"
%include "torrent_info.i"
%include "libtorrent/fingerprint.hpp"

%include "add_torrent_params.i"

%include "alert.i"
%include "alert_types.i"
%include "session_settings.i"
%include "session.i"
%include "magnet_uri.i"
%include "torrent_handle.i"

