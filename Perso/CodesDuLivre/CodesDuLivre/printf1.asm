.include "macros.asm"
.include "definitions.asm"

reset:		LDSP	RAMEND
			jmp		main	
.include "lcd.asm"
.include "printf.asm"

main:		
			
			PRINTF	LCD
.db			"hello",0
			rjmp	main