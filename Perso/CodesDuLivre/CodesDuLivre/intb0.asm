.include "macros.asm"
.include "definitions.asm"


jmp		reset
jmp		int_0		
jmp		int_1
jmp		int_2
jmp		int_3
jmp		int_4
jmp		int_5
jmp		int_6
jmp		int_7

int_0:	inc	r0
		reti
int_1:	reti
int_2:	reti
int_3:	reti
int_4:	inc	r1
		reti
int_5:	reti
int_6:	reti
int_7:	reti


reset:
		LDSP	RAMEND
		OUTI	EIMSK, 0b00111111
//		OUTI	EICRA, 0b00001110
		OUTI	EICRB, 0b00001110
		sei
main:	
		inc	r16
		nop
		rjmp main
