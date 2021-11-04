#!/bin/sh
## Summary
## * shd_count
## * shd_number
## * shd_spinner
## * shd_gauger
## * shd_gauge
## * shd_columns

# usage : shd_count [max [message]]
#   count lines provided to stdin
shd_count() {
  local o
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "count lines provided to stdin\n"
       return 0;;
    X) shd_test "zcat /proc/config.gz | shd_count"
       shd_test "max=\$(zcat /proc/config.gz | wc -l); zcat /proc/config.gz | shd_count \$max"
       shd_test "max=\$(zcat /proc/config.gz | wc -l); zcat /proc/config.gz | shd_count \$max 'checking Kernel config'"
       return 0;;
    *) printf "Usage : shd_count [max [message]]\n  $(shd_count -D)\n  max may be specified to display a percentage\n  specified message may be displayed instead of line content\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  local max="${1}" message="${2}" msg pct l
  [ ${SHD_COUNTIDX} -gt 0 ] 2>/dev/null || SHD_COUNTIDX=0
  shd_blines 60 | \
  if [ -n "${max}" ]; then
    if [ -n "${message}" ]; then
      while read l; do
        SHD_COUNTIDX=$(expr ${SHD_COUNTIDX} + 1); pct=$(expr ${max} / ${SHD_COUNTIDX})
        printf "\r%-60s : %d/%d (%d%%)" "${message}" "${SHD_COUNTIDX}" "${max}" "${pct}"
      done
    else
      while read l; do
        SHD_COUNTIDX=$(expr ${SHD_COUNTIDX} + 1); pct=$(expr ${max} / ${SHD_COUNTIDX})
        printf "\r%-60s : %d/%d (%d%%)" "${l}" "${SHD_COUNTIDX}" "${max}" "${pct}"
      done
    fi
  else
    if [ -n "${message}" ]; then
      while read l; do
        SHD_COUNTIDX=$(expr ${SHD_COUNTIDX} + 1)
        printf "\r%-60s : %d" "${l}" "${SHD_COUNTIDX}"
      done
    else
      while read l; do
        SHD_COUNTIDX=$(expr ${SHD_COUNTIDX} + 1)
        printf "\r%-60s : %d" "${l}" "${SHD_COUNTIDX}"
      done
    fi
  fi
  printf "\n"
}

# usage : shd_number [pad=3]
# display text provided to stdin, numbering lines starting at SHD_NUMBERIDX
shd_number() {
  local o
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "display text provided to stdin, numbering lines starting at SHD_NUMBERIDX\n"
       return 0;;
    X) shd_test "shd_lorem long | shd_blines 30 | shd_number"
       shd_test "SHD_NUMBERIDX=10 shd_lorem long | shd_blines 30 | shd_number"
       return 0;;
    *) printf "Usage : shd_number [numpad]\n  $(shd_number -D)\n  numpad is line number width\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  [ ${SHD_NUMBERIDX} -gt 0 ] 2>/dev/null || SHD_NUMBERIDX=0
  local l w="${1:-03}"
  while read l; do
    SHD_NUMBERIDX="$(expr ${SHD_NUMBERIDX} + 1)"
    printf "%${w}d %s\n" "${SHD_NUMBERIDX}" "${l}"
  done
}

# usage : shd_spinner
# display a 'rotating' character while lines are read on stdin
shd_spinner() {
  local o
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "display a 'rotating' character while lines are read on stdin\n"
       return 0;;
    X) shd_test "shd_lorem long 10 | shd_blines 10 | while read l; do sleep 0.1; echo \${l}; done | shd_spinner"
       return 0;;
    *) printf "Usage : shd_spinner\n  $(shd_spinner -D)\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  local l i=0 c c0="-" c1="\\\\" c2="|" c3="/"
  while read l; do
    eval c=\"\${c${i}}\"
    printf -- "${c}\b"
    i=$(expr "(" ${i} + 1 ")" % 4)
  done
  printf " \n"
}

# usage : shd_gauger max message
# display an 'animated' progress bar based on (line read / max) ratio
shd_gauger() {
  local o
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "display an 'animated' progress bar based on (line read / max) ratio\n"
       return 0;;
    X) shd_test "for i in \$(seq 100); do echo '.'; done | while read l; do sleep 0.1; echo \${l}; done | shd_gauger 100 'proceeding...'"
       return 0;;
    *) printf "Usage : shd_gauger max [message]\n  $(shd_gauger -D)\n  we expect max lines to be read on stdin"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  local max="${1}" msg="${2}" l idx=0 pct=0 ew e i
  local gw="$(expr ${SHD_SWIDTH} - 5)"
  if [ -n "${msg}" ]; then
    l="$(echo ${msg} | wc -c)"
    gw="$(expr ${gw} - ${l})"
  fi
  [ ${max} -ge 0 ] 2>/dev/null || return 1
  while read l; do
    idx=$(expr ${idx} + 1)
    pct=$(expr ${idx} \* 100 / ${max})
    ew=$(expr ${gw} \* ${idx} / ${max})
    e=""; for i in $(seq ${ew}); do e="${e}="; done
    [ ${idx} -ge ${max} ] && e="${e}=" || e="${e}>"
    ew=$(expr ${gw} - ${ew})
    printf "\r%s[%s%${ew}s]%3d%%" "${msg}" "${e}" "" "${pct}"
  done
  printf "\n"
}

# usage : shd_gauge pct message
# display a progress bar based on provided percentage
shd_gauge() {
  local o
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "display a progress bar based on provided percentage\n"
       return 0;;
    X) shd_test "for i in \$(seq 10); do shd_gauge $(expr ${i} \* 10 ) 'proceeding'; sleep 0.2; done"
       return 0;;
    *) printf "Usage : shd_gauge percentage [message]\n  $(shd_gauge -D)\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  local pct="${1}" msg="${2}" ew e i
  local gw="$(expr ${SHD_SWIDTH} - 5)"
  if [ -n "${msg}" ]; then
    local l="$(echo ${msg} | wc -c)"
    gw="$(expr ${gw} - ${l})"
  fi
  ew=$(expr ${gw} \* ${pct} / 100)
  e=""; for i in $(seq ${ew}); do e="${e}="; done
  ew=$(expr ${gw} - ${ew})
  printf "%s[%s%${ew}s]%3d%%" "${msg}" "${e}>" "" "${pct}"
}

# usage : shd_colums [nbcolumns=2] [width=SHD_SWIDTH]
# display a text in nbcolumns columns, all fitting in width
shd_columns() {
  local o
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "display text provided to stdin in nbcolumns columns, all fitting in width\n"
       return 0;;
    X) shd_test "shd_lorem long 4 | shd_columns"
       shd_test "shd_lorem long 3 | shd_columns 3 60"
       return 0;;
    *) printf "Usage : shd_columns [nbcolumns=2 [width=SHD_SWIDTH]]\n  $(shd_columns -D)\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
  local c="${1:-2}" w="${2:-${SHD_SWIDTH}}" sep=" ${SHD_COLUMNSEP} "
  local buffer="" b l
  while read l; do buffer="${buffer}${l}\n"; done
  b="$(expr "(" ${c} - 1 ")" \* 3)"
  local cw=$(expr "(" ${w} - ${b} ")" / ${c}) bh ch i j
  buffer="$(echo "${buffer}" | shd_blines ${cw})"
  bh="$(echo "${buffer}" | wc -l)"
  ch=$(expr "${bh}" / ${c})
  [ "$(expr ${ch} \* ${c})" = "${bh}" ] || ch=$(expr ${ch} + 1)
  for i in $(seq ${ch}); do
    l=${i}
    for j in $(seq ${c}); do
      printf "%-${cw}s" "$(echo "${buffer}" | sed -n ${l}p)"
      [ ${j} -eq ${c} ] && printf "\n" || printf "${SHD_COLUMNCOLOR}%3s${SHD_nrm}" "${sep}"
      l=$(expr ${l} + ${ch})
    done
  done
}
