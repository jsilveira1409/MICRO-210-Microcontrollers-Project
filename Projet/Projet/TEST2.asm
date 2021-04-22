.include "lib/macros.asm"
.include "lib/definitions.asm"

reset:
		LDSP		RAMEND
		OUTI		DDRB, 0xff
		rcall		LCD_init
		OUTI		ADCSR, (1<<ADEN)+6
		OUTI		ADMUX, 3
		jmp			main

.include "lib/lcd.asm"
.include "lib/printf.asm"

main:
		sbi		ADCSR,ADSC
		WP1		ADCSR,ADSC
		in		a0, ADCL
		in		a1, ADCH
		PRINTF		LCD
.db	CR, CR, "ADC=",FDEC2,a,"     ",0
		WAIT_US		100000
		rjmp main