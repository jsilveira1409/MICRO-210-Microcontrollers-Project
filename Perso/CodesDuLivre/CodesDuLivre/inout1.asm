/*
 * inout1.asm
 *
 *  Created: 05/03/2021 03:53:18
 *   Author: Joaquim Silveira
 */ 
 reset:	
		ldi		r16, 0x00
		out		DDRB, r16
		ldi		r16, 0xf0
		out		DDRD, r16
loop:
		in		r16, PIND
		out		PORTB, r16
		rjmp	loop
