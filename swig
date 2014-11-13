#!/bin/bash
if [ "$1" == "-go" ]; then
    args=`getopt -a -q --long go,outdir:,module: -n ${0} -- "$@"`
    swig_args=
    while [ $# -gt 0 ]; do
        case "$1" in
            (-go) swig_args+="${1} ${SWIG_FLAGS}"; shift;;
            (-module)
                module=$2
                swig_args+=" ${1} ${2} "
                shift; shift;;
            (-outdir)
                outdir=$2
                swig_args+=" ${1} ${2} "
                shift; shift;;
            (--) shift; break;;
            (*) swig_args+=" ${1} "; shift;;
        esac
    done
    /usr/local/bin/swig ${swig_args}
    sed -i -e 's/#pragma dynimport \(.*\) \(\"\"\)/#pragma dynimport \1 "'"${SONAME}"'"/g' \
            "${outdir}/${module}_gc.c"
else
    /usr/local/bin/swig "$@"
fi
