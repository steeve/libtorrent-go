%{
#include <sstream>
#include <libtorrent/bencode.hpp>
%}

%include <libtorrent/entry.hpp>
%include <libtorrent/lazy_entry.hpp>

namespace libtorrent {
    std::string bencode(const entry& e);
    error_code lazy_bdecode(std::string data, lazy_entry& ret);
}

%{
namespace libtorrent {
    std::string bencode(const entry& e) {
        std::ostringstream oss;
        bencode(std::ostream_iterator<char>(oss), e);
        return oss.str();
    }

    error_code lazy_bdecode(std::string data, lazy_entry& ret) {
        error_code ec;
        lazy_bdecode((const char*)data.c_str(), (const char*)(data.c_str() + data.size()), ret, ec);
        return ec;
    }
}
%}
