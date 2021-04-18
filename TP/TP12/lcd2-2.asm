; file	lcd2-2.asm   target ATmega128L-4MHz-STK300
; purpose LCD HD44780U, various display/cursor operations
.include "macros.asm"		;include macro definitions
.include "definitions.asm"	;include register/constant definitions

reset: 
	LDSP	RAMEND		;set up stack pointer (SP)
	OUTI	DDRB,0xff	;configure portB to output		
	rcall	LCD_init	;initialize LCD
	rcall	LCD_blink_on	;turn blinking on

intro:
	ldi	a0,'A'		;write the character 'A'
	rcall	lcd_putc
	ldi	a0,'V'		;write the character 'V'
	rcall	lcd_putc
	ldi	a0,'R'		;write the character 'R'
	rcall	lcd_putc	
main:
	WAIT_MS 100	
	CP0	PIND,0,LCD_home		;CP0: Call if Port=0
	CP0	PIND,1,LCD_clear
	CP0	PIND,2,LCD_cursor_up
	CP0	PIND,3,LCD_cursor_down
	CP0	PIND,4,LCD_cursor_right
	CP0	PIND,5,LCD_cursor_left
	JP0	PIND,6,intro		;JP0: Jump if Port=0
	CP0	PIND,5,LCD_cursor_left
	rjmp	main
	
; === include ===
.include "lcd.asm"	

LCD_cursor_up:
	lds	w, LCD_IR	; read AC (address counter)
	 i	w, 		; clear bit for line 1
	ori	w,		; set bit
	sts	LCD_IR,w
	ret
LCD_cursor_down:
	lds	w, LCD_IR	; read AC (address counter)
	ori	w,		; set bit for line 2
	ori	w,		; set bit
	sts	LCD_IR,w
	ret
LCD_cursor_toggle:
	lds	w, LCD_IR	; read AC (address counter)
	subi	w,		; add offset
	ori	w,		; set bit
	sts	LCD_IR,w
	ret

