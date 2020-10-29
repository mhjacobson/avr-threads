/*
 * threads.h
 * threading library for ATmega644p
 * author: Matt Jacobson
 */

#include <stddef.h>

#ifndef THREADS_H
#define THREADS_H

typedef struct thread *thread_t;

void thread_init(void);
thread_t thread_create(void (*start)(void));
void thread_switch(void);

#endif /* THREADS_H */