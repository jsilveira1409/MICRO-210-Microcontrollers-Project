; file	int1b.asm   target ATmega128L-4MHz-STK300		
; purpose oscillosope measurements while externally interrupting
.include "macros.asm"		; include macros definitions
.include "definitions.asm"	; include register definitions

; === interrupt table ===
.org	0
	jmp	reset
	
.org	INT3addr
	jmp	ext_int3

; === interrupt service routines	
ext_int3:
	sbi	PORTA,5		; pulse on PINA5 
	nop
	cbi	PORTA,5
	reti

; === initialization (reset) ====
reset:
	LDSP	RAMEND		; load stack pointer SP
	OUTI	DDRA, 0b00100010 ; PA1,PA5 = output
	OUTI	EIMSK,0b00001000 ; enable INT3	; 
	sei			; set global interrupt

; === main program ===
main:
	sbi	PORTA,1		; pulse on PINA1
	nop
	cbi	PORTA,1
	rjmp	main