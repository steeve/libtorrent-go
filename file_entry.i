%{
#include "libtorrent/file_storage.hpp"
%}

namespace libtorrent
{
    class peer_request;
}
%include "libtorrent/size_type.hpp"
%include "libtorrent/file_storage.hpp"

%extend libtorrent::file_entry
{
    void    get_offset2(int64_t *OUTPUT)
    {
        *OUTPUT = $self->offset;
    }

    void    get_size2(int64_t *OUTPUT)
    {
        *OUTPUT = $self->size;
    }
}
