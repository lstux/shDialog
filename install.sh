#!/bin/sh

WORKDIR="/usr/share/shdialog"

[ -d "${WORKDIR}" ] || install -v -d -m755 -oroot -groot "${WORKDIR}"
for f in LICENSE README.md; do install -v -m 644 -oroot -groot "${f}" "${WORKDIR}/${f}"; done

[ -d "${WORKDIR}/modules" ] || install -v -d -m755 -oroot -groot "${WORKDIR}/modules"
for m in modules/*; do install -v -m644 -oroot -groot "${m}" "${WORKDIR}/modules/${m}"; done

[ -d "${WORKDIR}/examples" ] || install -v -d -m755 -oroot -groot "${WORKDIR}/examples"
for e in examples/*; do install -v -m755 -oroot -groot "${e}" "${WORKDIR}/examples/${e}"; done

install -v -m644 -oroot -groot shdialog.conf.example /etc/shdialog.conf.example
[ -e "/etc/shdialog.conf" ] || install -v -m 644 -oroot -groot shdialog.conf.example /etc/shdialog.conf

install -v -m755 -oroot -groot shdialog.sh /usr/bin/shdialog
