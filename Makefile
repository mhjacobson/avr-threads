CFLAGS=-ffunction-sections -fdata-sections -Os -mmcu="${MCU}" --sysroot=/opt/local/avr/include/

CC=avr-gcc
AR=avr-ar
MCU=atmega644p

.PHONY: all clean

all: build/threads.a

clean:
	rm -r build

build:
	mkdir build

build/%.o: %.c | build
	${CC} -c -o "$@" ${CFLAGS} $<

build/%.o: %.s | build
	${CC} -c -o "$@" ${CFLAGS} $<

build/threads.a: build/threads.o build/threads_asm.o | build
	${AR} -cq $@ $^