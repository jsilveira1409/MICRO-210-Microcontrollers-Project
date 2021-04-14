/*
 * lcd2.asm
 *
 *  Created: 05/03/2021 06:07:14
 *   Author: Joaquim Silveira
 */
 
.include	"macros.asm"
.include	"definitions.asm"
.include	"lcd.asm"

reset:	LDSP	RAMEND
		OUTI	DDRB,0xff
		rcall	LCD_init
		rcall	LCD_blink_on
		jmp	intro

intro:	ldi		a0, 'A'
		rcall	lcd_putc
		ldi		a0, 'V'
		rcall	lcd_putc
		ldi		a0, 'R'
		rcall	lcd_putc

main:	WAIT_MS	100
		CP0		PIND, 0, LCD_home
		CP0		PIND, 1, LCD_clear
		CP0		PIND, 2, LCD_display_right
		CP0		PIND, 3, LCD_display_left
		CP0		PIND, 4, LCD_cursor_right
		CP0		PIND, 5, LCD_cursor_left
		CP0		PIND, 6, intro
		rjmp	main
