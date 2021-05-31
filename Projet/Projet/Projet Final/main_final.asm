.include "libPerso/per_macro.asm"
.include "lib/definitions.asm"

.equ	bufferLen		= 12			;à modifier, 12 octets-->4 seconds
.equ	SRAM_flag		= 0
.equ	EEPROM_START	= 0				;0x0E0a pour tester si le pointeur revient au début à modifier -> 0
.equ	eepromLen		= 0x00b4		;0x0E10 / 0x001E /0x0708 /0x0384 /0x00b4 /0x021C -> correspond à 3min avec 1mesure/2sec
;180 octet
; ======================= memory management ======================================
.dseg
.org	SRAM_START						;debut du buffer dans la sram
		buffer : .byte bufferLen

.cseg
; ========================interrupt vector tables =================================
.org 0									
		jmp			reset

.org	OVF0addr						
		jmp		overflow0

; =========interrupt service routine ==========

overflow0:								;timer overflow pour activer le flag de stockage dans la SRAM, des valeurs 
		in		_sreg, SREG				;des trois valeurs
		ori		b3, (1<<SRAM_flag)
		out		SREG, _sreg
		reti

; ================== init / reset ===============================

reset:
		LDSP		RAMEND						;load stack pointer (SP)
		OUTI		TIMSK, (1<<TOIE0)			;activation du timer
		OUTI		ASSR,  (1<<AS0)				
		OUTI		TCCR0,6						;overflow toutes les 2 secondes (5 -> toutes les secondes)
		OUTI		ADCSR,(1<<ADEN) + 6			;init du ADC pour LDR
		rcall		LCD_init
		rcall		encoder_init
		rcall		wire1_init
		ldi			b3, 0						;b3 register for SRAM_flag
		ldi			a0, 0						
		ldi			xl, low(EEPROM_START)		;init des pointeurs pour les bases de données/buffer
		ldi			xh, high(EEPROM_START)
		ldi			yl, low(buffer)
		ldi			yh, high(buffer)
		rcall		LCD_clear
		OUTI		DDRE,0b00000010				;make Tx (PE1) an output (arduino communication)
		sbi			PORTE,PE1					;set Tx to high			 (arduino communication
		rcall		set_eeprom					;concerne arduino
		sei										;set global interrupts
		rjmp		main

.include "lib/printf.asm"
.include "lib/lcd.asm"
.include "lib/menu.asm"	

.include "libPerso/per_eeprom.asm"				;libs du cours modifies par nous pour que les ports et 
.include "libPerso/per_encoder.asm"				;les registres ni coincident ni se superposent
.include "libPerso/per_wire1.asm"		
.include "libPerso/per_sensors.asm"
.include "libPerso/per_uart.asm"

.macro	STVALSRAM								;store sensor value to SRAM
	st		y+, b1
	st		y+, b0
	.endmacro

main:	
		CYCLIC			a0,0,3					;limite a0 à 0-1-2-3 pour le menu(le menu n'est plus cyclic)
		PRINTF			LCD
.db		CR, CR,FHEX,a,0							
		rcall			menui
.db		"Temperature |Humidity    |Light       |Upload      ",0	;choix dans le menu	
		WAIT_MS			1
		rcall			encoder					;verifie l'etat de l'encodeur angulaire pour les changements
		brts			mesurements_choice		;si l'encodeur est appuyé, un choix a été fait
		sbrc			b3, SRAM_flag			;flag pour stockage active et on stocke la valeur dans la sram
		rcall			store					;stocke dans la SRAM et verifie si elle est pleine 
		rjmp			main					;pour stocker dans l'eeprom

mesurements_choice:					;switch case selon le choix du menu (-> a0) pour l'affichage de la mesure 
		rcall		LCD_clear
		cpi			a0,0x0000
		breq		getTemp

		cpi			a0,0x0001
		breq		getHum

		cpi			a0,0x0002
		breq		getLight

		cpi			a0,0x0003
		breq		upload
		rjmp		mesurements_choice  

getTemp:
		rcall		temperature			;lecture de la valeur et stockage dans (b1,b0) (MSB, LSB)
		rcall		LCD_home
		PRINTF		LCD
.db	"temp  ",FFRAC2+FSIGN,b,4,$42," C",CR,0
		rcall		encoder				;verifie l'etat de l'encodeur au cas ou il a été appuyé
		brts		come_back			;revient si c'est le cas
		sbrc		b3, SRAM_flag		;flag pour stockage active et on stocke les 3 valeurs dans la sram
		rcall		store				;stocke dans la SRAM et verifie si elle est pleine 	
		rjmp		getTemp
	
getHum:
		rcall		humidity			;lecture de la valeur et stockage dans (b1,b0) (MSB, LSB)	
		rcall		LCD_home		
		PRINTF		LCD
.db	"hum   ",FFRAC2+FSIGN,b,4,$42," %",CR,0
		rcall		encoder				;verifie l'etat de l'encodeur au cas ou il a été appuyé
		brts		come_back			;revient si c'est le cas
		sbrc		b3, SRAM_flag		;flag pour stockage active et on stocke les 3 valeurs dans la sram
		rcall		store				;stocke dans la SRAM et verifie si elle est pleine 	
		rjmp		getHum

come_back:
		rcall		LCD_clear
		rcall		LCD_home
		rjmp		main

getLight:
		rcall		light
		rcall		LCD_home						;change
		PRINTF		LCD
.db	"light ",FFRAC2+FSIGN,b,4,$42," lm",CR,0
		rcall		encoder
		brts		come_back
		sbrc		b3, SRAM_flag
		
		rcall		store							;SRAM and EEPROM
		rjmp		getLight

upload:						;arduino
		cli					;disable interrupts pour ne pas deranger l'upload
		rcall		LCD_home
		PRINTF		LCD
.db	"Uploading...",0
		WAIT_MS		500
		mov		w, xl		;store pointer value
		mov		_w, xh
	loop_upload:
		adiw		xl,1					; incrementation de l'adresse de la eeprom (incrémentation de xl, xh -> word)
		rcall		eeprom_load
		mov			b1, b0
		rcall		eeprom_load

		cpi			b1, 0x00					;ou 0x00 ?
		brne		PC+3
		cpi			b0, 0x00					;ou 0x00 ?
		breq		PC+4

		rcall		putc						;send instruction b0 via uart
		mov			b0, b1						;-> b0 b1 et non pas b1 b0 (endian)
		rcall		putc

		cp			xl, w						;si le pointeur est égal à la valeur initiale on s'arrête
		brne		PC+4
		cp			xh, _w						;si le pointeur est égal à la valeur initiale on s'arrête
		brne		PC+2
		rjmp		end

		cpi			xl, low(eepromLen)			;xl max
		brne		PC+4
		cpi			xh, high(eepromLen)			;xh max
		brne		PC+2
		rjmp		end
		rjmp		loop_upload
		sei							; enable interrupts pas besoin ??
	end:
		mov			xl, w			; restore pointer value
		mov			xh, _w

		rjmp		come_back

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

set_eeprom:										;arduino vu que les interruptions ne sont pas encore active pas besoin de les (dés)activer
		ldi			b0, 0x00								;mettre 0x00 ? vu que avrisp-u met tout à ff ? remplir la eeprom
		loop_set:
					rcall		eeprom_store			; stockage du LSB?? de la temperature
					adiw		xl,1					; incrementation de l'adresse de la eeprom (incrémentation de xl, xh -> word)
					cpi			xl, low(eepromLen)			;xl max
					brne		loop_set
					cpi			xh, high(eepromLen)			;xh max
					brne		loop_set										
		ldi			xl, low(EEPROM_START)					;init des pointeurs pour les bases de données
		ldi			xh, high(EEPROM_START)					;pour remettre le pointeur à 0 après avoir set la eeprom à 0xff
		ret
	




