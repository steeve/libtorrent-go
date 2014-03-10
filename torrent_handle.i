%{
#include "libtorrent/torrent_handle.hpp"

namespace libtorrent
{
    float get_piece_progress(const torrent_handle& handle, int index)
    {
        if (handle.have_piece(index))
        {
            return 1.0;
        }

        std::vector<partial_piece_info> q;
        handle.get_download_queue(q);
        for (std::vector<partial_piece_info>::iterator it = q.begin(); it != q.end(); it++)
        {
            partial_piece_info pi = (*it);
            if (pi.piece_index == index)
            {
                unsigned int total_bytes_progress = 0;
                unsigned int total_block_size = 0;
                for (int i = 0; i < pi.blocks_in_piece; i++)
                {
                    block_info bi = pi.blocks[i];
                    total_bytes_progress += bi.bytes_progress;
                    total_block_size += bi.block_size;
                }
                return (float)total_bytes_progress / (float)total_block_size;
            }
        }

        return 0.0;
    }
}
%}

namespace libtorrent
{
    class tcp;
}

%include "libtorrent/bitfield.hpp"
%include "libtorrent/torrent_handle.hpp"

namespace libtorrent
{
    float get_piece_progress(const torrent_handle& handle, int index);
}
