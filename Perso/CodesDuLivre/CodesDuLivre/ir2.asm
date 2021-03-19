.include	"macros.asm"
.include	"definitions.asm"

reset:
	LDSP	RAMEND
	rcall	LCD_init
	rjmp	main

.include	"lcd.asm"
.include	"printf.asm"

main:
	clr		r20
	clr		r21
	WP1		PINE, IR
loop:
	subi	r20, low(-1)
	sbci	r21,high(-1)
	JP0		PINE,IR,loop
	PRINTF	LCD
.db	"t=",FDEC2,20,"usec		",CR,0
	rjmp	main