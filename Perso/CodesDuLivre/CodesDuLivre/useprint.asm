/*
 * useprint.asm
 *
 *  Created: 05/03/2021 10:15:58
 *   Author: Administrator
 */ 
 .include "macros.asm"
 .include "definitions.asm"

 reset:
		LDSP	RAMEND
		OUTI	DDRB,0xff
		RCALL	LCD_init
		rjmp	main
.include "lcd.asm"
.include "printf.asm"

main:
		ldi		r16,0x90
		rcall	LCD_home
		rcall	LCD_clear
		PRINTF	LCD_putc
.db		"hello", 0
		WAIT_MS	2000
		rjmp	main