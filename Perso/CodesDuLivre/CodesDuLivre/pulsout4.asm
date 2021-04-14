; file	pulsout4.asm   target ATmega128L-4MHz-STK300
; purpose generation of rectangular signal using timer2
; module: M2, output port: PORTE
.include "macros.asm"		; include macro definitions
.include "definitions.asm"

; === interrupt vector table ===
	rjmp	reset
.org	OC2addr
	rjmp	oc2
	
; === interrupt routines ===
oc2:	INVP	PORTE,SPEAKER	; make a sound
	reti
	
; === initialization ===
reset:
	LDSP	RAMEND		; load the stack pointer
	OUTI	DDRB,0xff	; make portB all output
	sbi	DDRE,SPEAKER	; make speaker an output
	OUTI	TCCR2,0b00011001 ; CS2=001 (CK), COM=01 (toggle) CTC=1 (clear)
	rcall	LCD_init

	ldi	b0,10		; preset OCR2
	ldi	a1,4		; preset TCCR2	
	
	OUTI	TIMSK,1<<OCIE2
	sei		
	jmp	main
.include "lcd.asm"
.include "printf.asm"

main:	in	r0, PIND	; copy buttons to LED
	out	PORTB,r0

	out	OCR2,b0		; set output compare register
	
	in	w,TCCR2
	andi	w,0b11111000
	add	w,a1
	out	TCCR2,w

	rcall	LCD_clear	; set cursor to home position
	PRINTF	LCD
.db	"CS2=",FHEX,a+1," OCR2=",FHEX,b,0	
	WAIT_MS	100		; wait 100msec

loop:	JP0	PIND,0,incremb ; jump if pin=0, check the buttons
	JP0	PIND,1,decremb
	JP0	PIND,2,increma
	JP0	PIND,3,decrema
	rjmp	loop		; jump back
incremb:
	INC_CYC	b0,10,250
	rjmp	main
decremb:
	DEC_CYC	b0,10,250
	rjmp	main
increma:
	INC_CYC	a1,2,5
	rjmp	main
decrema:
	DEC_CYC	a1,2,5
	rjmp	main
