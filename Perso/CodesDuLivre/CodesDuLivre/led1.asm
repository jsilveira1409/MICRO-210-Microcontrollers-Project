/*
 * led1.asm
 *
 *  Created: 05/03/2021 04:13:30
 *   Author: Joaquim Silveira
 */ 
.include "macros.asm"
.include "definitions.asm"

reset:		
		OUTI	DDRB, 0xff
main:
		inc		a1
		brne	main
		
		inc		a2
		brne	main
		
		inc		a0
		out		PORTB, a0
		rjmp	main
