.include "lib/macros.asm"
.include "lib/definitions.asm"

.dseg
		buffer:.byte 1000
.cseg	

	reset:
			LDSP		RAMEND
			rcall		lcd_init
			ldi		xl, low(buffer)

			ldi		xh, high(buffer)
			jmp			main
			


.include "lib/lcd.asm"
.include "lib/printf.asm"

main:
	ldi		a0, 0xAA
	st		x+,a0
	rjmp main