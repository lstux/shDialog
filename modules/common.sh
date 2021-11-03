#!/bin/sh

# usage : shd_printvars [klength] varname1 [varname2 [varname3 ... varnameN]]
#   For every varnameX, print a key=value line. If klength is specified, assume
#   varname length is klength max.
shd_printvars() {
  local k v pattern="%s=%s"
  if [ ${1} -gt 0 ] 2>/dev/null; then pattern="%-${1}s=%s\n"; shift; fi
  for k in "$@"; do eval v=\"\${${k}}\"; printf "%s=%s\n" "${k}" "${v}"; done
}

# usage : shd_infos
#   Display shDialog configuration
shd_infos() {
  shd_printvars SHD_SWIDTH
}

# usage : shd_lorem [long=false [count=1]]
#   Used for functions examples, display a (long version of) "lorem ipsum" on
#   stdout count times
shd_lorem() {
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
  local i max_items="${1:-6}" prefix="${2:-item}"
  for i in $(seq ${max_items}); do echo "${prefix}${i}"; done
}

# usage : maxlinelenght
#   Read on stdin and display longest line length
maxlinelength() {
  local max=0 m l
  while read l; do m=$(echo "${l}" | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' | wc -c); [ ${m} -gt ${max} ] && max=${m}; done
  expr ${max} - 1
}
