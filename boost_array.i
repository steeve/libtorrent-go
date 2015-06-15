%{
#include <boost/array.hpp>
#include <stdio.h>
%}

%typemap(gotype) boost::array<char, 32>, boost::array<char, 64>, boost::array<char, 32>*, boost::array<char, 64>*  "[]byte"

%typemap(in) boost::array
%{
    memcpy($1.data(), $input.array, $1.size() < $input.len ? $1.size() : $input.len);
%}

%typemap(out) boost::array
%{
    $result.array = (void*)$1.data();
    $result.len = (intgo)$1.size();
    $result.cap = $result.len;
%}

%typemap(out) boost::array*
%{
    $result.array = (void*)$1->data();
    $result.len = (intgo)$1->size();
    $result.cap = $result.len;
%}

%include <boost/array.hpp>
