%module libtorrent

%{
#include <libtorrent/session.hpp>
%}

%include <stl.i>
%include <stdint.i>
%include <typemaps.i>

#ifdef SWIGWIN
    %include <windows.i>
    %include "dllmain.i"
#endif

#define BOOST_POSIX_API

namespace std {
    typedef int time_t;
    %template(pair_int_int) std::pair<int, int>;
}

namespace boost {
    typedef ::int64_t int64_t;
}

namespace libtorrent
{
    typedef int64_t size_type;
    class ptime;
}

// These are problematic, ignore them for now
%ignore libtorrent::throw_invalid_handle;
%ignore libtorrent::session::add_extension;
%ignore libtorrent::web_seed_entry;

%include <boost/preprocessor/cat.hpp>
%include <boost/version.hpp>
%include <boost/config/suffix.hpp>
%include <boost/system/config.hpp>
%include <boost/system/error_code.hpp>
%include <boost/asio/detail/config.hpp>
%include <boost/asio/error.hpp>

%include <libtorrent/config.hpp>
%include <libtorrent/version.hpp>
%include <libtorrent/build_config.hpp>
%include <libtorrent/size_type.hpp>
%include <libtorrent/error_code.hpp>
%include <libtorrent/error.hpp>

%include <libtorrent/fingerprint.hpp>
%include <libtorrent/bitfield.hpp>
%include "socket.i"
%include <libtorrent/address.hpp>
%include "torrent_info.i"
%include <libtorrent/session_settings.hpp>
%include "torrent_handle.i"
%include <libtorrent/session_status.hpp>
%include <libtorrent/add_torrent_params.hpp>
%include "alert.i"
%include "alert_types.i"
%include <libtorrent/ptime.hpp>
%include <libtorrent/time.hpp>
%include "session.i"
