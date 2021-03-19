.include	"macros.asm"
.include	"definitions.asm"

reset:
	LDSP	RAMEND
	rcall	LCD_init
	rjmp	main
.include "lcd.asm"
.include "printf.asm"

.equ	T1 = 1778

main:	CLR2	b1,b0
		ldi	b2,14
		WP1		PINE,IR
		WAIT_US	(3*T1/4)

loop:	P2C		PINE,IR
		ROL2	b1,b0
		WAIT_US	(T1-4)
		DJNZ	b2,loop
		com		b0
		rcall	LCD_home
		PRINTF	LCD
.db		"cmd=",FHEX,b,0
		rjmp	main
	