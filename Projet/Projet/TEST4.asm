/*
 * TEST4.asm
 *
 *  Created: 30.04.2021 21:15:18
 *   Author: BG
 */

.include "libPerso/per_macro.asm"
.include "lib/definitions.asm"

.equ	bufferLen	= 12		;à modifier
.equ	SRAM_flag	= 0
.equ	EEPROM_flag	= 1

; ======================= memory management ======================================
.dseg
.org	SRAM_START
		buffer : .byte bufferLen

.cseg
; ========================interrupt vector tables =================================
.org 0
		jmp			reset

.org	OVF0addr
		jmp		overflow0

.org	0x30			;end of interrupt vector table ??

; =========interrupt service routine ==========
.org	0x31
overflow0:
		in		_sreg, SREG
		ori		b3, (1<<SRAM_flag)
		out		SREG, _sreg
		reti

; ================== init / reset ===============================

reset:
		LDSP		RAMEND						;load stack pointer (SP)
		//OUTI		DDRC, 0xff					;make portB (LEDs) output -> debugging
		OUTI		TIMSK, (1<<TOIE0)			;init du timer
		OUTI		ASSR,  (1<<AS0)
		OUTI		TCCR0,5						;p.189 5->overflow toutes les secondes
		OUTI		ADCSR,(1<<ADEN) + 6			;init du ADC pour LDR
		OUTI		ADMUX, 0					;pin 0 -> LDR
		rcall		LCD_init
		rcall		encoder_init
		rcall		wire1_init
		ldi			b3, 0						;b3 register for SRAM_flag -> on pourrait utiliser a1 aussi ?
		ldi			a0, 0
		ldi			xl, low(0)					;init des pointeurs pour les bases de données
		ldi			xh, high(0)
		ldi			yl, low(buffer)
		ldi			yh, high(buffer)
		rcall		LCD_clear
		sei										; set global interrupts
		rjmp		main

.include "lib/printf.asm"
.include "lib/lcd.asm"
.include "lib/menu.asm"	
.include "libPerso/per_eeprom.asm"



.include "libPerso/per_encoder.asm"
.include "libPerso/per_wire1.asm"		
.include "libPerso/per_sensors.asm"

main:	
		CYCLIC			a0,0,2
		PRINTF			LCD
.db		CR, CR,FHEX,a,0							;deux retours à la ligne ? ->a indique l'adresse mémoire
		rcall			menui
.db		"Temperature |Humidity    |Light       ",0		;au début du programme ? strmenu : .db "Temperature ..."	
		WAIT_MS			1
		rcall			encoder
		brts			mesurements_choice

		//out			PORTB, b3
		sbrc		b3, SRAM_flag
		rcall		store_SRAM		;and EEPROM

		rjmp			main

mesurements_choice:				; switch case selon le choix du menu (-> a0) pour l'affichage de la mesure 
		rcall		LCD_clear
		cpi			a0,0x0000
		breq		getTemp

		cpi			a0,0x0001
		breq		getHum

		cpi			a0,0x0002
		breq		getLight

		rjmp		mesurements_choice ;boucle infinie si a0 != 0,1,2 


getTemp:
	rcall		temperature
	rcall		LCD_home
	PRINTF		LCD
.db	"temp  ",FFRAC2+FSIGN,b,4,$42," C",CR,0
	rcall		encoder
	brts		come_back
	rjmp		getTemp

getHum:
	rcall		humidity
	rcall		LCD_home
	PRINTF		LCD
.db	"hum   ",FFRAC2+FSIGN,b,4,$42," %",CR,0
	rcall		encoder
	brts		come_back
	rjmp		getHum

getLight:
	rcall		light
	rcall		LCD_home ;change
	PRINTF		LCD
.db	"light ",FFRAC2+FSIGN,b,4,$42," lm",CR,0
	rcall		encoder
	brts		come_back
	rjmp		getLight


come_back:
	rcall		LCD_clear
	rcall		LCD_home
	rjmp		main

store_SRAM:
		rcall	temperature
		st		y+, b1		;store dans la SRAM
		st		y+, b0
		
		rcall	humidity
		st		y+, b1
		st		y+, b0

		rcall	light
		st		y+, b1
		st		y+, b0

		andi	b3, ~(1<<SRAM_flag)

		cpi		yl, bufferLen			;si yl pointe vers l'adresse suivant la fin du buffer -> EEPROM
		brne	PC+2
		rcall	store_EEPROM	

		ret

store_EEPROM:
		ldi		yl, 0
loop:
		ld		_u, y+		;utiliser le scratch register pour les interruptions
		mov		b1, _u
		ld		_u, y+		
		mov		b0, _u
		rcall	record
		cpi		yl, bufferLen
		brne	loop

		ldi		yl, 0
		ret




