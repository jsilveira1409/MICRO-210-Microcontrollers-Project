; file	pulsout1b.asm   target ATmega128L-4MHz-STK300
; purpose port switching for training oscilloscope operation
; module: none, output port: PORTE
$
reset:	
	ldi	r16,0xff	; load immediate value into register
	out	DDRE,r16	; output register to i/o Data Direction	
main:
	sbi	PORTE,7		; set bit 7 in i/o port E
	cbi	PORTE,7		; clear bit 7 in i/o port E
	nop				; No OPeration (do nothing)
	push	r0
	pop		r0
	rjmp	main		; jump back to main