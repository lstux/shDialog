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
  local max="${1}" message="${2}" msg pct l
  [ ${SHD_COUNTIDX} -gt 0 ] 2>/dev/null || SHD_COUNTIDX=0
  if [ -n "${max}" ]; then
    if [ -n "${message}" ]; then
      while read l; do
        SHD_COUNTIDX=$(expr ${SHD_COUNTIDX} + 1); pct=$(expr ${max} / ${SHDCOUNTIDX})
        printf "\r%s : %d/%d (%d%%)" "${message}" "${SHD_COUNTIDX}" "${max}" "${pct}"
      done
    else
      while read l; do
        SHD_COUNTIDX=$(expr ${SHD_COUNTIDX} + 1); pct=$(expr ${max} / ${SHDCOUNTIDX})
        printf "\r%s : %d/%d (%d%%)" "${l}" "${SHD_COUNTIDX}" "${max}" "${pct}"
      done
    fi
  else
    if [ -n "${message}" ]; then
      while read l; do
        SHD_COUNTIDX=$(expr ${SHD_COUNTIDX} + 1)
        printf "\r%s : %d" "${l}" "${SHD_COUNTIDX}"
      done
    else
      while read l; do
        SHD_COUNTIDX=$(expr ${SHD_COUNTIDX} + 1)
        printf "\r%s : %d" "${l}" "${SHD_COUNTIDX}"
      done
    fi
  fi
  printf "\n"
}

# usage : shd_number [pad=3]
# display text provided to stdin, numbering lines starting at SHD_NUMBERIDX
shd_number() {
  [ ${SHD_NUMBERIDX} -gt 0 ] || SHD_NUMBERIDX=0
  local l w=${1:-3}
  while read l; do
    SHD_NUMBERIDX="$(expr ${SHD_NUMBERIDX} + 1)"
    printf "%${w}d %s\n" "${SHD_NUMBERIDX}" "${l}"
  done
}





shd_spinner() {
  local l i=0 c c0="-" c1="\\\\" c2="|" c3="/"
  while read l; do
    eval c=\"\${c${i}}\"
    printf -- "${c}\b"
    i=$(expr "(" ${i} + 1 ")" % 4)
  done
  printf " \n"
}

shd_gauger() {
  local max="${1}" msg="${2}" l idx=0 pct=0 ew e i
  local gw="$(expr ${SHD_SWIDTH} - 5)"
  if [ -n "${msg}" ]; then
    l="$(echo ${msg} | wc -c)"
    gw="$(expr ${gw} - ${l})"
  fi
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

shd_gauge() {
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

shd_columns() {
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
