/*
 * threads_asm.s
 * threading library for ATmega644p
 * author: Matt Jacobson
 */

; extern uint8_t thread_get_sreg(void);
.globl thread_get_sreg
thread_get_sreg:
 	; sreg == 0x3f
	in r24, 0x3f
	ret

; extern uint16_t thread_get_pc(void);
.globl thread_get_pc
thread_get_pc:
	; pop the RA off the stack.  note that the high byte is popped first
	pop r25 ; pch
	pop r24 ; pcl
	
	; push it back
	push r24
	push r25
	
	ret

; extern uint16_t thread_get_sp(void);
.global thread_get_sp
thread_get_sp:
	; spl == 0x3d
	; sph == 0x3e
	in r24, 0x3d
	in r25, 0x3e
	ret

; extern void thread_swap(struct avr_state *old, const struct avr_state *new);
.globl thread_swap
thread_swap:
	; r25:r24 <- old
	; r23:r22 <- new
	
	; We must be called with interrupts disabled.  An interrupt while we're halfway 
	; through restoring context could call thread_switch(), which would be ruinous.
	; Also, the thread_switch() that called us wants interrupts disabled anyway, 
	; because it wants to update current_thread atomically with this swap.
	
	; Caller-saved state has already been saved by the caller (usually on the stack).
	; We need to save callee-saved state: r2–r17 and Y (r29:r28).
	; We also need to save the status register, program counter, and stack pointer.
	; We use as scratch space: r24, r25, X (r27:r26), and Z (r31:r30).
	
	; X (r27:r26) <- old (r25:r24)
	mov r26, r24
	mov r27, r25
	
	; save general registers r2–r17 and Y (r29:r28)
	st X+, r2
	st X+, r3
	st X+, r4
	st X+, r5
	st X+, r6
	st X+, r7
	st X+, r8
	st X+, r9
	st X+, r10
	st X+, r11
	st X+, r12
	st X+, r13
	st X+, r14
	st X+, r15
	st X+, r16
	st X+, r17
	st X+, r28 ; yl
	st X+, r29 ; yh
	
	; pop the RA off the stack.  note that the high byte is popped first.
	pop r24 ; pch
	pop r25 ; pcl
	
	; save the RA
	st X+, r25 ; pcl
	st X+, r24 ; pch
	
	; save the (post-pop) stack pointer
	; spl == 0x3d
	; sph == 0x3e
	in r24, 0x3d
	st X+, r24
	in r24, 0x3e
	st X+, r24
	
	; save the status register
	; sreg == 0x3f
	in r24, 0x3f
	st X+, r24
	
	; ---------
	
	; X (r27:r26) <- new (r23:r22)
	mov r26, r22
	mov r27, r23
	
	; restore general registers r2–r17 and Y (r29:r28)
	ld r2, X+
	ld r3, X+
	ld r4, X+
	ld r5, X+
	ld r6, X+
	ld r7, X+
	ld r8, X+
	ld r9, X+
	ld r10, X+
	ld r11, X+
	ld r12, X+
	ld r13, X+
	ld r14, X+
	ld r15, X+
	ld r16, X+
	ld r17, X+
	ld r28, X+ ; yl
	ld r29, X+ ; yh
	
	; Z (r31:r30) <- stored PC
	ld r30, X+ ; pcl
	ld r31, X+ ; pch
	
	; restore the stack pointer
	; spl == 0x3d
	; sph == 0x3e
	ld r24, X+
	out 0x3d, r24
	ld r24, X+
	out 0x3e, r24
	
	; restore the status register
	; sreg == 0x3f
	ld r24, X+
	out 0x3f, r24
	
	; NOTE: at this point, interrupts may be re-enabled, based on the status register
	; of the restored thread.  That's fine, since all callee-saved state is restored.
	; If an interrupt were to happen now and call thread_switch(), it would simply 
	; save the restored thread at a point just before jumping back into action.
	
	; jump to Z (r31:r30)
	ijmp
