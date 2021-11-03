#!/bin/sh
## Summary
## * shd_confirm
## * shd_ask
## * shd_askvar

# usage: shd_confirm [question]
#   ask user for confirmation, return 0 if user answers 'yes', 1 else
shd_confirm() {
  local question="${1}"
  [ -n "${question}" ] || question="Type '${SHD_grn}yes${SHD_nrm}' to continue"
  printf "${SHD_grn}>${SHD_nrm} ${question} : "
  read a
  [ "${a}" = "yes" ] && return 0
  return 1
}

# usage : shd_ask question [default]
#   ask user for a question, allowing yes or no as answer (return 0 for yes, 1 else)
shd_ask() {
  local prompt="(${SHD_grn}y${SHD_nrm}/${SHD_red}n${SHD_nrm})" question="${1}" default="${2}" d="" a
  case "${default}" in
    y|Y|0) d=0; prompt="(${SHD_grn}[y]${SHD_nrm}/${SHD_red}n${SHD_nrm})";;
    n|N|1) d=1; prompt="(${SHD_grn}y${SHD_nrm}/${SHD_red}[n]${SHD_nrm})";;
  esac
  while true; do
    printf "${SHD_grn}>${SHD_nrm} ${question} ${prompt} "
    read a
    case "${a}" in
      y|Y|0) return 0;;
      n|N|1) return 1;;
      "")    [ ${d} -ge 0 ] 2>/dev/null && return "${d}"; printf "Default answer is undefined" >&2;;
    esac
    printf "${SHD_ylw}>${SHD_nrm} Please answer with '${SHD_grn}y${SHD_nrm}' or '${SHD_red}n${SHD_nrm}'.\n" >&2
    sleep 2
    printf "\n"
  done
}

# usage : shd_askvar varname default [prompt=Enter value for '${varname}']
#   ask user to enter a value for varname
shd_askvar() {
  local varname="${1}" default="${2}" prompt="${3}" value
  eval value=\"\$${varname}\"
  [ -n "${value}" ] && default="${value}"
  [ -n "${prompt}" ] || prompt="Enter a value for '${varname}'"
  printf "${SHD_grn}>${SHD_nrm} ${prompt} [${default}] : "
  read value
  [ -n "${value}" ] || value="${default}"
  eval ${varname}=\"${value}\"
}


# usage : shd_menu title "label1:execfunc1" "label2:execfunc2" ...
shd_menu() {
  local title="${1}" i arg k v a
  shift
  while true; do
    printf "${title}\n"
    i=0
    for arg in "$@"; do
      i=$(expr ${i} + 1)
      k="$(echo "${arg}" | sed 's/:.*$//')"
      v="$(echo "${arg}" | sed 's/^.*://')"
      printf " %2d) %s (%s)\n" "${i}" "${k}" "${v}"
    done
    printf " %2d) Quit\n" "0"
    read -p "Your choice [0-${i}] > " a
    [ ${a} -eq 0 ] 2>/dev/null && return 0
    [ ${a} -ge 1 -a ${a} -le ${i} ] 2>/dev/null && break
    printf "Please enter a value between 0 and ${i}...\n"
    sleep 2
    printf "\n"
  done
  i=0
  for arg in "$@"; do
    i=$(expr ${i} + 1)
    if [ ${i} -eq ${a} ]; then
      v="$(echo "${arg}" | sed 's/^.*://')"
      ${v}
      return $?
    fi
  done
}

