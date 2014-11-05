%{
#include <sstream>
#include <libtorrent/bencode.hpp>
%}

%include <libtorrent/entry.hpp>
%include <libtorrent/lazy_entry.hpp>

%extend libtorrent::entry {
    std::string bencode() {
        std::ostringstream oss;
        libtorrent::bencode(std::ostream_iterator<char>(oss), *self);
        return oss.str();
    }
}
