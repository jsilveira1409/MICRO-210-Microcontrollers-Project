/*
 * inout2.asm
 *
 *  Created: 05/03/2021 04:05:45
 *   Author: Joaquim Silveira
 */ 
reset:
		ldi		r16, 0xff
		out		DDRB, r16
		ldi		r16, 0x00
		out		DDRD, r16
		clr		r16
loop:
		sbic	PIND, 0
		rjmp	PC-1
		;sbis	PIND, 2
		;rjmp	PC-1

		dec		r16
		out		PORTB, r16
		rjmp	loop