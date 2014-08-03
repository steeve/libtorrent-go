%include "std_pair.i"

namespace std
{
    %template(pair_int_int) std::pair<int, int>;
    %template(pair_str_int) std::pair<std::string, int>;
}
