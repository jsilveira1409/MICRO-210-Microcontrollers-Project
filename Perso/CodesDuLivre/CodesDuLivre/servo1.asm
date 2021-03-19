/*
 * servo1.asm
 *
 *  Created: 04/03/2021 13:57:29
 *   Author: Joaquim Silveira
 */ 

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
		P0		PORTB,SERVO1
		WAIT_US	20000
		sbi		ADCSR, ADSC
		WP1		ADCSR,ADSC
		in		a0,ADCL
		in		a1,ADCH
		ADDI2	a1, a0, 1000
		PRINTF	LCD
.db		"pulse=", FDEC2,a,"usec     ", CR, 0
		P1		PORTB, SERVO1
loop:
		SUBI2	a1, a0, 0x1
		brne	loop
		rjmp	main