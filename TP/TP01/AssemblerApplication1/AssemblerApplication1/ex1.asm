/*
 * AsmFile1.asm
 *
 *  Created: 21/02/2021 03:10:14
 *   Author: Joaquim Silveira
 */ 
	ldi		r16, 0x03
reset:
	inc		r16
	add		r0, r16
	rjmp	reset