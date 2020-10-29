/*
 * threads.c
 * threading library for ATmega644p
 * author: Matt Jacobson
 */
 
 ; extern uint8_t get_sreg(void);
 _thread_get_sreg:
  	; sreg == 0x3f
 	in r24, 0x3f
 	ret
 
 ; extern void thread_swap(struct avr_state *old, const struct avr_state *new);
 _thread_swap:
 	; old <- r25:r24
 	; new <- r23:r22
 	; need to save: r2–r17 and Y (r29:r28)
 	
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
 	
	; save the status register
 	; sreg == 0x3f
 	in r24, 0x3f
 	st X+, r24
 	
 	; pop the RA off the stack
 	pop r24 ; pcl
 	pop r25 ; pch

	; save the RA
 	st X+, r24 ; pcl
 	st X+, r25 ; pch
 	
 	; save the (post-pop) stack pointer
 	; spl == 0x3d
 	; sph == 0x3e
 	in r24, 0x3d
 	st X+, r24
 	in r24, 0x3e
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
 	
 	; restore the status register
 	; sreg == 0x3f
 	ld r24, X+
 	out 0x3f, r24
 	
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
 	
 	; jump to Z (r31:r30)
 	ijmp
