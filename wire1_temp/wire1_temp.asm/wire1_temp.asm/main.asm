.include "macros.asm"
.include "definitions.asm"

reset:
	LDSP	RAMEND
	rcall	wire1_init
	rcall	LCD_init
	rjmp	main

.include "lcd.asm"
.include "printf.asm"
.include "wire1.asm"

main:
	rcall	wire1_reset
	ldi		a1,8
	CA		wire1_write, readROM

rom_read:	
		rcall	wire1_read
		PRINTF	LCD
.db		FHEX, a,0
		DJNZ	a1,rom_read
		CA		lcd_pos, $40
		ldi		a1,8
		CA		wire1_write, readScratchpad

ram_read:
		rcall	wire1_read
		PRINTF	LCD
.db		FHEX,a,0
		DJNZ	a1,ram_read
		rjmp	PC	