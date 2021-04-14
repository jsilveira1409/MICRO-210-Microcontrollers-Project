/*
 * fibonacci.asm
 *
 *  Created: 24/02/2021 03:34:57
 *   Author: Joaquim Silveira
 */ 
 reset:
	clr		r0
	clr		r1
	inc		r1
	clr		r2
loop :
	mov		r2,r0
	add		r2,r1
	mov		r0,r1
	mov		r1,r2 ;comme
	rjmp	loop