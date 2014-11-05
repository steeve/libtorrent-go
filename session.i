%{
#include <libtorrent/session.hpp>
%}

%include <std_vector.i>

namespace libtorrent
{
    class io_service;
    class cache_status;
    class cached_piece_info;
    class feed_settings;
    class feed_handle;
}

// These are problematic, so we ignore them.
%ignore libtorrent::session::get_ip_filter;
%ignore libtorrent::session::dht_put_item;

%template(std_vector_torrent_handle) std::vector<libtorrent::torrent_handle>;

%extend libtorrent::session {
    libtorrent::alert* pop_alert() {
        return self->pop_alert().release();
    }
}
%ignore libtorrent::session::pop_alert;

%include "extensions.i"
%include <libtorrent/session.hpp>
