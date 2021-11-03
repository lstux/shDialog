#!/bin/sh
EXDIR="$(dirname "$(realpath "${0}")")"
WORKDIR="$(realpath "${EXDIR}/..")"
source "${WORKDIR}/shdialog.sh"

shd_test "shd_lorem long | shd_columns 2 40"
shd_test "shd_lorem long 3 | shd_columns 2 100"
shd_test "shd_lorem long 5 | shd_columns 3"
