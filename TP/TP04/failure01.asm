; file	   failure01.asm   target ATmega128L-4MHz-STK300
; purpose study incorrect code operation
.include "macros.asm"
.include "definitions.asm"

reset: 
	LDSP	RAMEND		;set up stack pointer (SP)
	
	ldi	r16, 0x11
	ldi	r17, 0xaa
	
main:
	ldi	xl, 0xff
	ldi	xh, 0x10
	
	push	r16
	
	st	x, r17
	
	pop	r16