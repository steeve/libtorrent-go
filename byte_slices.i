%typemap(gotype) unsigned char* "[]byte"

%typemap(in) unsigned char*
%{
    $1 = ($1_ltype)$input.array;
%}
