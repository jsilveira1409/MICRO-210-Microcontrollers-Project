.include "lib/macros.asm"
.include "lib/definitions.asm"

; ========================interrupt vector tables =================================
.org 0
		jmp			reset

.org	OVF0addr
		rjmp		overflow0


; =========interrupt service routine ==========
	
overflow0:
		in			_sreg, SREG
		out			SREG, _sreg
		reti
; ================== init / reset ===============================
reset:
		LDSP		RAMEND
		ldi			r17, 0xff
		out			DDRC,r17
		rcall		wire1_init
		rcall		lcd_init
		rcall		encoder_init
		;OUTI		TIMSK, (1<<TOIE0)			;init du timer
		;OUTI		ASSR,  (1<<AS0)
		;OUTI		TCCR0,6
		OUTI		ADCSR,(1<<ADEN) + (1<<ADIE) + 6 ;init du ADC pour LDR
		OUTI		ADMUX, 0						;pin 0 -> LDR
		;OUTI		ADMUX, 1						;pin 1 -> humidity   VERIFIER QUE CA MARCHE COMME CA -- > JE PENSE PAS
		ldi			a0, 0
		;sei									; set global interrupts
		rjmp			main

.include "lib/printf.asm"
.include "lib/lcd.asm"
.include "lib/encoder.asm"
.include "lib/wire1.asm"	
.include "lib/menu.asm"	
.include "lib/eeprom.asm"
.include "libPerso/Sensors.asm"


main:
		CYCLIC			a0,0,2
		PRINTF			LCD
.db		CR, CR, FHEX,a,0
		rcall			menui
.db		"Temperature|Humidity   |Light      ",0		
		WAIT_MS			1
		rcall			encoder
		brts			mesurements_choice			
		rjmp			main

mesurements_choice:				; switch case selon le choix du menu (-> a0) pour l'affichage de la mesure
		rcall		LCD_clear
		ldi			w, 0x0000		;Temperature code
		cp			a0,w
		breq		getTemp
		ldi			w, 0x0001		;Humidity code
		cp			a0,w
		breq		getHum
		ldi			w, 0x0002
		cp			a0,w
		breq		getLight
		rjmp		mesurements_choice


getTemp:
	rcall		temperature
	PRINTF		LCD
.db	"temp ",FFRAC2+FSIGN,a,4,$42," C",CR,0
	rcall		encoder
	brts		come_back
	rjmp		getTemp

getHum:
	;rcall		humidity
	rcall		lcd_home
	PRINTF		LCD
;.db	"hum ",FFRAC2+FSIGN,a,4,$42," %",CR,0
.db		"va te pendre",0
	rcall		encoder
	brts		come_back
	rjmp		getHum

getLight:
	rcall		light
	PRINTF		LCD
.db	"light  ",FFRAC2+FSIGN,a,4,$42," lm  ",CR,0
	rcall		encoder
	brts		come_back
	rjmp		getLight


come_back:
	ldi			a0, 0
	rcall		lcd_clear
	rjmp		main

	
	


