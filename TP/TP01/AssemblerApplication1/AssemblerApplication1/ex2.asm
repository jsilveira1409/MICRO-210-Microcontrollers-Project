/*
 * ex2.asm
 *
 *  Created: 21/02/2021 04:59:29
 *   Author: Joaquim Silveira
 */ 
	ldi		r16, 0x05
	nop
	nop
reset:
	dec		r16
	add		r0, r16
	jmp		reset
