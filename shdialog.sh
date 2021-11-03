#!/bin/sh
DEBUG="${DEBUG:-false}"
shd_dbg() { ${DEBUG} 2>/dev/null && printf "shdialog DEBUG : ${1}\n" >&2; }
shd_test() { printf -- "\n\e[1;33m**\e[0m $@\n" >&2; eval "$@"; }

SCRIPTNAME="shdialog"
SHD_WORKDIR="${SHD_WORKDIR:-/usr/share/${SCRIPTNAME}}"
shd_dbg "SHD_WORKDIR=${SHD_WORKDIR}"
for c in /etc/ ${HOME}/.; do
  [ -e "${c}${SCRIPTNAME}.conf" ] || continue
  . "${c}${SCRIPTNAME}.conf"
  shd_dbg "loaded configuration file '${c}${SCRIPTNAME}.conf'"
done

# usage : shd_eval varname
#   Evaluate varname variable value if it references a 'SHD' variable
# example : var="SHD_VALUE"; shd_eval var; <= var will contain ${SHD_VALUE}
shd_eval() {
  local var="${1}" val
  eval val=\"\$${var}\"
  case "${val}" in
    ${SHD_PREFIX}*) eval ${var}=\"\$${val}\";;
  esac
}

shd_modules_funcs() {
  local m mname f
  for m in "${SHD_WORKDIR}/modules/"*.sh; do
    printf "Module ${SHD_grn}$(basename "${m}" .sh)${SHD_nrm}\n"
    sed -n "s/^\(shd_.*\)().*$/\1/p" "${m}" | while read f; do
      d="$(${f} -D)"; printf " * %-16s %s\n" "${f}" "${d}"
    done
  done
}

# Do not modify!
# Use ~/.shdialog.conf or /etc/shdialog.conf to override these
SHD_PREFIX="SHD_"
SHD_COLORS="${SHD_COLORS:-true}"
if ${SHD_COLORS}; then
  SHD_red='\e[1;31m'; SHD_grn='\e[1;32m'; SHD_ylw='\e[1;33m'
  SHD_blu='\e[1;34m'; SHD_mgt='\e[1;35m'; SHD_cyn='\e[1;36m'
  SHD_wht='\e[1;37m'; SHD_nrm='\e[0m'
fi
SHD_SWIDTH="${SHD_SWIDTH:-auto}"
SHD_BORDERHCHAR="${SHD_BORDERHCHAR:--}"
SHD_BORDERVCHAR="${SHD_BORDERVCHAR:-|}"
SHD_BORDERCCHAR="${SHD_BORDERCCHAR:-*}"
SHD_BORDERCOLOR="${SHD_BORDERCOLOR:-${SHD_blu}}"
SHD_LISTCHAR="${SHD_LISTCHAR:-*}"
SHD_LISTCOLOR="${SHD_LISTCOLOR:-SHD_grn}"
SHD_UNDERLINECHAR="${SHD_UNDERLINECHAR:--}"
SHD_UNDERLINECHAREXT="${SHD_UNDERLINECHAREXT:-${SHD_UNDERLINECHAR}}"
SHD_UNDERLINECOLOR="${SHD_UNDERLINECOLOR:-SHD_ylw}"
SHD_COLUMNSEP="${SHD_COLUMNSEP:-|}"
SHD_COLUMNCOLOR="${SHD_COLUMNCOLOR:-SHD_wht}"
SHD_TSFORMAT="${SHD_TSFORMAT:-%d-%m %H:%M:%S}"

## Do not modify
SHD_OLIST=0

## Shell specific tuning
case "$(basename "${SHELL}")" in
  bash) alias echo='echo -e';;
esac

case "${SHD_SWIDTH}" in
  auto*) min="$(echo "${SHD_SWIDTH}" | sed -n 's/auto \([0-9]\+\).*/\1/p')"
         [ "${min}" -gt 0 ] 2>/dev/null || min=20
         max="$(echo "${SHD_SWIDTH}" | sed -n 's/auto [0-9]\+ \([0-9]\+\)/\1/p')"
         [ "${max}" -gt 0 ] 2>/dev/null || max=160
         SHD_SWIDTH="$(stty size | sed -n 's/^[0-9]\+ //p')"
         if [ ${SHD_SWIDTH} -lt ${min} ] 2>/dev/null; then SHD_SWIDTH="${min}"
         else
           if [ ${SHD_SWIDTH} -gt ${max} ]; then SHD_SWIDTH="${max}"
           else [ ${SHD_SWIDTH} -ge 0 ] 2>/dev/null || SHD_SWIDTH="${max}"; fi
         fi;;
  real*) fb="$(echo "${SHD_SWIDTH}" | sed -n 's/^real //')"
         SHD_SWIDTH="$(stty size | sed -n 's/^[0-9]\+ //p')"
         if ! [ ${SHD_SWIDTH} -gt 0 ] 2>/dev/null; then
           [ ${fb} -gt 0 ] 2>/dev/null && SHD_SWIDTH="${fb}" || SHD_SWIDTH="80"
         fi;;
  *)     [ ${SHD_SWIDTH} -gt 0 ] 2>/dev/null || SHD_SWIDTH=80;;
esac

shd_eval SHD_BORDERCOLOR
shd_eval SHD_LISTCOLOR
shd_eval SHD_UNDERLINECOLOR
shd_eval SHD_COLUMNCOLOR


## Load modules
for f in "${SHD_WORKDIR}/modules/"*.sh; do
  [ -r "${f}" ] || continue
  . "${f}"
  shd_dbg "loaded module '${f}'"
done

#### TODO ####
shd_select() { return; }
shd_select_file() { return; }

# If script was not sourced, display help :)
if [ "$(basename -- "${0}" .sh)" = "${SCRIPTNAME}" ]; then
  exec >&2
  printf "\n"
  printf "${SHD_grn}${SCRIPTNAME}${SHD_nrm} : this script is not meant to be used by its own...\n"
  printf "  Source this code in your shell scripts and use following modules functions.\n"
  printf "  To get help about functions usage, use 'shd_function -h'.\n"
  printf "  To get examples on functions, use 'shd_funciton -X'.\n"
  printf "\n"
  shd_modules_funcs
  printf "\n"
  exit 0
fi
