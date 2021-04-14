.include "macros.asm"
.include "definitions.asm"

reset:
		LDSP	RAMEND
		OUTI	DDRB,$ff

main:
		WP0		PINE,IR
		WP1		PINE, IR
		inc		r16
		out		PORTB, r16
		rjmp	main