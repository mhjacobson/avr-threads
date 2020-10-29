#!/bin/sh

set -e
set -x

SDKROOT=~/avr/
HEADER_SEARCH_PATHS="-I ${SDKROOT}/sdk/avr/include"
# MCU="atmega328p"
MCU="atmega644p"
PRODUCT_NAME="threads.a"
CFLAGS="-Os"

CC="${SDKROOT}/sdk/bin/avr-gcc"
AR="${SDKROOT}/sdk/bin/avr-ar"

rm -f "${PRODUCT_NAME}"

for f in threads.c threads.s; do
	"${CC}" -c -mmcu="${MCU}" ${CFLAGS} ${HEADER_SEARCH_PATHS} "${f}"
done

"${AR}" -cq "${PRODUCT_NAME}" *.o
