/*
 * TEST4.asm
 *
 *  Created: 30.04.2021 21:15:18
 *   Author: BG
 */

.include "libPerso/per_macro.asm"
.include "lib/definitions.asm"

.equ	bufferLen		= 12			;à modifier
.equ	SRAM_flag		= 0
//.equ	display_flag	= 1
.equ	EEPROM_START	= 0	;0x0E0a pour tester si le pointeur revient au début à modifier -> 0
.equ	eepromLen		= 0x0E10
//.equ	EEPROM_flag	= 1

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

//.org	OVF3addr
		//jmp		overflow2

//.org	0x30			;end of interrupt vector table ??

; =========interrupt service routine ==========
//.org	0x31
overflow0:
		in		_sreg, SREG
		ori		b3, (1<<SRAM_flag)
		out		SREG, _sreg
		reti

//overflow2:
		//in		_sreg, SREG
		//ori		b3, (1<<display_flag)
		//out		SREG, _sreg
		//reti

; ================== init / reset ===============================

reset:
		LDSP		RAMEND						;load stack pointer (SP)
		//OUTI		DDRC, 0xff					;make portB (LEDs) output -> debugging
		OUTI		TIMSK, (1<<TOIE0)			;init du timer
		OUTI		ASSR,  (1<<AS0)
		OUTI		TCCR0,5						;p.189 6->overflow toutes les 2 secondes (5 -> toutes les secondes)

		//OUTI		TIMSK, (1<<TOIE2)			;init du timer
		//OUTI		ASSR,  (1<<AS0)
		//OUTI		TCCR2, 2					;p.189 6->overflow toutes les

		OUTI		ADCSR,(1<<ADEN) + 6			;init du ADC pour LDR
		//OUTI		ADMUX, 3					;pin 0 -> LDR ???
		//OUTI		ADMUX, 1
		rcall		LCD_init
		rcall		encoder_init
		rcall		wire1_init
		ldi			b3, 0						;b3 register for SRAM_flag -> on pourrait utiliser a1 aussi ?
		ldi			a0, 0
		ldi			xl, low(EEPROM_START)					;init des pointeurs pour les bases de données
		ldi			xh, high(EEPROM_START)
		ldi			yl, low(buffer)
		ldi			yh, high(buffer)
		rcall		LCD_clear
		//OUTI	DDRE,0b00000010	; make Tx (PE1) an output ;arduino
		//sbi		PORTE,PE1	; set Tx to high			;arduino
		//rcall		set_eeprom					;arduino
		sei										; set global interrupts
		rjmp		main

.include "lib/printf.asm"
.include "lib/lcd.asm"
.include "lib/menu.asm"	
.include "libPerso/per_eeprom.asm"



.include "libPerso/per_encoder.asm"
.include "libPerso/per_wire1.asm"		
.include "libPerso/per_sensors.asm"
.include "libPerso/TESTuart2.asm"

.macro	STVALSRAM		;store sensor value to SRAM
	st		y+, b1
	st		y+, b0
	.endmacro

main:	
		CYCLIC			a0,0,2
		//CYCLIC			a0,0,3		;arduino
		PRINTF			LCD
.db		CR, CR,FHEX,a,0							;deux retours à la ligne ? ->a indique l'adresse mémoire
		rcall			menui
.db		"Temperature |Humidity    |Light       ",0		;au début du programme ? strmenu : .db "Temperature ..."
//.db		"Temperature |Humidity    |Light       |Upload      ",0		;au début du programme ? strmenu : .db "Temperature ..." arduino	
		WAIT_MS			1
		rcall			encoder
		brts			mesurements_choice

		//out			PORTB, b3
		sbrc		b3, SRAM_flag
		//rcall		store				;SRAM
		rcall		store				;SRAM and EEPROM


		rjmp			main

mesurements_choice:				; switch case selon le choix du menu (-> a0) pour l'affichage de la mesure 
		rcall		LCD_clear
		cpi			a0,0x0000
		breq		getTemp

		cpi			a0,0x0001
		breq		getHum

		cpi			a0,0x0002
		breq		getLight

		//cpi			a0,0x0003			;arduino
		//breq		upload
		
		//clr			a0					;sinon boucle infinie si a0 != 0,1,2 ?
		rjmp		mesurements_choice  


getTemp:
	rcall		temperature
	rcall		LCD_home
	PRINTF		LCD
.db	"temp  ",FFRAC2+FSIGN,b,4,$42," C",CR,0
	rcall		encoder
	brts		come_back

	sbrc		b3, SRAM_flag
	rcall		store							;SRAM and EEPROM
	rjmp		getTemp

getHum:
	rcall		humidity
	rcall		LCD_home
	PRINTF		LCD
.db	"hum   ",FFRAC2+FSIGN,b,4,$42," %",CR,0
	rcall		encoder
	brts		come_back

	sbrc		b3, SRAM_flag
	rcall		store							;SRAM and EEPROM
	rjmp		getHum

getLight:
	//sbrs		b3, display_flag			;skip if display_flag is set
	//rjmp		PC-1						;jump back to previous address
	//andi		b3, ~(1<<display_flag)		;clear bit display_flag in b3 register
	rcall		light
	rcall		LCD_home						;change
	PRINTF		LCD
.db	"light ",FFRAC2+FSIGN,b,4,$42," lm",CR,0
	rcall		encoder
	brts		come_back
	sbrc		b3, SRAM_flag

	rcall		store							;SRAM and EEPROM
	rjmp		getLight

/*upload:										;arduino
	//cli					; disable interrupts pas besoin ?
	rcall		LCD_home
	PRINTF		LCD
.db	"Uploading...",0
	mov		w, xl		;store pointer value
	mov		_w, xh

	loop_upload:
	adiw		xl,1					; incrementation de l'adresse de la eeprom (incrémentation de xl, xh -> word)
	rcall eeprom_load
	cpi		b0, 0xff					;ou 0x00 ?
	breq	PC+2
	rcall	putc						;send instruction b0 via uart
	cpi			xl, w						;si le pointeur est égal à la valeur initiale on s'arrête
	brne		PC+4
	cpi			xh, _w						;si le pointeur est égal à la valeur initiale on s'arrête
	brne		PC+2
	rjmp		end

	cpi			xl, low(eepromLen)			;xl max
	brne		PC+4
	cpi			xh, high(eepromLen)			;xh max
	brne		PC+2
	rjmp		end
	rjmp		loop_upload
	//sei					; enable interrupts pas besoin ??
	end:
	mov		xl, w			;restore pointer value
	mov		xh, _w
	rjmp		come_back*/

come_back:
	rcall		LCD_clear
	rcall		LCD_home
	rjmp		main

store:
		rcall		temperature
		STVALSRAM							;store to SRAM
		
		rcall		humidity
		STVALSRAM							;store to SRAM

		rcall		light
		STVALSRAM							;store to SRAM

		andi		b3, ~(1<<SRAM_flag)		;clear bit SRAM_flag in b3 register

		cpi			yl, bufferLen			;if yl at the end of the buffer then
		brne		PC+4					
		ldi			yl, 0
		rcall		record					;store to EEPROM
		ldi			yl, 0

		ret

/*set_eeprom:				;arduino vu que les interruptions ne sont pas encore active pas besoin de les (dés)activer
		ldi			b0, 0xff								;mettre 0x00 ? vu que avrisp-u met tout à ff ? remplir la eeprom
		loop_set:
					rcall		eeprom_store			; stockage du LSB?? de la temperature
					adiw		xl,1					; incrementation de l'adresse de la eeprom (incrémentation de xl, xh -> word)
					cpi			xl, low(eepromLen)			;xl max
					brne		loop_set
					cpi			xh, high(eepromLen)			;xh max
					brne		loop_set										
		ldi			xl, low(EEPROM_START)					;init des pointeurs pour les bases de données
		ldi			xh, high(EEPROM_START)					;pour remettre le pointeur à 0 après avoir set la eeprom à 0xff
		ret*/
	




