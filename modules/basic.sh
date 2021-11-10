#!/bin/sh
## Summary
## * shd_blines
## * shd_center
## * shd_underline
## * shd_boxed
## * shd_rainbow
## * shd_timestamp
## * shd_error
## * shd_notice
## * shd_message
## * shd_warning
## * shd_debug
## * shd_list
## * shd_olist
## * shd_title{1-4}
## * shd_par

## shd_function() {
##   OPTIND=0; while getopts DXh o; do case "${o}" in
##     D) printf "Do some operations on line as argument";;
##     X) printf "";;
##     *) printf "";;
##   esac; done
##   shift $(expr ${OPTIND} - 1)
##   local line="${1}"
##   some_ops on "${line}"
## }

# usage : shd_blines [width [some text]]
#   display text given as argument or read from stdin on stdout,
#   breaking lines so length is less or equal to width
shd_blines() {
  local o
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "Break lines to specified width\n"
       return 0;;
    X) shd_test "shd_lorem long | shd_blines 24"
       shd_test "shd_lorem long | shd_blines 60 | shd_center"
       return 0;;
    *) printf "Usage : shd_blines [width [\"line\"]]\n  $(shd_blines -D)\n  if no line specified read from stdin\n  default width is SHD_SWIDTH\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  local width="${1:-${SHD_SWIDTH}}" line="${2}"
  if [ -n "${line}" -a "${line}" != "-" ]; then echo "${line}" | shd_blines ${width} #sed "s/\\(.\\{${width}\\}\\)/\\1\\n/g"
  else sed "s/\\(.\\{${width}\\}\\)/\\1\\n/g"; fi
}

# usage : shd_center [some text]
#   display text given as argument or read from stdin centered on stdout
shd_center() {
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "Center text (relative to specified width)\n"
       return 0;;
    X) shd_test "shd_lorem long | shd_blines 24"
       shd_test "shd_lorem long | shd_blines 60 | shd_center 80"
       return 0;;
    *) printf "Usage : shd_center [width [\"line\"]]\n  $(shd_center -D)\n  if no line specified read from stdin\n  default width is SHD_SWIDTH\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  local width="${1:-${SHD_SWIDTH}}" line="${2}" lw pad i
  if [ -n "${line}" -a "${line}" != "-" ]; then echo "${line}" | shd_center ${width}
  else
    while read line; do
      lw="$(echo "${line}" | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' | wc -c)"
      pad=$(expr \( ${width} - ${lw} + 1 \) / 2)
      for i in $(seq ${pad}); do printf " "; done
      printf -- "${line}\n"
    done
  fi
}

# usage : shd_underline [some text]
# display text given as argument or read from stdin underlined on stdout
shd_underline() {
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "Underline text\n"
       return 0;;
    X) shd_test "shd_underline 'some_text'"
       shd_test "echo 'some other text' | shd_underline"
       return 0;;
    *) printf "Usage : shd_underline [\"line\"]\n  $(shd_underline -D)\n  if no line specified read from stdin\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  if [ -n "${1}" -a "${1}" != "-" ]; then
    local lw="$(echo "${1}" | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' | wc -c)" i
    printf -- "${1}\n${SHD_UNDERLINECOLOR}${SHD_UNDERLINECHAREXT}"
    lw=$(expr ${lw} - 3)
    for i in $(seq 1 ${lw}); do printf "${SHD_UNDERLINECHAR}"; done
    printf -- "${SHD_UNDERLINECHAREXT}${SHD_nrm}\n"
  else
    local line
    while read line; do shd_underline "${line}"; done
  fi
}

# usage : shd_boxed [some text]
#   display text given as argument or read from stdin in a box on stdout
shd_boxed() {
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "Display 'boxed' text\n"
       return 0;;
    X) shd_test "shd_boxed 'some_text'"
       shd_test "shd_lorem | shd_boxed"
       return 0;;
    *) printf "Usage : shd_boxed [\"line\"]\n  $(shd_boxed -D)\n  if no line specified read from stdin\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  local buffer=""
  if [ -z "${1}" -o "${1}" = "-" ]; then
    local l w i el
    while read l; do buffer="${buffer}${l}\n"; done
    w="$(echo "${buffer}" | shd_maxlinelength)"
    el="${SHD_BORDERCCHAR}${SHD_BORDERHCHAR}"
    for i in $(seq 1 ${w}); do el="${el}${SHD_BORDERHCHAR}"; done
    el="${el}${SHD_BORDERHCHAR}${SHD_BORDERCCHAR}"
    printf "${SHD_BORDERCOLOR}${el}\n"
    echo "${buffer}" | while read l; do
      [ -n "${l}" ] && printf "${SHD_BORDERCOLOR}${SHD_BORDERVCHAR}${SHD_nrm} %-${w}s ${SHD_BORDERCOLOR}${SHD_BORDERVCHAR}${SHD_nrm}\n" "${l}"
    done
    printf "${SHD_BORDERCOLOR}${el}${SHD_nrm}\n"
  else echo "$@" | shd_boxed; fi
}

# usage : shd_rainbow [some text]
#   display text given as argument or read from stdin colored on stdout
shd_rainbow() {
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "Display rainbow colored text\n"
       return 0;;
    X) shd_test "shd_lorem long | shd_rainbow"
       shd_test "shd_rainbow 'one color per word, wow thats psychedelic... :P"
       return 0;;
    *) printf "Usage : shd_rainbow [\"line\"]\n  $(shd_rainbow -D)\n  if no line specified read from stdin\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  local l w i=0 c
  local r1="${SHD_red}" r2="${SHD_mgt}" r3="${SHD_ylw}"
  local r4="${SHD_grn}" r5="${SHD_cyn}" r6="${SHD_blu}"
  if [ -z "${1}" -o "${1}" = "-" ]; then
    while read l; do
      for w in ${l}; do
        i=$(expr ${i} + 1); [ ${i} -gt 6 ] && i=1
        eval c=\"\${r${i}}\"
        printf "${c}${w} "
      done
      printf "${SHD_nrm}\n"
    done
  else echo "$@" | shd_rainbow; fi
}

# usage : shd_timestamp some text
#   display text given as argument prefixed with a 'timestamp'
shd_timestamp() {
    OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "Display timestamped text\n"
       return 0;;
    X) shd_test "shd_timestamp 'some text'"
       return 0;;
    *) printf "Usage : shd_timestamp some text\n  $(shd_timestamp -D)\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  printf "$(date "+${SHD_TSFORMAT}") $@\n"
}

# usage : shd_error "some text" [errcode]
#   display error message on stderr, return 255 or given errcode
shd_error()     {
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "Display error message\n"
       return 0;;
    X) shd_test "shd_error 'oups...' 2; echo \$?"
       return 0;;
    *) printf "Usage : shd_error 'message' [errcode]\n  $(shd_error -D)\n  default errcode is 255\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  printf "[${SHD_red}ERR${SHD_nrm}] ${1}\n" >&2
  [ ${2} -gt 0 ] 2>/dev/null && return ${2}
  return 255
}

# usage : shd_notice some text
#   display a notice message on stderr
shd_notice()    {
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "Display notice message\n"
       return 0;;
    X) shd_test "shd_notice 'my message'"
       return 0;;
    *) printf "Usage : shd_notice 'message'\n  $(shd_notice -D)\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  printf "[${SHD_mgt}NOT${SHD_nrm}] $@\n" >&2
}

# usage : shd_message some text
#   display a message on stderr
shd_message()   {
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "Display informational message\n"
       return 0;;
    X) shd_test "shd_message 'my message'"
       return 0;;
    *) printf "Usage : shd_message 'message'\n  $(shd_message -D)\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  printf "[${SHD_blu}MSG${SHD_nrm}] $@\n" >&2
}

# usage : shd_warning some text
#   display a warning message on stderr
shd_warning()   {
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "Display warning message\n"
       return 0;;
    X) shd_test "shd_message 'my warning message'"
       return 0;;
    *) printf "Usage : shd_warning 'message'\n  $(shd_warning -D)\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  printf "[${SHD_ylw}WRN${SHD_nrm}] $@\n" >&2
}

# usage : shd_debug some text
#   display a debug message on stderr
shd_debug()     {
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "Display debug message\n"
       return 0;;
    X) shd_test "shd_debug 'my message'"
       return 0;;
    *) printf "Usage : shd_debug 'message'\n  $(shd_debug -D)\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  printf "[${SHD_wht}DBG${SHD_nrm}] $@\n" >&2
}

# usage : shd_list [item1 [item2 ....]]
#   display a list of unordered items (provided as args or read from stdin)
shd_list() {
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "Display a list of unordered items\n"
       return 0;;
    X) shd_test "shd_list 'My first item' 'My second item' 'My third item'"
       shd_test "printf \"My first item\nMy second item\nMy third item\n\" | shd_list"
       return 0;;
    *) printf "Usage : shd_list [item1 [item2 ...]]\n  $(shd_list -D)\n  if no args given, read items from stdin 1/line\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  local l="${1}"
  if [ -n "${l}" -a "${l}" != "-" ]; then while [ -n "${1}" ]; do echo "${l}" | shd_list; shift; done
  else while read l; do printf "  ${SHD_LISTCOLOR}${SHD_LISTCHAR}${SHD_nrm} %s\n" "${l}"; done; fi
}

# usage : shd_olist [item1 [item2 ....]]
#   display a list of ordered items (provided as args or read from stdin), index is stored in SHD_OLIST
shd_olist() {
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "Display a list of ordered items\n"
       return 0;;
    X) shd_test "shd_olist 'My first item' 'My second item' 'My third item'"
       shd_test "printf \"My first item\nMy second item\nMy third item\n\" | shd_olist"
       return 0;;
    *) printf "Usage : shd_olist [item1 [item2 ...]]\n  $(shd_olist -D)\n  if no args given, read items from stdin 1/line\n  index is stored in SHD_OLIST\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  local line="${1}"
  if [ -n "${1}" -a "${1}" != "-" ]; then
    while [ -n "${1}" ]; do
      SHD_OLIST="$(expr ${SHD_OLIST} + 1)"
      printf " ${SHD_LISTCOLOR}%2d)${SHD_nrm} %s\n" "${SHD_OLIST}" "${line}"
      shift
    done
  else
    while read line; do shd_olist "${line}"; done
  fi
}

# usage : shd_titleX some text
shd_title1() {
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "wrapper for level 1 title\n"
       return 0;;
    X) shd_test "shd_title1 'My title (level1)'"
       return 0;;
    *) printf "Usage : shd_title1 'title'\n  $(shd_title1 -D)\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  shd_boxed "$@" | shd_center
}

shd_title2() {
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "wrapper for level 2 title\n"
       return 0;;
    X) shd_test "shd_title2 'My title (level2)'"
       return 0;;
    *) printf "Usage : shd_title2 'title'\n  $(shd_title2 -D)\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  shd_boxed "$@"
}

shd_title3() {
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "wrapper for level 3 title\n"
       return 0;;
    X) shd_test "shd_title3 'My title (level3)'"
       return 0;;
    *) printf "Usage : shd_title3 'title'\n  $(shd_title3 -D)\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  shd_underline "$@"
}

shd_title4() {
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "wrapper for level 4 title\n"
       return 0;;
    X) shd_test "shd_title4 'My title (level4)'"
       return 0;;
    *) printf "Usage : shd_title4 'title'\n  $(shd_title4 -D)\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  shd_underline "$@"
}

shd_par()    {
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "wrapper for paragraphs\n"
       return 0;;
    X) shd_test "shd_par '\$(shd_lorem long)'"
       return 0;;
    *) printf "Usage : shd_par 'some text'\n  $(shd_par -D)\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  shd_blines "  $@"
}


# usage : shd_table [ -t "table title" ] [-H "head1;head2;head3...."] ["v11;v12;v13..." ["v21;v22,v23..." ...]]
#   display a table, reading values from csv lines as parameter or from stdin
shd_table() {
  local title="" header=""
  OPTIND=0; while getopts DXt:H:h o; do case "${o}" in
    D) printf "Display a simple table\n"
       return 0;;
    X) shd_test "shd_table -t 'A test table' -H 'Field1;Field2;Field3;Field4' 'v11;v12;v13;v14' 'v21;v22;v23;v24'"
       shd_test "printf \"v11;v12;v13;v14\\\nv21;v22;v23;v24\\\n\" | shd_table -H 'Field1;Field2;Field3;Field4'"
       return 0;;
    t) title="${OPTARG}";;
    H) header="${OPTARG}";;
    *) printf "Usage : shd_table [-t 'table title'] [-H 'head1;head2;head3....'] ['v11;v12;v13...' ['v21;v22,v23...' ...]]\n  $(shd_table -D)\n  csv lines can be provided as arguments or from stdin\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)

  local values="" l
  if [ -n "${1}" ]; then while [ -n "${1}" ]; do values="${values}${1}\n"; shift; done
  else while read l; do values="${values}${l}\n"; done;   fi

  local pattern="" hpattern="" max i=1 twidth=0
  while true; do
    max="$(echo -e "${header}\n${values}" | awk -F";" '{print $'${i}'}' | shd_maxlinelength)"
    [ "${max}" = "0" ] && break
    pattern="${pattern}${SHD_BORDERCOLOR}${SHD_BORDERVCHAR}${SHD_nrm} %-${max}s "
    hpattern="${hpattern}${SHD_BORDERCOLOR}${SHD_BORDERVCHAR}${SHD_nrm} ${SHD_HEADERCOLOR}%-${max}s${SHD_nrm} "
    i=$(expr ${i} + 1)
    twidth=$(expr ${twidth} + 3 + ${max})
  done
  pattern="${pattern} ${SHD_BORDERCOLOR}${SHD_BORDERVCHAR}${SHD_nrm}\n"
  hpattern="${hpattern} ${SHD_BORDERCOLOR}${SHD_BORDERVCHAR}${SHD_nrm}\n"
  local vline="${SHD_BORDERCOLOR}${SHD_BORDERCCHAR}"; for i in $(seq ${twidth}); do vline="${vline}${SHD_BORDERHCHAR}"; done; vline="${vline}${SHD_BORDERCCHAR}${SHD_nrm}\n"

  if [ -n "${title}" ]; then
    twidth=$(expr ${twidth} - 2)
    printf "${vline}${SHD_BORDERCOLOR}${SHD_BORDERVCHAR} ${SHD_TITLECOLOR}%-${twidth}s ${SHD_BORDERCOLOR}${SHD_BORDERVCHAR}${SHD_nrm}\n" "${title}"
  fi
  printf "${vline}"
  if [ -n "${header}" ]; then
    eval printf \"\${hpattern}\" \"$(echo "${header}" | sed 's/;/" "/g')\"
    printf "${vline}"
  fi
  echo -e "${values}" | while read l; do
    [ -n "${l}" ] || continue
    eval printf \"\${pattern}\" \"$(echo "${l}" | sed 's/;/" "/g')\"
  done
  printf "${vline}"
}
