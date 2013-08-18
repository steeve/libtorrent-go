%{
#include "libtorrent/torrent_info.hpp"
%}

%include "libtorrent/entry.hpp"
%include "libtorrent/lazy_entry.hpp"
%include "libtorrent/copy_ptr.hpp"
%include "libtorrent/peer_id.hpp"

namespace libtorrent
{
    class lazy_entry;
    class file_storage;
    class announce_entry;
    class web_seed_entry;
    class file_slice;
    class peer_request;

    struct file_entry
    {
        std::string path;
        size_type offset;
        size_type size;
        size_type file_base;
        time_t mtime;
        sha1_hash filehash;
        bool pad_file:1;
        bool hidden_attribute:1;
        bool executable_attribute:1;
        bool symlink_attribute:1;
    };

    class torrent_info
    {
    public:

#ifdef TORRENT_DEBUG
        void check_invariant() const;
#endif

#ifndef BOOST_NO_EXCEPTIONS
        torrent_info(lazy_entry const& torrent_file, int flags = 0);
        torrent_info(char const* buffer, int size, int flags = 0);
        torrent_info(std::string const& filename, int flags = 0);
#if TORRENT_USE_WSTRING
        torrent_info(std::wstring const& filename, int flags = 0);
#endif // TORRENT_USE_WSTRING
#endif

        torrent_info(torrent_info const& t, int flags = 0);
        torrent_info(sha1_hash const& info_hash, int flags = 0);
        torrent_info(lazy_entry const& torrent_file, error_code& ec, int flags = 0);
        torrent_info(char const* buffer, int size, error_code& ec, int flags = 0);
        torrent_info(std::string const& filename, error_code& ec, int flags = 0);
#if TORRENT_USE_WSTRING
        torrent_info(std::wstring const& filename, error_code& ec, int flags = 0);
#endif // TORRENT_USE_WSTRING

        ~torrent_info();

        file_storage const& files() const { return m_files; }
        file_storage const& orig_files() const { return m_orig_files ? *m_orig_files : m_files; }

        void rename_file(int index, std::string const& new_filename)
        {
            copy_on_write();
            m_files.rename_file(index, new_filename);
        }

#if TORRENT_USE_WSTRING
        void rename_file(int index, std::wstring const& new_filename)
        {
            copy_on_write();
            m_files.rename_file(index, new_filename);
        }
#endif // TORRENT_USE_WSTRING

        void remap_files(file_storage const& f);

        void add_tracker(std::string const& url, int tier = 0);
        std::vector<announce_entry> const& trackers() const { return m_urls; }

#ifndef TORRENT_NO_DEPRECATE
        // deprecated in 0.16. Use web_seeds() instead
        TORRENT_DEPRECATED_PREFIX
        std::vector<std::string> url_seeds() const TORRENT_DEPRECATED;
        TORRENT_DEPRECATED_PREFIX
        std::vector<std::string> http_seeds() const TORRENT_DEPRECATED;
#endif // TORRENT_NO_DEPRECATE

        void add_url_seed(std::string const& url
            , std::string const& extern_auth = std::string()
            , web_seed_entry::headers_t const& extra_headers = web_seed_entry::headers_t());

        void add_http_seed(std::string const& url
            , std::string const& extern_auth = std::string()
            , web_seed_entry::headers_t const& extra_headers = web_seed_entry::headers_t());

        std::vector<web_seed_entry> const& web_seeds() const
        { return m_web_seeds; }

        size_type total_size() const { return m_files.total_size(); }
        int piece_length() const { return m_files.piece_length(); }
        int num_pieces() const { return m_files.num_pieces(); }
        const sha1_hash& info_hash() const { return m_info_hash; }
        const std::string& name() const { return m_files.name(); }

        typedef file_storage::iterator file_iterator;
        typedef file_storage::reverse_iterator reverse_file_iterator;

        file_iterator begin_files() const { return m_files.begin(); }
        file_iterator end_files() const { return m_files.end(); }
        reverse_file_iterator rbegin_files() const { return m_files.rbegin(); }
        reverse_file_iterator rend_files() const { return m_files.rend(); }
        int num_files() const { return m_files.num_files(); }
        file_entry file_at(int index) const { return m_files.at(index); }

        file_iterator file_at_offset(size_type offset) const
        { return m_files.file_at_offset(offset); }
        std::vector<file_slice> map_block(int piece, size_type offset, int size) const
        { return m_files.map_block(piece, offset, size); }
        peer_request map_file(int file, size_type offset, int size) const
        { return m_files.map_file(file, offset, size); }

#ifndef TORRENT_NO_DEPRECATE
// ------- start deprecation -------
// these functions will be removed in a future version
        TORRENT_DEPRECATED_PREFIX
        torrent_info(entry const& torrent_file) TORRENT_DEPRECATED;
        TORRENT_DEPRECATED_PREFIX
        void print(std::ostream& os) const TORRENT_DEPRECATED;
// ------- end deprecation -------
#endif

#ifdef TORRENT_USE_OPENSSL
        std::string const& ssl_cert() const { return m_ssl_root_cert; }
#endif

        bool is_valid() const { return m_files.is_valid(); }

        bool priv() const { return m_private; }

        bool is_i2p() const { return m_i2p; }

        int piece_size(int index) const { return m_files.piece_size(index); }

        sha1_hash hash_for_piece(int index) const
        { return sha1_hash(hash_for_piece_ptr(index)); }

        std::vector<sha1_hash> const& merkle_tree() const { return m_merkle_tree; }
        void set_merkle_tree(std::vector<sha1_hash>& h)
        { TORRENT_ASSERT(h.size() == m_merkle_tree.size() ); m_merkle_tree.swap(h); }

        char const* hash_for_piece_ptr(int index) const
        {
            TORRENT_ASSERT(index >= 0);
            TORRENT_ASSERT(index < m_files.num_pieces());
            if (is_merkle_torrent())
            {
                TORRENT_ASSERT(index < int(m_merkle_tree.size() - m_merkle_first_leaf));
                return (const char*)&m_merkle_tree[m_merkle_first_leaf + index][0];
            }
            else
            {
                TORRENT_ASSERT(m_piece_hashes);
                TORRENT_ASSERT(m_piece_hashes >= m_info_section.get());
                TORRENT_ASSERT(m_piece_hashes < m_info_section.get() + m_info_section_size);
                TORRENT_ASSERT(index < int(m_info_section_size / 20));
                return &m_piece_hashes[index*20];
            }
        }

        boost::optional<time_t> creation_date() const;

        const std::string& creator() const
        { return m_created_by; }

        const std::string& comment() const
        { return m_comment; }

        // dht nodes to add to the routing table/bootstrap from
        typedef std::vector<std::pair<std::string, int> > nodes_t;

        nodes_t const& nodes() const
        { return m_nodes; }
        void add_node(std::pair<std::string, int> const& node)
        { m_nodes.push_back(node); }

        bool parse_info_section(lazy_entry const& e, error_code& ec, int flags);

        lazy_entry const* info(char const* key) const
        {
            if (m_info_dict.type() == lazy_entry::none_t)
            {
                error_code ec;
                lazy_bdecode(m_info_section.get(), m_info_section.get()
                    + m_info_section_size, m_info_dict, ec);
            }
            return m_info_dict.dict_find(key);
        }

        void swap(torrent_info& ti);

        boost::shared_array<char> metadata() const
        { return m_info_section; }

        int metadata_size() const { return m_info_section_size; }

        bool add_merkle_nodes(std::map<int, sha1_hash> const& subtree
            , int piece);
        std::map<int, sha1_hash> build_merkle_list(int piece) const;
        bool is_merkle_torrent() const { return !m_merkle_tree.empty(); }

        // if we're logging member offsets, we need access to them
#if defined TORRENT_DEBUG \
        && !defined TORRENT_LOGGING \
        && !defined TORRENT_VERBOSE_LOGGING \
        && !defined TORRENT_ERROR_LOGGING
    private:
#endif

        // not assignable
        torrent_info const& operator=(torrent_info const&);

        void copy_on_write();
        bool parse_torrent_file(lazy_entry const& libtorrent, error_code& ec, int flags);

        // the index to the first leaf. This is where the hash for the
        // first piece is stored
        boost::uint32_t m_merkle_first_leaf;

        file_storage m_files;

        // if m_files is modified, it is first copied into
        // m_orig_files so that the original name and
        // filenames are preserved.
        copy_ptr<const file_storage> m_orig_files;

        // the urls to the trackers
        std::vector<announce_entry> m_urls;
        std::vector<web_seed_entry> m_web_seeds;
        nodes_t m_nodes;

        // if this is a merkle torrent, this is the merkle
        // tree. It has space for merkle_num_nodes(merkle_num_leafs(num_pieces))
        // hashes
        std::vector<sha1_hash> m_merkle_tree;

        // this is a copy of the info section from the torrent.
        // it use maintained in this flat format in order to
        // make it available through the metadata extension
        boost::shared_array<char> m_info_section;

        // this is a pointer into the m_info_section buffer
        // pointing to the first byte of the first sha-1 hash
        char const* m_piece_hashes;

        // TODO: these strings could be lazy_entry* to save memory

        // if a comment is found in the torrent file
        // this will be set to that comment
        std::string m_comment;

        // an optional string naming the software used
        // to create the torrent file
        std::string m_created_by;

#ifdef TORRENT_USE_OPENSSL
        // for ssl-torrens, this contains the root
        // certificate, in .pem format (i.e. ascii
        // base64 encoded with head and tails)
        std::string m_ssl_root_cert;
#endif

        // the info section parsed. points into m_info_section
        // parsed lazily
        mutable lazy_entry m_info_dict;

        // if a creation date is found in the torrent file
        // this will be set to that, otherwise it'll be
        // 1970, Jan 1
        time_t m_creation_date;

        // the hash that identifies this torrent
        sha1_hash m_info_hash;

        // the number of bytes in m_info_section
        boost::uint32_t m_info_section_size:24;

        // this is used when creating a torrent. If there's
        // only one file there are cases where it's impossible
        // to know if it should be written as a multifile torrent
        // or not. e.g. test/test  there's one file and one directory
        // and they have the same name.
        bool m_multifile:1;

        // this is true if the torrent is private. i.e., is should not
        // be announced on the dht
        bool m_private:1;

        // this is true if one of the trackers has an .i2p top
        // domain in its hostname. This means the DHT and LSD
        // features are disabled for this torrent (unless the
        // settings allows mixing i2p peers with regular peers)
        bool m_i2p:1;
    };
}
