/*
 * inc_lim.asm
 *
 *  Created: 05/03/2021 05:01:05
 *   Author: Joaquim Silveira
 */ 
.include	"macros.asm"
.include	"definitions.asm"

reset:
		LDSP	RAMEND
		OUTI	DDRB,$ff
loop:
		WAIT_MS	100
		JP0		PIND, 0, button0
		JP0		PIND, 1, button1
		rjmp	loop
button0:
		INC_LIM	a0,10
		inc		a0
		mov		w,a0
		com		w
		out		LED,w
		rjmp	loop
button1:
		INC_LIM	a0,3
		dec		a0
		mov		w,a0
		com		w
		out		LED,w
		rjmp	loop
