.include "lib/macros.asm"
.include "lib/definitions.asm"

reset:
		LDSP	RAMEND
		rcall	LCD_init
		rcall	encoder_init
		ldi		a0,0
		ldi		b0,0
		jmp		main

.include "lib/lcd.asm"
.include "lib/printf.asm"
.include "lib/encoder.asm"
.include "lib/menu.asm"

main:
		rcall	encoder
		CYCLIC	a0,0,3
		PRINTF	LCD
.db		CR, CR, FHEX,a,0
		rcall	menui
.db		"Temperature|Humidity   |Buzzer     |InfraRed   ",0		
		WAIT_MS	1
		rjmp	main
