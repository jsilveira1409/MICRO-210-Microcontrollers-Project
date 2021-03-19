/*
 * lcd2.asm
 *
 *  Created: 05/03/2021 06:07:14
 *   Author: Joaquim Silveira
 */
 
.include	"macros.asm"
.include	"definitions.asm"
.include	"lcd.asm"
.include	"printf.asm"

reset:	LDSP	RAMEND
		OUTI	DDRB,0xff
		rcall	LCD_init
		rcall	LCD_blink_on
		jmp	main

main:	WAIT_MS	100
		PRINTF	LCD_putc
.db		"hello", 0
