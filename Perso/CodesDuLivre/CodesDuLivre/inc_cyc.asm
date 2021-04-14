/*
 * inc_cyc.asm
 *
 *  Created: 05/03/2021 05:19:40
 *   Author: Joaquim Silveira
 */ 
.include	"macros.asm"
.include	"definitions.asm"

reset:
		LDSP	RAMEND
		OUTI	DDRB, $ff
loop:
		WAIT_MS	100
		JP0		PIND, 0, button0
		;JP0		PIND, 1, button1
		rjmp	loop
button0:
		INC_CYC	a0,3,10
		mov		w, a0
		com		w
		out		LED,w
		rjmp	loop
button1:
		DEC_CYC	a0,3,10w4 3e
		mov		w,a0
		com		w
		out		LED,w
		rjmp	loop