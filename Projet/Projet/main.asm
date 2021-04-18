.include "lib/macros.asm"
.include "lib/definitions.asm"

reset:
	LDSP	RAMEND
	rcall	wire1_init
	rcall	lcd_init
	rjmp main

.include "lib/lcd.asm"
.include "lib/printf.asm"
.include "lib/wire1.asm"

main:
	rcall	wire1_reset
	CA		wire1_write, skipROM
	CA		wire1_write, convertT
	WAIT_MS	750

	rcall	lcd_home
	rcall	wire1_reset
	CA		wire1_write, skipROM
	CA		wire1_write, readScratchpad
	rcall	wire1_read
	mov		c0,a0
	rcall	wire1_read
	mov		a1, a0
	mov		a0, c0

	PRINTF	LCD
.db	"temp=",FFRAC2+FSIGN,a,4,$42,"C ", CR,0
	rjmp	main