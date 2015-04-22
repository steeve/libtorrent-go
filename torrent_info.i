%{
#include <libtorrent/torrent_info.hpp>
#include <boost/intrusive_ptr.hpp>
%}

%ignore libtorrent::sha1_hash::begin;
%ignore libtorrent::sha1_hash::end;

%include <libtorrent/sha1_hash.hpp>
%include "entry.i"
%include <libtorrent/peer_id.hpp>
%include "file_storage.i"
%include <libtorrent/torrent_info.hpp>
