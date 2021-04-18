; file	putx02.asm   target ATmega128L-4MHz-STK300			
; purpose display a hex value
.include "macros.asm"			; include macro definitions
.include "definitions.asm"

reset:
	LDSP	RAMEND			; load stack pointer
	OUTI	DDRB,0xff		; make portB output
	rcall	LCD_init		; initialize LCD
	rjmp	main
.include "lcd.asm"

main:	rcall	LCD_home		; place cursor to home position
	in	a0,PIND			; read switches
	out	PORTB,a0		; write to LED
	com	a0			; invert a0
	rcall	LCD_putx		; display in hex on LCD
	WAIT_MS	100
	rjmp	main

hextb:
.db	"0123456789abcdef"

LCD_putx:
; in	a0
	push	a0		; save
	swap	 		; display high nibble first
	andi	a0, 		; mask higher nibble
	mov	 		; load low byte of z
	clr	 	; clear high byte of z
	subi	zl, low 	; add offset to table base
	sbci	 
	  			; look up ASCII code
	mov	a0,r0
	    	LCD_putc	; put character to LCD
	pop	 
	andi	 
	mov	 		; load offset in low byte
	clr	 		; clear high byte
	subi	 		; add offset to table base
	sbci	 
	 			; look up ASCII code
	mov	a0,r0
				; put character to LCD
	ret
