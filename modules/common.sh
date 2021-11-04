#!/bin/sh

# usage : shd_printvars [klength] varname1 [varname2 [varname3 ... varnameN]]
#   For every varnameX, print a key=value line. If klength is specified, assume
#   varname length is klength max.
shd_printvars() {
  local o
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "display a bunch of variables values\n"
       return 0;;
    X) shd_test "shd_printvars SHELL C_ALL"
       shd_test "shd_printvars 10 SHELL C_ALL"
       return 0;;
    *) printf "Usage : shd_printvars [width] varname1 [varname2 [varname3 ...]]\n  $(shd_printvars -D)\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  local k v pattern="%s=%s"
  if [ ${1} -gt 0 ] 2>/dev/null; then pattern="%-${1}s=%s\n"; shift; fi
  for k in "$@"; do eval v=\"\${${k}}\"; printf "%s=%s\n" "${k}" "${v}"; done
}

# usage : shd_infos
#   Display shDialog configuration
shd_infos() {
  local o
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "display shDialogs configuration\n"
       return 0;;
    X) shd_test "shd_infos"
       return 0;;
    *) printf "Usage : shd_infos\n  $(shd_infos -D)\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  shd_printvars SHD_SWIDTH
}

# usage : shd_lorem [long=false [count=1]]
#   Used for functions examples, display a (long version of) "lorem ipsum" on
#   stdout count times
shd_lorem() {
  local o
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "display a 'lorem ipsum' paragprah (used for examples)\n"
       return 0;;
    X) shd_test "shd_lorem"
       shd_test "shd_lorem true"
       shd_test "shd_lorem false 3"
       return 0;;
    *) printf "Usage : shd_lorem [long=false [count=1]]\n  $(shd_lorem -D)\n  long should be 'true' or 'false'\n  repeat count times\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  local long="${1:-false}" count=${2:-1} i
  [ "${long}" = "true" ] || long=false # it may ONLY be 'true' or 'false'
  for i in $(seq ${count}); do
    printf "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    ${long} && printf " Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    printf "\n"
  done
}

# usage : shd_items [nbitems=6 [prefix=item]]
#   Used for functions examples, display a list nbitems items on stdout, named 'prefixN'
shd_items() {
  local o
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "display a list of items (used for examples)\n"
       return 0;;
    X) shd_test "shd_items"
       shd_test "shd_items 3"
       shd_test "shd_items 3 EXAMPLE_"
       return 0;;
    *) printf "Usage : shd_items [nbitems=6 [prefix=item]]\n  $(shd_items -D)\n  display nbitems prefixed with 'item'\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  local i max_items="${1:-6}" prefix="${2:-item}"
  for i in $(seq ${max_items}); do echo "${prefix}${i}"; done
}

# usage : shd_maxlinelength
#   Read on stdin and display longest line length
shd_maxlinelength() {
  local o
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "get max line length in a text (used internally)\n"
       return 0;;
    X) shd_test "shd_lorem | shd_maxlinelength"
       shd_test "shd_lorem | shd_blines 20 | shd_maxlinelength"
       return 0;;
    *) printf "Usage : shd_maxlinelength\n  $(shd_maxlinelength -D)\n  read from stdin\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  local max=0 m l
  while read l; do m=$(echo "${l}" | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' | wc -c); [ ${m} -gt ${max} ] && max=${m}; done
  expr ${max} - 1
}
