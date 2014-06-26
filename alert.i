%{
#include <libtorrent/alert.hpp>
%}

// std::auto_ptr cuases problems, so we ignore the methods which use it
%ignore libtorrent::alert::clone;
%include <libtorrent/alert.hpp>
