#!/bin/sh
PROGNAME="shdialog"
PREFIX="${PREFIX:-/usr}"
CONFDIR="${CONFDIR:-/etc}"
SHAREDIR="${PREFIX}/share/${PROGNAME}"
BINDIR="${PREFIX}/bin"


[ "$(id -un)" = "root" ] || { printf "Error : this script should be run as root\n" >&2; exit 1; }


[ -d "${SHAREDIR}" ] || install -v -d -m755 -oroot -groot "${SHAREDIR}"
for f in LICENSE README.md; do install -v -m 644 -oroot -groot "${f}" "${SHAREDIR}/${f}"; done

[ -d "${SHAREDIR}/modules" ] || install -v -d -m755 -oroot -groot "${SHAREDIR}/modules"
for m in modules/*; do install -v -m644 -oroot -groot "${m}" "${SHAREDIR}/${m}"; done

[ -d "${SHAREDIR}/examples" ] || install -v -d -m755 -oroot -groot "${SHAREDIR}/examples"
for e in examples/*; do install -v -m755 -oroot -groot "${e}" "${SHAREDIR}/${e}"; done

install -v -m644 -oroot -groot ${PROGNAME}.conf.example ${CONFDIR}/${PROGNAME}.conf.example
[ -e "${CONFDIR}/${PROGNAME}.conf" ] || install -v -m 644 -oroot -groot ${PROGNAME}.conf.example ${CONFDIR}/${PROGNAME}.conf

install -v -m755 -oroot -groot ${PROGNAME}.sh /usr/bin/${PROGNAME}
