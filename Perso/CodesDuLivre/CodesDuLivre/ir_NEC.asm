.include "macros.asm"
.include "definitions.asm"

reset:
	LDSP	RAMEND
	rcall	LCD_init
	rjmp	main

.include	"lcd.asm"
.include	"printf.asm"

.equ	T2 = 15532
.equ	T1 = 1180

main:	CLR2	b1, b0
		CLR2	a1,a0
		ldi		b2,16
		WP1		PINE,IR
		WAIT_US	T2
		clc
addr:	P2C		PINE,IR
		ROL2	b1,b0
		sbrc	b0,0
		rjmp	rdz_a
		WAIT_US	(T1-4.5)
		DJNZ	b2,addr
		jmp		next_a

rdz_a:
		WAIT_US	(2*T1 - 5.5)
		DJNZ	b2,addr

next_a:	MOV2	d1,d0,b1,b0
		MOV2	a1,a0,b1,b0
		ldi		b2,16
		clc
		CLR2	b1,b0

data:	P2C		PINE,IR
		ROL2	b1,b0
		sbrc	b0,0
		rjmp	rdz_d
		WAIT_US	(T1 - 4.5)
		DJNZ	b2,data
		jmp		next_b
rdz_d:
		WAIT_US	(2*T1 - 5.5)
		DJNZ	b2,data
next_b:
		MOV2	d3,d2,b1,b0
data_proc01:
		_CPI	d3,0xff
		brne	data_proc02
		_CPI	d2,0xff
		brne	data_proc02
		_CPI	d1,0xff
		brne	data_proc02
		_CPI	d0,0xff
		brne	data_proc02
display_reset:
		rcall	LCD_clear
		rcall	LCD_home
		MOV4	a1,a0,b1,b0,c3,c2,c1,c0
		PRINTF	LCD
.db		"A=",FHEX2,a," C=",FHEX2,b,0
		PRINTF	LCD
.db		LF,"REPEAT",0
		rjmp main

data_proc02:
		com		d1
		cpse	d0,d1
		brne	display_error
		com		d3
		cpse	d2,d3
		brne	display_error
display_correct:
		com		b0
		com		b1
		com		a0
		com		a1
		com		b0
		rcall	LCD_clear
		rcall	LCD_home
		PRINTF	LCD
.db		"A=", FHEX2,a," C=",FHEX2,b,0
		MOV4	c3,c2,c1,c0,a1,a0,b1,b0
		rjmp	main
display_error:
		com		b0
		com		b1
		com		a0
		com		a1
		rcall	LCD_clear
		rcall	LCD_home
		PRINTF	LCD
.db		"EA=",FHEX2,a,"	EC=",FHEX2,b,0
		rjmp main		