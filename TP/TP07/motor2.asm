; file	motor2.asm   target ATmega128L-4MHz-STK300
; purpose stepper motor control using timer2 interrupt and LUT
; module: M1, output port: PORTA
.include "macros.asm"
.include "definitions.asm"

.equ	port_mot = PORTA

; === interrupt table ===
.org	0
	jmp	reset
		
.org	OVF2addr			; timer overflow 2 interrupt vector
	rjmp	ovf2
	
; === interrupt routines ===
ovf2:
	JP0	PIND,0,reverse		; forward/reverse ?
							; r0 <- lookup(z)
							; output pattern to stepping motor
	out	PORTC, r0			; to connect oscilloscope probe
							; increment table pointer
	cpi	zl,
	br	PC+2				; are we at end of table?
	ldi	zl,					; reset to begin of table
	reti
reverse:
	lpm						; r0 <- lookup(z)
	out	port_mot, r0		; output pattern to stepping motor
	out	PORTC, r0			; to connect oscilloscope probe
	dec	zl					; decrement table pointer
	cpi	zl,2*tbl_mot
	brsh	PC+2			; are we at begin of table?
	ldi	zl,2*tbl_mot+5		; reset to end of table
	reti

; === lookup table ===
tbl_mot:
.db	0b0101, 0b0001, 

; === initialization ===
reset:	LDSP	RAMEND		; initialize stack pointer SP
	OUTI	DDRA, 0x0f		; make motor lines output
	OUTI	DDRB, 0xff		; make portB (LEDs) output

	clr	zh					; Z high-byte is always zero
	ldi	zl,					; point to table entry

	OUTI		,3			; CS2=3 CK/64
	OUTI		,(1<<TOIE2); timer 2 overflow enable
	sei						; set global interrupt

; === main program === 
main:	in	a0, PIND
	out	PORTB, a0
	rjmp	main

