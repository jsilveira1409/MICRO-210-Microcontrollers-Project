.include "lib/macros.asm"
.include "lib/definitions.asm"

reset:
		LDSP		RAMEND
		rcall		lcd_init
		jmp			main


.include "lib/lcd.asm"
.include "lib/printf.asm"

main:
	rcall		lcd_home
	PRINTF		LCD
	.db "vincente t bo ", 0
	WAIT_MS 500
	rjmp main