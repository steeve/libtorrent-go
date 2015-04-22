%{
#include <libtorrent/kademlia/item.hpp>
#include <libtorrent/ed25519.hpp>
#include <boost/bind.hpp>
#include <stdio.h>
%}

%{
namespace libtorrent {
    class dht_put_operation {
    public:
        entry                   *data;
        boost::array<char, 32>  public_key;
        boost::array<char, 64>  private_key;
        std::string             salt;

        dht_put_operation(unsigned char* public_key, unsigned char* private_key) {
            for (int i = 0; i < 32; i++) {
                this->public_key[i] = public_key[i];
            }
            for (int i = 0; i < 64; i++) {
                this->private_key[i] = private_key[i];
            }
        }
    };

    class dht_get_operation {
    public:
        entry                   *data;
        boost::array<char, 32>  public_key;
        std::string             salt;

        dht_get_operation(unsigned char* public_key) {
            for (int i = 0; i < 32; i++) {
                this->public_key[i] = public_key[i];
            }
        }
    };

    void dht_put_item_cb(entry& e, boost::array<char, 64>& sig, boost::uint64_t& seq,
        std::string const& salt, char const* public_key, char const* private_key,
        entry& data)
    {
        e = data;
        std::vector<char> buf;
        bencode(std::back_inserter(buf), e);
        seq++;
        libtorrent::dht::sign_mutable_item(
            std::pair<char const*, int>(buf.data(), buf.size()),
            std::pair<char const*, int>(salt.data(), salt.size()),
            seq,
            public_key,
            private_key,
            sig.data());
    }
}
%}

namespace libtorrent {
    class dht_put_operation {
    public:
        entry                   *data;
        boost::array<char, 32>  public_key;
        boost::array<char, 64>  private_key;
        std::string             salt;

        dht_put_operation(unsigned char* public_key, unsigned char* private_key);
    };

    class dht_get_operation {
    public:
        entry                   *data;
        boost::array<char, 32>  public_key;
        std::string             salt;

        dht_get_operation(unsigned char* public_key);
    };
}

%extend libtorrent::session {
    libtorrent::sha1_hash dht_put_item(entry& item) {
        return $self->dht_put_item(item);
    }

    void dht_get_item(libtorrent::dht_get_operation& op) {
        $self->dht_get_item(op.public_key, op.salt);
    }

    void dht_put_mutable_item(libtorrent::dht_put_operation& op) {
        $self->dht_put_item(
            op.public_key,
            boost::bind(
                &libtorrent::dht_put_item_cb, _1, _2, _3, _4,
                op.public_key.data(), op.private_key.data(), *op.data),
            op.salt);
    }
}
