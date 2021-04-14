; file	int0b.asm   target ATmega128L-4MHz-STK300	
; purpose simulation of external interrupts

.include "macros.asm"	; include macros definitions
.include "definitions.asm"	; include register definitions

; === interrupt table ===
	jmp	reset
	jmp	int_0	; PIND0..3
	jmp	int_1
	jmp	int_2
	jmp	int_3
	jmp	int_4	; PINE4..7
	jmp	int_5
	jmp	int_6
	jmp	int_7

; === interrupt service routines	
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

; === initialization (reset) ====
reset:	LDSP	RAMEND	; load SP
	OUTI	EIMSK,0b00111111 ; INT0..5
	OUTEI	EICRA, 0b00000000 ; INT3..0; 00=low, 10=fall, 11=rise
	OUTI	EICRB, 0b00001110 ; INT7..4
	sei	; set global interrupt

; === main program ===
main:	inc	r16
	nop
	rjmp	main