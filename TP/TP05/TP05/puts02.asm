; file	puts02.asm   target ATmega128L-4MHz-STK300	
; purose display an ASCII string
.include "macros.asm"
.include "definitions.asm"

reset:
	LDSP	RAMEND
	rcall	LCD_init
	rjmp	main
.include "lcd.asm"

main:	
	ldi	r16,str0
	ldi	zl, low(2*str0)	; load pointer to string
	ldi	zh, high
	rcall	LCD_putstring	; display string
	rjmp	PC		; infinite loop

LCD_putstring:
; in	z 
	 			; load program memory into r0
	tst	 		; test for end of string
	breq	 
	mov	 	; load argument
	rcall	LCD_putc
	adiw	 		; increase pointer address
	rjmp	 		; restart until end of string
done:	ret

.org 200
str0:
.db	"hello world 1",0
.org str0/2
.db	"hello world 2",0
.org str0*2
.db	"hello world 3",0