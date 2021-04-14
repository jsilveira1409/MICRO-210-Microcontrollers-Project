.equ	LCD_IR	=	0x8000
.equ	LCD_DR	=	0xc000
.macro LD_IR
a:		lds		r16,LCD_IR
		sbrc	r16,7
		rjmp	a
		ldi		r16,@0
		sts		LCD_IR,r16
		.endmacro
reset:
		in		r16, MCUCR
		sbr		r16, (1<<SRE)+(1<<SRW10)
		out		MCUCR, r16
		
main:
		LD_IR 0b00000001
		LD_IR 0b00000010
		LD_IR 0b00000110
		LD_IR 0b00001111
loop:
		LD_IR 0b00001111
		rjmp	loop
