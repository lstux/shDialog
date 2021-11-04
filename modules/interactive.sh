#!/bin/sh
## Summary
## * shd_confirm
## * shd_ask
## * shd_askvar

# usage: shd_confirm [question]
#   ask user for confirmation, return 0 if user answers 'yes', 1 else
shd_confirm() {
  local o
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "ask user for confirmation\n"
       return 0;;
    X) shd_test "shd_confirm; echo \$?"
       shd_test "shd_confirm 'are you really sure?'; echo \$?"
       return 0;;
    *) printf "Usage : shd_confirm [question]\n  $(shd_confirm -D)\n  user should confirm a choice by typing 'yes'\n  returns 0 if user confirms, 1 else\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
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
  local o
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "ask user a question which he should answer with yes or no\n"
       return 0;;
    X) shd_test "shd_ask 'should we continue?'; echo \$?"
       shd_test "shd_ask 'should we continue?' n; echo \$?"
       return 0;;
    *) printf "Usage : shd_ask question [default]\n  $(shd_ask -D)\n  user should answer y or n\n  a default answer may be set\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
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
  local o
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "ask user to enter a value vor a variable\n"
       return 0;;
    X) shd_test "shd_askvar MYVAR mv_def_value; echo \$MYVAR"
       shd_test "shd_askvar MYVAR mv_def_value 'Which value should be stored in MYVAR?'; echo \$MYVAR"
       return 0;;
    *) printf "Usage : shd_askvar varname default_value [prompt]\n  $(shd_askvar -D)\n  default prompt is 'Enter a value for varname'\n"; return 0;;
  esac; done
  shift $(expr ${OPTIND} - 1)
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
  local o
  OPTIND=0; while getopts DXh o; do case "${o}" in
    D) printf "a simple menu, a command may be associated to each choice\n"
       return 0;;
    X) shd_test "shd_menu 'My first menu' 'Choice 1:echo choice1' 'Choice 2:date'"
       return 0;;
    *) printf "Usage : shd_menu 'title' {item1[:cmd1]} [{item2[:cmd2]} ...] \n  $(shd_menu -D)\n"; return 0;;
  esac; done
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
