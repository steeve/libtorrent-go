%{
#include "libtorrent/magnet_uri.hpp"

namespace libtorrent
{
    add_torrent_params parse_magnet_uri2(std::string const& uri)
    {
        error_code  ec;
        add_torrent_params  params;

        parse_magnet_uri(uri, params, ec);
        return params;
    }
}
%}

namespace libtorrent
{
    class session;

    add_torrent_params parse_magnet_uri2(std::string const& uri);
}
