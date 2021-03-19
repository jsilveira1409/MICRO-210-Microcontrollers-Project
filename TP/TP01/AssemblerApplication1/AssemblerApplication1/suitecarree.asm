/*
 * suitecarree.asm
 *
 *  Created: 24/02/2021 02:47:12
 *   Author: Joaquim Silveira
 */ 
reset:
	clr		r0
	inc		r0
	mov		r1,r0
loop:
	inc		r1
	inc		r1
	add		r0,r1
	rjmp	loop