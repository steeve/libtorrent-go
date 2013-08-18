%{
#include "libtorrent/session.hpp"
%}

namespace libtorrent
{
    class aux;
    class torrent_status;
    class torrent_handle;
    class io_service;
    class add_torrent_params;
    class session_status;
    class cache_status;
    class cached_piece_info;
    class feed_settings;
    class feed_handle;
    class address;
    struct time_duration;
}

// These need more work, so we just ignore them.
%ignore libtorrent::session::pop_alert;
%ignore libtorrent::session::get_ip_filter;
%ignore libtorrent::rel_boosttime_pools_nolog_resolvecountries_deprecated_dht_ext_;

%include "libtorrent/storage_defs.hpp"
%include "libtorrent/session_status.hpp"
%include "libtorrent/session.hpp"
