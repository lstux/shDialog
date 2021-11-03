#!/bin/sh
EXDIR="$(dirname "$(realpath "${0}")")"
WORKDIR="$(realpath "${EXDIR}/..")"
source "${WORKDIR}/shdialog.sh"

shd_test "shd_ask \"is it yes or no?\" && echo \"let's go then...\" || echo \"let's stay here then...\""
shd_test "shd_ask \"is it yes or no?\" y && echo \"let's go then...\" || echo \"let's stay here then...\""
exit $?

WORKDIR="$(dirname "$(realpath "${0}")")"
source "${WORKDIR}/../shdialog.sh"
shd_infos

echo "\nshd_ask \"is it yes or no?\" && echo \"let's go then...\" || echo \"let's stay here then...\""
shd_ask "is it yes or no?" && echo "let's go then..." || echo "let's stay here then..."
echo "\nshd_ask \"is it yesor no ?\" y && echo \"let's go then...\" || echo \"let's stay here then...\""
shd_ask "is it yes or no?" y && echo "let's go then..." || echo "let's stay here then..."
