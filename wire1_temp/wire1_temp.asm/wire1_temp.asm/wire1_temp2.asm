.include "macros.asm"
.include "definitions.asm"
.include "lcd.asm"
.include "printf.asm"
.include "wire1.asm"

reset:
		LDSP	RAMEND
		rcall	wire1_init
		RCALL	LCD_init
		rjmp	main

main:
		rcall	wire1_reset
		CA		wire1_write, skipROM
		CA		wire1_write, convertT
		WAIT_MS	750
		rcall	LCD_home
		rcall	wire1_reset
		CA		wire1_write,skipROM
		CA		wire1_write, readScratchpad
		rcall	wire1_read
		mov		c0,a0
		rcall	wire1_read
		mov		a1,a0
		mov		a0,c0
		PRINTF	LCD_putc
.db		"temp=",FFRAC2+FSIGN,a,4,$42,"C ",CR,0
		rjmp	main