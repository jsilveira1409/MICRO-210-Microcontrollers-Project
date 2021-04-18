; file	lcd2-2.asm   target ATmega128L-4MHz-STK300
; purpose LCD HD44780U, various display/cursor operations
.include "macros.asm"		;include macro definitions
.include "definitions.asm"	;include register/constant definitions

reset: 
	LDSP	RAMEND		;set up stack pointer (SP)
	OUTI	DDRB,0xff	;configure portB to output		
	rcall	LCD_init	;initialize LCD

intro:
	ldi	a0,'A'		;write the character 'A'
	rcall	lcd_putc
	ldi	a0,'V'		;write the character 'V'
	rcall	lcd_putc
	ldi	a0,'R'		;write the character 'R'
	rcall	lcd_putc	
	rjmp intro