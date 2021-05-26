/*
 * threads.c
 * threading library for ATmega644p
 * author: Matt Jacobson
 */

#include "threads.h"
#include <stdbool.h>
#include <stdint.h>
#include <avr/interrupt.h>
#include <avr/io.h>

struct avr_state {
	uint8_t  r2,  r3,  r4,  r5,  r6,  r7,  r8,  r9, 
	        r10, r11, r12, r13, r14, r15, r16, r17, 
	         yl, yh;
	uint8_t pcl;
	uint8_t pch;
	uint8_t spl;
	uint8_t sph;
	uint8_t sreg;
};

extern uint8_t thread_get_sreg(void);
extern void thread_swap(struct avr_state *old, const struct avr_state *new);

struct thread {
	struct avr_state saved_state;
};

#define STACK_SIZE 0x100
#define MAX_THREADS 4
static struct thread threads[MAX_THREADS];
static thread_t current_thread;
static uint8_t next_thread_index;
 
void thread_init(void) {
	current_thread = &threads[0];
	next_thread_index = 1;
}

thread_t thread_create(void (*start)(void)) {
	thread_t thread = NULL;
	
	const bool interrupts_enabled = (SREG & (1 << SREG_I));
	cli();
	
	if (next_thread_index < MAX_THREADS) {
		const uint8_t thread_index = next_thread_index++;
		thread = &threads[thread_index];
		
		thread->saved_state.pcl = (uint16_t)start & 0xff;
		thread->saved_state.pch = (uint16_t)start >> 8;
		
		// Make sure the new thread starts with interrupts enabled.
		thread->saved_state.sreg = thread_get_sreg() | (1 << SREG_I);
	
		const uint16_t sp = RAMEND - STACK_SIZE * thread_index;
		thread->saved_state.spl = sp & 0xff;
		thread->saved_state.sph = sp >> 8;
	}
	
	if (interrupts_enabled) {
		sei();
	}
	
	return thread;
}

void thread_switch(void) {
	// Disable interrupts, because:
	//   1. we're accessing global state (threads and next_thread_index)
	//   2. changing current_thread and swapping must happen atomically
	const bool interrupts_enabled = (SREG & (1 << SREG_I));
	cli();
	
	const uint8_t current_index = current_thread - &threads[0];
	const uint8_t next_index = (current_index == next_thread_index - 1) ? 0 : current_index + 1;
	
	const thread_t old_thread = current_thread;
	const thread_t new_thread = &threads[next_index];
	
	current_thread = new_thread;
	thread_swap(&old_thread->saved_state, &new_thread->saved_state);
	
	if (interrupts_enabled) {
		sei();
	}
}