; file	   failure02.asm   target ATmega128L-4MHz-STK300
; purpose study incorrect code operation
.include "macros.asm"
.include "definitions.asm"

;============================================
; this stands for a big macro, over which a
; programer may have lost control
.macro 	DISTRACT	  ;void
	;several instructions ...
	push	r18
	push	r17
	
	;several instructions ...
	pop	r17
	
	;several instructions ...
.endmacro

reset: 
	LDSP	RAMEND		;set up stack pointer (SP)
	
	ldi	r16, 0x11
	ldi	r17, 0xaa
	ldi	r18, 0x55
	
main:
	push	r16

	DISTRACT
	
	pop	r16