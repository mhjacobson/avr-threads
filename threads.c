/*
 * threads.c
 * threading library for ATmega644p
 * author: Matt Jacobson
 */

#include "threads.h"
#include <stdint.h>
#include <avr/io.h>

struct avr_state {
	uint8_t  r2,  r3,  r4,  r5,  r6,  r7,  r8,  r9, 
	        r10, r11, r12, r13, r14, r15, r16, r17, 
	        r28, r29, yl, yh;
	uint8_t sreg;
	uint8_t pcl;
	uint8_t pch;
	uint8_t spl;
	uint8_t sph;
};

extern void thread_get_sreg(void);
extern void thread_swap(struct avr_state *old, const struct avr_state *new);

struct thread {
	struct avr_state saved_state;
};

#define MAX_THREADS 32
struct thread threads[MAX_THREADS];
thread_t current_thread;
uint8_t nthread;
 
void threads_init(void) {
	nthread = 1;
	current_thread = &threads[0];
}

thread_t thread_create(void (*start)(void)) {
	const thread_t thread = &threads[nthread++];
	thread->saved_state.pcl = (uint16_t)start & 0xff;
	thread->saved_state.pch = (uint16_t)start >> 8;
	thread->saved_state.sreg = get_sreg();
	
	uint16_t sp = RAMEND / 2; // TODO: advance for each thread
	thread->saved_state.spl = sp & 0xff;
	thread->saved_state.sph = sp >> 8;
	
	return thread;
}

void thread_switch(void) {
	const uint8_t current_index = current_thread - &threads[0];
	const uint8_t next_index = (current_index == nthread - 1) ? 0 : current_index + 1;
	
	const thread_t old_thread = current_thread;
	const thread_t new_thread = &threads[next_index];
	
	current_thread = new_thread;
	thread_swap(&old_thread->saved_state, &new_thread->saved_state);
}