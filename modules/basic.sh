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

# usage : shd_blines [some text]
#   display text given as argument or read from stdin on stdout,
#   breaking lines so length is less or equal to SHD_SWIDTH
shd_blines() {
  local width="${1:-${SHD_SWIDTH}}" line="${2}"
  if [ -n "${line}" -a "${line}" != "-" ]; then echo "${line}" | shd_blines ${width} #sed "s/\\(.\\{${width}\\}\\)/\\1\\n/g"
  else sed "s/\\(.\\{${width}\\}\\)/\\1\\n/g"; fi
}

# usage : shd_center [some text]
#   display text given as argument or read from stdin centered on stdout
shd_center() {
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
  local buffer=""
  if [ -z "${1}" -o "${1}" = "-" ]; then
    local l w i el
    while read l; do buffer="${buffer}${l}\n"; done
    w="$(echo "${buffer}" | maxlinelength)"
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
shd_timestamp() { printf "$(date "+${SHD_TSFORMAT}") $@\n"; }

# usage : shd_error "some text" [errcode]
#   display error message on stderr, return 255 or given errcode
shd_error()     { printf "[${SHD_red}ERR${SHD_nrm}] ${1}\n" >&2; [ ${2} -gt 0 ] 2>/dev/null && return ${2}; return 255; }

# usage : shd_notice some text
#   display a notice message on stderr
shd_notice()    { printf "[${SHD_mgt}NOT${SHD_nrm}] $@\n" >&2; }

# usage : shd_message some text
#   display a message on stderr
shd_message()   { printf "[${SHD_blu}MSG${SHD_nrm}] $@\n" >&2; }

# usage : shd_warning some text
#   display a warning message on stderr
shd_warning()   { printf "[${SHD_ylw}WRN${SHD_nrm}] $@\n" >&2; }

# usage : shd_debug some text
#   display a debug message on stderr
shd_debug()     { printf "[${SHD_wht}DBG${SHD_nrm}] $@\n" >&2; }

# usage : shd_list [item1 [item2 ....]]
#   display a list of unordered items (provided as args or read from stdin)
shd_list() {
  local l="${1}"
  if [ -n "${l}" -a "${l}" != "-" ]; then while [ -n "${1}" ]; do echo "${l}" | shd_list; shift; done
  else while read l; do printf "  ${SHD_LISTCOLOR}${SHD_LISTCHAR}${SHD_nrm} %s\n" "${l}"; done; fi
}

# usage : shd_olist [item1 [item2 ....]]
#   display a list of ordered items (provided as args or read from stdin), index is stored in SHD_OLIST
shd_olist() {
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
shd_title1() { shd_boxed "$@" | shd_center; }
shd_title2() { shd_boxed "$@"; }
shd_title3() { shd_underline "$@"; }
shd_title4() { shd_underline "$@"; }
shd_par()    { shd_blines "  $@"; }


# usage : shd_table "table title" ["head1;head2;head3...." ["v11;v12;v13..." ["v21;v22,v23..." ...]]]
#   display a table, reading values from csv lines as parameter or from stdin
shd_table() {
  local title="${1}" header="${2}"
  shift 2
  local values="" l
  if [ -n "${1}" ]; then
    while [ -n "${1}" ]; do values="${values}${1}\n"; shift; done
  else
    [ -n "${header}" ] || read header
    while read l; do values="${values}${l}\n"; done
  fi
  local pattern="" max i=1
  while true; do
    max="$(echo -e "${header}\n${values}" | awk -F";" '{print $'${i}'}' | maxlinelength)"
    [ "${max}" = "0" ] && break
    pattern="${pattern}| %-${max}s "
    i=$(expr ${i} + 1)
  done
  pattern="${pattern} |\n"
  local twidth="$(printf "${pattern}" | wc -c)"
  twidth="$(expr ${twidth} - 3)"
  local vline="*"; for i in $(seq ${twidth}); do vline="${vline}-"; done; vline="${vline}*\n"
  printf "${vline}"
  eval printf \"\${pattern}\" \"$(echo "${header}" | sed 's/;/" "/g')\"
  printf "${vline}"
  echo -e "${values}" | while read l; do
    [ -n "${l}" ] || continue
    eval printf \"\${pattern}\" \"$(echo "${l}" | sed 's/;/" "/g')\"
  done
  printf "${vline}"
}
