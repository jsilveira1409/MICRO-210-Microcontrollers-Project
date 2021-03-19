; file	01.asm   target ATmega128L-4MHz-STK300
; purpose delay loop

reset:
	ldi	r16,0xFF
	out	DDRB,r16	; portB = output
loop:
	dec	r16			; increment low-byte counter
	nop
	nop
	nop				; adjust to 1.5us loop time
	brne loop		; loop back
	dec	r17			; increment high-byte counter
	brne loop		; loop back
	dec	r18			; increment LED counter
	out	PORTB,r18	; ouput register to portB
	rjmp loop