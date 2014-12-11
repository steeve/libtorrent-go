%{
#include <libtorrent/kademlia/item.hpp>
#include <boost/bind.hpp>
%}

%{
namespace libtorrent {
    void put_item(entry& e, boost::array<char, 64>& sig, boost::uint64_t& seq,
                  std::string const& salt, char const* public_key,
                  char const* private_key, entry& new_entry) {
        using libtorrent::dht::sign_mutable_item;

        e = new_entry;
        std::vector<char> buf;
        bencode(std::back_inserter(buf), new_entry);
        ++seq;
        sign_mutable_item(
            std::pair<char const*, int>(&buf[0], buf.size()),
            std::pair<char const*, int>(&salt[0], salt.size()),
            seq,
            public_key,
            private_key,
            sig.data());
    }
}
%}

%extend libtorrent::session {
    void dht_put_item(entry& e, std::string pubkey, std::string privkey) {
        boost::array<char, 32> public_key;
        boost::array<char, 64> private_key;
        public_key.operator=<std::string>(pubkey);
        private_key.operator=<std::string>(privkey);

        $self->dht_put_item(
            public_key,
            boost::bind(
                &libtorrent::put_item,
                _1, _2, _3, _4,
                public_key,
                private_key,
                e));
    }
}
