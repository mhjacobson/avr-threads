/*
 * threads.h
 * threading library for ATmega644p
 * author: Matt Jacobson
 */

#include <stddef.h>

typedef struct thread *thread_t;

void threads_init(void);
thread_t thread_create(void (*start)(void));
void thread_switch(void);