#!/bin/sh
EXDIR="$(dirname "$(realpath "${0}")")"
WORKDIR="$(realpath "${EXDIR}/..")"
source "${WORKDIR}/shdialog.sh"

shd_test "shd_lorem long | shd_blines 24"
shd_test "shd_lorem long | shd_blines 60 | shd_center"
shd_test "shd_lorem | shd_blines 16 | shd_center 30"

shd_test "shd_items 3 | shd_list"
shd_test "shd_items 3 | shd_olist"
shd_test "shd_olist 'another item'; shd_olist 'and another one'; shd_olist 'and a last one'"
shd_test "SHD_OLIST=3; shd_items 3 | shd_olist"

shd_test "shd_underline 'some very interesting text'"
shd_test "shd_boxed 'some text in a box'"
shd_test "shd_lorem long | shd_blines 80 | shd_boxed"

shd_test "shd_timestamp \"a timestamped line \${SHD_ylw}:)\${SHD_nrm}\""
shd_test "shd_lorem long | shd_rainbow | shd_blines 80"

shd_test "echo -e \"uid1;Name 1;Ref 1\\\nuid2;Name 2;Ref 2\" | shd_table 'My Table' 'UID;Name;Reference'"
