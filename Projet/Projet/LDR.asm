.include "lib/definitions.asm"
.include "lib/macros.asm"

;================	interrupt table		============
.org	0
		jmp		reset
.org	ADCCaddr
		jmp		ADCCaddr_sra

.org	0x30


; ==============	interrupt service routines ============

ADCCaddr_sra:
		ldi		r23,0x01

		reti

; ==============	initialization / reset ================
reset:	
		LDSP	RAMEND
		OUTI	DDRB,0xff
		OUTI	DDRE,0xff
		sei
		rcall	lcd_init
		OUTI	ADCSR,(1<<ADEN) + (1<<ADIE) + 6
		OUTI	ADMUX, POT
		jmp		main

.include "lib/lcd.asm"
.include "lib/printf.asm"
.include "lib/eeprom.asm"

main:
		WAIT_MS		1000
		clr			r23
		in			w, PIND	
		sbrc		w, 0
		jmp			PC-2
		sbi			ADCSR,ADSC
		WB0			r23,0
		in			a0,ADCL
		in			a1,ADCH
		rcall		record
		PRINTF		LCD
.db	CR,CR,"ADC = ",FDEC2,a, "      ",0
		rjmp		main

