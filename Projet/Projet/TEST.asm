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
		out			SREG, _sreg
		reti

; ==========reset / initialization================
reset:
		LDSP		RAMEND
		ldi			xl, low(0)					;memoire eeprom adresse init
		ldi			xh, high(0)
		rcall		lcd_init						; CAUSE DES PROBLEMES AVEC LES INTERRUPTIONS
		rcall		encoder_init
		ldi			b0, 0
		ldi			b2, 0
		
		rjmp		main


;	============================libs du livre/cours===============================================
.include "lib/lcd.asm"
.include "lib/printf.asm"

;	================================libs personnelles avec changements de variables ===============
.include "libPerso/per_encoder.asm"	
.include "libPerso/per_menu.asm"

; ======================main ==============================
main:
		rcall		LCD_home	

		CYCLIC			b0,0,2
		PRINTF			LCD
.db		CR, CR, FHEX,b,0	
		rcall			menui
.db		"Temperature|Humidity   |Light     ",0		
		WAIT_MS			10
		rcall			encoder
		rjmp		main
	
; =======================subroutine=========================	