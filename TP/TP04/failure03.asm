; file	   failure03.asm   target ATmega128L-4MHz-STK300
; purpose study incorrect code operation
.include "macros.asm"
.include "definitions.asm"

reset: 
	LDSP	RAMEND		;set up stack pointer (SP)
	
	ldi	r16, 0x11
	ldi	r17, 0xaa
	ldi	r18, 0x55
	
main:
	push	r16

	rcall distract
	
	pop	r16
	
;============================================
; this stands for a big subroutine, where a
; programmer may have lost control
distract:
	;several instructions ...
	push	r17
	push	r18
	
	;several instructions ...
	pop	r18

	;several instructions ...
	ret