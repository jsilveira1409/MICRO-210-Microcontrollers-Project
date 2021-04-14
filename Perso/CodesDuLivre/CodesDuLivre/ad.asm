;
; CodesDuLivre.asm
;
; Created: 04/03/2021 03:36:15
; Author : Joaquim Silveira
;
.include "macros.asm"
.include "definitions.asm"

reset:
		LDSP	RAMEND
		OUTI	DDRB, 0xff
		rcall	LCD_init

		OUTI	ADCSR, (1<<ADEN) + 6
		OUTI	ADMUX, POT
		jmp		main

.include "lcd.asm"
.include "printf.asm"


main:
		sbi		ADCSR,ADSC
		WP1		ADCSR, ADSC
		in		a0, ADCL
		in		a1, ADCH
		PRINTF	LCD	
		.db		CR, CR, "ADC=",FHEX2,a, "=",FDEC2,a,"   ",0
		WAIT_US	100000
		rjmp	main	
	