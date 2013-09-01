// Shamelessly made from https://github.com/ssalevan/rbtorrent/blob/master/ext/rbtorrent/alert.i

namespace libtorrent {
  class peer_id;
  class peer_request;
  class torrent_handle;


  %nodefaultctor torrent_alert;
  struct torrent_alert: alert
  {
    torrent_handle handle;
  };

  %nodefaultctor tracker_alert;
  struct tracker_alert: torrent_alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    tracker_alert(torrent_handle const& h
      , int times
      , int status
      , std::string const& url_
      , std::string const& msg)
      : torrent_alert(h, alert::warning, msg)
      , times_in_row(times)
      , status_code(status)
      , url(url_);
#endif

#if LIBTORRENT_VERSION_MINOR == 13
    int times_in_row;
    int status_code;
#endif
    std::string url;
  };

  %nodefaultctor tracker_warning_alert;
  struct tracker_warning_alert: torrent_alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    tracker_warning_alert(torrent_handle const& h
      , std::string const& msg)
      : torrent_alert(h, alert::warning, msg);
#elif LIBTORRENT_VERSION_MINOR >= 14
    tracker_warning_alert(torrent_handle const& h
      , std::string const& url_
      , std::string const& msg_);
#endif
  };

  struct scrape_reply_alert: torrent_alert
  {
    scrape_reply_alert(torrent_handle const& h
      , int incomplete_
      , int complete_
      , std::string const& msg)
      : torrent_alert(h, alert::info, msg)
      , incomplete(incomplete_)
      , complete(complete_);

    int incomplete;
    int complete;
  };

  %nodefaultctor scrape_failed_alert;
  struct scrape_failed_alert: torrent_alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    scrape_failed_alert(torrent_handle const& h
      , std::string const& msg)
      : torrent_alert(h, alert::warning, msg);
#elif LIBTORRENT_VERSION_MINOR >= 14
    scrape_failed_alert(torrent_handle const& h
      , std::string const& url_
      , std::string const& msg_)
      : tracker_alert(h, url_)
      , msg(msg_);
#endif
  };

  struct tracker_reply_alert: torrent_alert
  {
    tracker_reply_alert(torrent_handle const& h
      , int np
      , std::string const& msg)
      : alert(h, alert::info, msg)
      , num_peers(np);

    int num_peers;
  };

  %nodefaultctor tracker_announce_alert;
  struct tracker_announce_alert: torrent_alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    tracker_announce_alert(torrent_handle const& h, std::string const& msg)
      : torrent_alert(h, alert::info, msg);
#elif LIBTORRENT_VERSION_MINOR >= 14
    tracker_announce_alert(torrent_handle const& h
      , std::string const& url_, int event_)
      : tracker_alert(h, url_)
      , event(event_);
#endif
  };

  %nodefaultctor hash_failed_alert;
  struct hash_failed_alert: torrent_alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    hash_failed_alert(
      torrent_handle const& h
      , int index
      , std::string const& msg)
      : torrent_alert(h, alert::info, msg)
      , piece_index(index);
#elif LIBTORRENT_VERSION_MINOR >= 14
    hash_failed_alert(
      torrent_handle const& h
      , int index)
      : torrent_alert(h)
      , piece_index(index);
#endif
    int piece_index;
  };

  %nodefaultctor peer_ban_alert;
  struct peer_ban_alert: torrent_alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    peer_ban_alert(asio::ip::tcp::endpoint const& pip, torrent_handle h, std::string const& msg)
      : torrent_alert(h, alert::info, msg)
      , ip(pip);
#elif LIBTORRENT_VERSION_MINOR >= 14
    peer_ban_alert(torrent_handle h, asio::ip::tcp::endpoint const& ip
      , peer_id const& pid)
      : peer_alert(h, ip, pid);
#endif

#if LIBTORRENT_VERSION_MINOR == 13
    asio::ip::tcp::endpoint ip;
#elif LIBTORRENT_VERSION_MINOR >= 14
    boost::asio::ip::tcp::endpoint ip;
#endif
  };

  %nodefaultctor peer_error_alert;
  struct peer_error_alert: alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    peer_error_alert(asio::ip::tcp::endpoint const& pip, peer_id const& pid_, std::string const& msg)
      : alert(alert::debug, msg)
      , ip(pip)
      , pid(pid_);
#elif LIBTORRENT_VERSION_MINOR >= 14
    peer_error_alert(torrent_handle const& h, tcp::endpoint const& ip
      , peer_id const& pid, std::string const& msg_)
      : peer_alert(h, ip, pid)
      , msg(msg_);
#endif

#if LIBTORRENT_VERSION_MINOR == 13
    asio::ip::tcp::endpoint ip;
#elif LIBTORRENT_VERSION_MINOR >= 14
    boost::asio::ip::tcp::endpoint ip;
#endif
    peer_id pid;
  };

  %nodefaultctor invalid_request_alert;
  struct invalid_request_alert: torrent_alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    invalid_request_alert(
      peer_request const& r
      , torrent_handle const& h
      , asio::ip::tcp::endpoint const& sender
      , peer_id const& pid_
      , std::string const& msg)
      : torrent_alert(h, alert::debug, msg)
      , ip(sender)
      , request(r)
      , pid(pid_);
#elif LIBTORRENT_VERSION_MINOR >= 14
    invalid_request_alert(torrent_handle const& h, tcp::endpoint const& ip
      , peer_id const& pid, peer_request const& r)
      : peer_alert(h, ip, pid)
      , request(r);
#endif

#if LIBTORRENT_VERSION_MINOR == 13
    asio::ip::tcp::endpoint ip;
#elif LIBTORRENT_VERSION_MINOR >= 14
    boost::asio::ip::tcp::endpoint ip;
#endif
    peer_request request;
    peer_id pid;
  };

  %nodefaultctor torrent_finished_alert;
  struct torrent_finished_alert: torrent_alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    torrent_finished_alert(
      const torrent_handle& h
      , const std::string& msg)
      : torrent_alert(h, alert::warning, msg);
#elif LIBTORRENT_VERSION_MINOR >= 14
    torrent_finished_alert(
      const torrent_handle& h)
      : torrent_alert(h);
#endif

  };

  %nodefaultctor piece_finished_alert;
  struct piece_finished_alert: torrent_alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    piece_finished_alert(
      const torrent_handle& h
      , int piece_num
      , const std::string& msg)
      : torrent_alert(h, alert::debug, msg)
      , piece_index(piece_num);
#elif LIBTORRENT_VERSION_MINOR >= 14
    piece_finished_alert(
      const torrent_handle& h
      , int piece_num)
      : torrent_alert(h)
      , piece_index(piece_num);
#endif

    int piece_index;

  };

  %nodefaultctor block_finished_alert;
  struct block_finished_alert: torrent_alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    block_finished_alert(
      const torrent_handle& h
      , int block_num
      , int piece_num
      , const std::string& msg)
      : torrent_alert(h, alert::debug, msg)
      , block_index(block_num)
      , piece_index(piece_num);
#elif LIBTORRENT_VERSION_MINOR >= 14
    block_finished_alert(const torrent_handle& h, tcp::endpoint const& ip
      , peer_id const& pid, int block_num, int piece_num)
      : peer_alert(h, ip, pid)
      , block_index(block_num)
      , piece_index(piece_num);
#endif

    int block_index;
    int piece_index;

  };

  %nodefaultctor block_downloading_alert;
  struct block_downloading_alert: torrent_alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    block_downloading_alert(
      const torrent_handle& h
      , char const* speedmsg
      , int block_num
      , int piece_num
      , const std::string& msg)
      : torrent_alert(h, alert::debug, msg)
      , peer_speedmsg(speedmsg)
      , block_index(block_num)
      , piece_index(piece_num);
#elif LIBTORRENT_VERSION_MINOR >= 14
    block_downloading_alert(const torrent_handle& h, tcp::endpoint const& ip
      , peer_id const& pid, char const* speedmsg, int block_num, int piece_num)
      : peer_alert(h, ip, pid)
      , peer_speedmsg(speedmsg)
      , block_index(block_num)
      , piece_index(piece_num);
#endif

#if LIBTORRENT_VERSION_MINOR == 13
    std::string peer_speedmsg;
#elif LIBTORRENT_VERSION_MINOR >= 14
    char const* peer_speedmsg;
#endif
    int block_index;
    int piece_index;

  };

  struct storage_moved_alert: torrent_alert
  {
    storage_moved_alert(torrent_handle const& h, std::string const& path)
      : torrent_alert(h, alert::warning, path);

  };

  %nodefaultctor torrent_deleted_alert;
  struct torrent_deleted_alert: torrent_alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    torrent_deleted_alert(torrent_handle const& h, std::string const& msg)
      : torrent_alert(h, alert::warning, msg);
#elif LIBTORRENT_VERSION_MINOR >= 14
    torrent_deleted_alert(torrent_handle const& h)
      : torrent_alert(h);
#endif
  };

  %nodefaultctor torrent_paused_alert;
  struct torrent_paused_alert: torrent_alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    torrent_paused_alert(torrent_handle const& h, std::string const& msg)
      : torrent_alert(h, alert::warning, msg);
#elif LIBTORRENT_VERSION_MINOR >= 14
    torrent_paused_alert(torrent_handle const& h)
      : torrent_alert(h);
#endif
  };

  %nodefaultctor torrent_checked_alert;
  struct torrent_checked_alert: torrent_alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    torrent_checked_alert(torrent_handle const& h, std::string const& msg)
      : torrent_alert(h, alert::info, msg);
#elif LIBTORRENT_VERSION_MINOR >= 14
    torrent_checked_alert(torrent_handle const& h)
      : torrent_alert(h);
#endif
  };


  struct url_seed_alert: torrent_alert
  {
    url_seed_alert(
      torrent_handle const& h
      , const std::string& url_
      , const std::string& msg)
      : torrent_alert(h, alert::warning, msg)
      , url(url_);

    std::string url;
  };

  %nodefaultctor file_error_alert;
  struct file_error_alert: torrent_alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    file_error_alert(
      const torrent_handle& h
      , const std::string& msg)
      : torrent_alert(h, alert::fatal, msg);
#elif LIBTORRENT_VERSION_MINOR >= 14
    file_error_alert(
      std::string const& f
      , const torrent_handle& h
      , const std::string& msg_)
      : torrent_alert(h)
      , file(f)
      , msg(msg_);
#endif
  };

  %nodefaultctor metadata_failed_alert;
  struct metadata_failed_alert: torrent_alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    metadata_failed_alert(
      const torrent_handle& h
      , const std::string& msg)
      : torrent_alert(h, alert::info, msg);
#elif LIBTORRENT_VERSION_MINOR >= 14
    metadata_failed_alert(const torrent_handle& h)
      : torrent_alert(h);
#endif
  };

  %nodefaultctor metadata_received_alert;
  struct metadata_received_alert: torrent_alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    metadata_received_alert(
      const torrent_handle& h
      , const std::string& msg)
      : torrent_alert(h, alert::info, msg);
#elif LIBTORRENT_VERSION_MINOR >= 14
    metadata_received_alert(
      const torrent_handle& h)
      : torrent_alert(h);
#endif
  };

  %nodefaultctor listen_failed_alert;
  struct listen_failed_alert: alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    listen_failed_alert(
      asio::ip::tcp::endpoint const& ep
      , std::string const& msg)
      : alert(alert::fatal, msg)
      , endpoint(ep);
#elif LIBTORRENT_VERSION_MINOR >= 14
    listen_failed_alert(
      tcp::endpoint const& ep
      , error_code const& ec)
      : endpoint(ep)
      , error(ec);
#endif

#if LIBTORRENT_VERSION_MINOR == 13
    asio::ip::tcp::endpoint endpoint;
#elif LIBTORRENT_VERSION_MINOR >= 14
    boost::asio::ip::tcp::endpoint endpoint;
#endif
  };

  %nodefaultctor listen_succeeded_alert;
  struct listen_succeeded_alert: alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    listen_succeeded_alert(
      asio::ip::tcp::endpoint const& ep
      , std::string const& msg)
      : alert(alert::fatal, msg)
      , endpoint(ep);
#elif LIBTORRENT_VERSION_MINOR >= 14
    listen_succeeded_alert(tcp::endpoint const& ep)
      : endpoint(ep);
#endif

#if LIBTORRENT_VERSION_MINOR == 13
    asio::ip::tcp::endpoint endpoint;
#elif LIBTORRENT_VERSION_MINOR >= 14
    boost::asio::ip::tcp::endpoint endpoint;
#endif
  };

  %nodefaultctor portmap_error_alert;
  struct portmap_error_alert: alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    portmap_error_alert(const std::string& msg)
      : alert(alert::warning, msg);
#elif LIBTORRENT_VERSION_MINOR >= 14
    portmap_error_alert(int i, int t, const std::string& msg_)
      :  mapping(i), type(t), msg(msg_);
#endif
  };

  %nodefaultctor portmap_alert;
  struct portmap_alert: alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    portmap_alert(const std::string& msg)
      : alert(alert::info, msg);
#elif LIBTORRENT_VERSION_MINOR >= 14
    portmap_alert(int i, int port, int t)
      : mapping(i), external_port(port), type(t);
#endif
  };

  struct fastresume_rejected_alert: torrent_alert
  {
    fastresume_rejected_alert(torrent_handle const& h
      , std::string const& msg)
      : torrent_alert(h, alert::warning, msg);
  };

  %nodefaultctor peer_blocked_alert;
  struct peer_blocked_alert: alert
  {
#if LIBTORRENT_VERSION_MINOR == 13
    peer_blocked_alert(asio::ip::address const& ip_
      , std::string const& msg)
      : alert(alert::info, msg)
      , ip(ip_);
#elif LIBTORRENT_VERSION_MINOR >= 14
    peer_blocked_alert(address const& ip_)
      : ip(ip_);
#endif

#if LIBTORRENT_VERSION_MINOR == 13
    asio::ip::address ip;
#elif LIBTORRENT_VERSION_MINOR >= 14
    boost::asio::ip::address ip;
#endif
  };

}
