; file	speaker1b.asm   target ATmega128L-4MHz-STK300
; purpose fixed frequency sound through piezo
; module: M2, output port: PORTE
.include "macros.asm"
.include "definitions.asm"

reset:
	LDSP	RAMEND				; load stack pointer SP
	OUTI	DDRB,$ff				; make LEDs output
	sbi	DDRE,SPEAKER				; make pin SPEAKER an output

main:
	sbic	PIND, 0		; insert additional instruction here
	rjmp    PC-1     	; insert additional instruction here
						; insert additional instruction here
	sbi	PORTE,SPEAKER
	WAIT_US	1136				; same as in speaker1.asm

	cbi	PORTE,SPEAKER
	WAIT_US	1136				; same as in speaker1.asm
	rjmp	main
