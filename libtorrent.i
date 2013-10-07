%module libtorrent

%include "std_string.i"
%include "stdint.i"

#define BOOST_POSIX_API

namespace libtorrent
{
    typedef int64_t size_type;
}

%ignore libtorrent::throw_invalid_handle;
%ignore libtorrent::session::add_extension;

%include <boost/preprocessor/cat.hpp>

%include "libtorrent/config.hpp"
%include "libtorrent/version.hpp"
%include "libtorrent/build_config.hpp"
%include "libtorrent/size_type.hpp"

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
%include "libtorrent/file_storage.hpp"
