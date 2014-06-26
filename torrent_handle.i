%{
#include "libtorrent/torrent_handle.hpp"
%}

%include "std_vector.i"
%template(partial_piece_info_list) std::vector<libtorrent::partial_piece_info>;

%include "carrays.i"
%array_class(libtorrent::block_info, block_info_list);

%extend libtorrent::torrent_handle {
    const libtorrent::torrent_info* torrent_file() {
        return self->torrent_file().get();
    }
}
%ignore libtorrent::torrent_handle::torrent_file;

%extend libtorrent::partial_piece_info {
    block_info_list* blocks() {
        return block_info_list_frompointer(self->blocks);
    }
}
%ignore libtorrent::partial_piece_info::blocks;

%include <libtorrent/torrent_handle.hpp>
