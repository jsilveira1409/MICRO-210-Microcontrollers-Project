.include "macros.asm"
.include "definitions.asm"

.org 0
		jmp		reset
.org INT5
		jmp		ext_int5

ext_int5:
	cbi		PORTB, 5
	reti

reset:
	LDSP	RAMEND
	OUTI	DDRB,0xFF
	OUTI	EIMSK,0b00001111
	sei

main:
	WAIT_US	10000
	dec		r18
	out		PORTB,r18
	rjmp	main
	