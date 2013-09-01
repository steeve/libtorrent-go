%{
#include "libtorrent/alert.hpp"
#include "libtorrent/alert_types.hpp"
%}

namespace libtorrent
{
  class peer_id;
  class peer_request;
  class torrent_handle;

  class TORRENT_EXPORT alert
  {
  public:

#ifndef TORRENT_NO_DEPRECATE
    // only here for backwards compatibility
    enum severity_t { debug, info, warning, critical, fatal, none };
#endif

    enum category_t
    {
      error_notification = 0x1,
      peer_notification = 0x2,
      port_mapping_notification = 0x4,
      storage_notification = 0x8,
      tracker_notification = 0x10,
      debug_notification = 0x20,
      status_notification = 0x40,
      progress_notification = 0x80,
      ip_block_notification = 0x100,
      performance_warning = 0x200,
      dht_notification = 0x400,
      stats_notification = 0x800,
      rss_notification = 0x1000,

      // since the enum is signed, make sure this isn't
      // interpreted as -1. For instance, boost.python
      // does that and fails when assigning it to an
      // unsigned parameter.
      all_categories = 0x7fffffff
    };

    alert();
    virtual ~alert();

    // a timestamp is automatically created in the constructor
    ptime timestamp() const;

    virtual int type() const = 0;
    virtual char const* what() const = 0;
    virtual std::string message() const = 0;
    virtual int category() const = 0;
    virtual bool discardable() const { return true; }

#ifndef TORRENT_NO_DEPRECATE
    TORRENT_DEPRECATED_PREFIX
    severity_t severity() const TORRENT_DEPRECATED { return warning; }
#endif
  };
}
