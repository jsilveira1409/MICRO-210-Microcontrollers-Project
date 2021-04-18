; file	putb02.asm   target ATmega128L-4MHz-STK300			
; purpose display a binary value
.include "macros.asm"		; include macro definitions
.include "definitions.asm"

reset:
	LDSP	RAMEND		; load stack pointer
	OUTI	DDRB,0xff		; make portB output
	rcall	LCD_init		; initialize LCD
	rjmp	main
.include "lcd.asm"

main:	rcall	LCD_clear		; place cursor to home position
	in	a0,PIND		; read switches
	out	PORTB,a0		; write to LED
	com	a0		; invert a0
	rcall	LCD_putb		; display in binary on LCD
	WAIT_MS	100
	rjmp	main

LCD_putb:
; in	a0
	mov	a1, 		; move argument to different register
	ldi	  ,8		; load counter
loop:	ldi	a0,		; load '0'
	lsl	 		; shift bit into carry
	brcc	
	ldi	 		; load '1'
	     	LCD_putc	; put character to LCD
	dec	 	; decrement counter
	brne	loop
