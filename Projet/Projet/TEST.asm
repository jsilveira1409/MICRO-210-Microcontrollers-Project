.include "libPerso/per_macro.asm"
.include "lib/definitions.asm"

.equ   bufferLen = 90		;à modifier

; ======================= memory management ======================================
.dseg
.org	SRAM_START
		buffer : .byte bufferLen
		//dataTemp  : .byte bufferLen
		//dataHum   : .byte bufferLen
		//dataLight : .byte bufferLen
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

		ldi		a3, 0xCA	;temp
		ldi		a2, 0xFE
		st		y+, a3		;store dans la SRAM
		st		y+, a2
		
		ldi		a3, 0xAB	;hum
		ldi		a2, 0xCD
		st		y+, a3
		st		y+, a2

		ldi		a3, 0xB1	;light
		ldi		a2, 0x7E
		st		y+, a3
		st		y+, a2
		
		cpi		yl, bufferLen
		//breq	record_eeprom

		out		SREG, _sreg
		reti

; ================== init / reset ===============================

reset:
		LDSP		RAMEND						; load stack pointer (SP)
		;wdr										; reset watchdog timer
		;ldi			r16, 1<<WDE+0b000			; enable watchdog
		;out			WDTCR, r16
		OUTI		TIMSK, (1<<TOIE0)			;init du timer
		OUTI		ASSR,  (1<<AS0)
		OUTI		TCCR0,6						;p.189 5->overflow toutes les secondes
		OUTI		ADCSR,(1<<ADEN) + 6 ;init du ADC pour LDR
		OUTI		ADMUX, 0						;pin 0 -> LDR
		;OUTI		ADMUX, 1						;pin 1 -> humidity   VERIFIER QUE CA MARCHE COMME CA -- > JE PENSE PAS
		;ldi			c0, 0
		rcall		LCD_init
		rcall		encoder_init
		rcall		wire1_init
		
		ldi			a0, 0
		ldi			xl, low(0)			;init des pointeurs pour les bases de données
		ldi			xh, high(0)
		ldi			yl, low(dataTemp)
		ldi			yh, high(dataTemp)	;yh !!
		rcall		LCD_clear
		//sei									; set global interrupts
		rjmp			main

.include "lib/printf.asm"
.include "lib/lcd.asm"
.include "lib/menu.asm"	
.include "libPerso/per_eeprom.asm"



.include "libPerso/per_encoder.asm"
.include "libPerso/per_wire1.asm"		
.include "libPerso/per_sensors.asm"

main:	
		;wdr
		;CYCLIC			c0,0,2
		CYCLIC			a0,0,2
		PRINTF			LCD
.db		CR, CR,FHEX,a,0							;deux retours à la ligne ? ->a indique l'adresse mémoire
//.db		FHEX,a,0							??
		rcall			menui
.db		"Temperature |Humidity    |Light       ",0		;au début du programme ? strmenu : .db "Temperature ..."	
		WAIT_MS			1
		rcall			encoder
		brts			mesurements_choice			
		rjmp			main

;mesurements_choice:				; switch case selon le choix du menu (-> c0) pour l'affichage de la mesure
mesurements_choice:				; switch case selon le choix du menu (-> a0) pour l'affichage de la mesure
		;push		a0			;change 
		rcall		LCD_clear
		//ldi			w, 0x0000		;Temperature code
		;cp			b0,w
		cpi			a0,0x0000
		breq		getTemp
		//ldi			w, 0x0001		;Humidity code
		;cp			b0,w
		cpi			a0,0x0001
		breq		getHum
		//ldi			w, 0x0002		;light code
		;cp			b0,w
		cpi			a0,0x0002
		breq		getLight
		;pop			a0			;change
		rjmp		mesurements_choice ;boucle infinie si a0 != 0,1,2 


getTemp:
	;wdr
	;mov			b0, a0  ;change
	rcall		temperature
	rcall		LCD_home
	PRINTF		LCD
;.db	"tem ",FFRAC2+FSIGN,a,4,$42," C",CR,0
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
	;ldi			c0, 0
	//ldi			a0, 0	;plus besoin vu qu'on ne change pas cette valeur
	;mov			a0, b0 ;change
	rcall		LCD_clear
	rcall		LCD_home
	rjmp		main



overflowtest:
		in		_sreg, SREG
		/*push	a3
		push	a2
		push	_u
		push	b1
		push	b0*/

		ldi		a3, 0xCA	;temp
		ldi		a2, 0xFE
		st		y+, a3		;store dans la SRAM
		st		y, a2		;pas de +y
		clr		a2			;clear le registre pour contrôler si la valeur est bien stockée dans la SRAM
		clr		a3			;clear le registre pour contrôler si la valeur est bien stockée dans la SRAM

		subi	yl, 1		;revenir à l'adresse du MSB dans la SRAM
		ld		_u, y+		;utiliser le scratch register pour les interruptions
		mov		b1, _u
		clr		_u			;clear
		ld		_u, y		
		mov		b0, _u
		clr		_u			;clear
		subi	yl, 1
		rcall	record

		ldi		a3, 0xAB	;hum
		ldi		a2, 0xCD
		//subi	yl, 1
		adiw	yl, bufferLen
		st		y+, a3
		st		y, a2		;pas de +y
		clr		a2			;clear le registre pour contrôler si la valeur est bien stockée dans la SRAM
		clr		a3			;clear le registre pour contrôler si la valeur est bien stockée dans la SRAM

		subi	yl, 1		;revenir à l'adresse du MSB dans la SRAM
		//adiw	yl, bufferLen
		ld		_u, y+		;utiliser le scratch register pour les interruptions
		mov		b1, _u
		clr		_u			;clear
		ld		_u, y		
		mov		b0, _u
		clr		_u			;clear
		subi	yl, 1
		rcall	record

		//subi	yl, 1
		ldi		a3, 0xB1	;light
		ldi		a2, 0x7E
		adiw	yl, 2*bufferLen
		st		y+, a3
		st		y, a2		;pas de +y
		clr		a2			;clear le registre pour contrôler si la valeur est bien stockée dans la SRAM
		clr		a3			;clear le registre pour contrôler si la valeur est bien stockée dans la SRAM

		subi	yl, 1		;revenir à l'adresse du MSB dans la SRAM
		//adiw	yl, 2*bufferLen
		ld		_u, y+		;utiliser le scratch register pour les interruptions
		mov		b1, _u
		clr		_u			;clear
		ld		_u, y+		
		mov		b0, _u
		clr		_u			;clear
		//subi	yl, 1
		rcall	record
		subi	yl, bufferLen
		subi	yl, bufferLen

		/*rcall	temperature		
		st		x+, a0
		st		x+, a1
		rcall	humidity	
		st		y+, a0
		st		y+, a1
		rcall	light
		st		z+, a0
		st		z+, a1*/

		/*pop b0
		pop	b1
		pop _u
		pop a2
		pop a3*/
		out		SREG, _sreg
		reti



