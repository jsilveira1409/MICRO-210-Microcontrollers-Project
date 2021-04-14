; file	timer0_prescaler.asm   target ATmega128L-4MHz-STK300	
; purpose timer 0 overflow
; module: M3, output port: PORTE
.include "macros.asm"			; include macro definitions
.include "definitions.asm"

; === interrupt vector table ===
.org	0
	rjmp	reset			; reset
		
.org	OVF0addr			; timer0 overflow interrupt
	rjmp	ovf0

; === interrupt service routines ====
.org	0x30
ovf0:	INVP	PORTE,SPEAKER	; make a sound
	INVP	PORTD,7		; oscilloscope probe
	reti

.include "lcd.asm"
.include "printf.asm"
	
; === reset ===	
reset: 
	LDSP	RAMEND		; load stack pointer (SP)
	OUTI	DDRB,0xff		; LEDs = output	
	sbi	DDRE,SPEAKER	; speaker = output
	sbi	DDRD,7		; oscilloscope probe = output
	rcall	LCD_init		; initialize LCD
	
	OUTI	TIMSK,1<<TOIE0	; Timer0 Overflow Interrupt Enable
	sei				; set global interrupt

; === main program ===
main:
	in	r20,PIND		; read buttons
	out	PORTB,r20		; write LEDs
	com	r20			; invert register
	out	TCCR0,r20		; write Timer Control Reg
		
	rcall	LCD_clear		; clear LCD
	PRINTF	LCD		; display formatted string
.db	"TCCR0=",FBIN,TCCR0+0x20,0

	WAIT_MS	100
	rjmp	main
