.include "lib/macros.asm"
.include "lib/definitions.asm"

; ==========================macros =====================================

; ========================interrupt vector tables =================================
.org 0
		jmp			reset

.org	OVF0addr
		rjmp		overflow0

; =========interrupt service routine ==========
	
overflow0:
		in			_sreg, SREG
		inc			b3
		out			PORTC, b3
		rcall		temperature
		rcall		record
		rcall		light
		rcall		record
		ldi			a0, 0xFE
		ldi			a1, 0xCA
		rcall		record
		out			SREG, _sreg
		reti
		

; ==========reset / initialization================
reset:
		LDSP		RAMEND
		ldi			xl, low(0)					;memoire eeprom adresse init
		ldi			xh, high(0)
		OUTI		TIMSK, (1<<TOIE0)			; timer
		OUTI		ASSR,  (1<<AS0)
		OUTI		TCCR0, 3
		OUTI		ADCSR,(1<<ADEN) + (1<<ADIE) + 6 ;init du CAN pour LDR
		OUTI		ADMUX, 0						;pin 0 -> LDR
		;OUTI		ADMUX, 1						;pin 1 -> humidity   VERIFIER QUE CA MARCHE COMME CA -- > JE PENSE PAS
		rcall		wire1_init
		;rcall		lcd_init						; CAUSE DES PROBLEMES AVEC LES INTERRUPTIONS
		ldi			r16, 0xff
		out			DDRC, r16						;port A en output --> LEDs
		ldi			b3, 0
		sei
		rjmp		main

.include "lib/lcd.asm"
.include "lib/wire1.asm"	
.include "lib/printf.asm"
.include "lib/eeprom.asm"
.include "Sensors.asm"


; ======================main ==============================
main:
	nop
	rjmp		main
	
; =======================subroutine=========================	