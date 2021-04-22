.include "lib/macros.asm"
.include "lib/definitions.asm"


; ==========================macros =====================================
.macro TEMPERATURE_RECORD
	inc			b3
	out			PORTA, b3		
	rcall		wire1_reset							;reset pulse
	CA			wire1_write, skipROM				;skip ROM identification
	CA			wire1_write, convertT				;initaite temperature convertion							
	WAIT_MS		750		
	rcall		wire1_reset
	CA			wire1_write, skipROM
	CA			wire1_write, readScratchpad
	rcall		wire1_read							;read temperature LSB
	mov			c0,a0
	rcall		wire1_read							;read temperature MSB
	mov			a1, a0
	mov			a0, c0
	rcall		record
.endmacro	

; ========================interrupt vector tables =================================
.org 0
		jmp			reset

.org	OVF0addr
		rjmp		overflow0

; =========interrupt service routine ==========
	
overflow0:
		TEMPERATURE_RECORD
		reti


; ==========reset / initialization================
reset:
		LDSP		RAMEND
		ldi			xl, low(0)				;memoire eeprom adresse init
		ldi			xh, high(0)
		ldi			r16, 0xff
		out			DDRA, r16				;port A en output
		rcall		wire1_init
		OUTI		TIMSK, (1<<TOIE0)		; timer
		OUTI		ASSR,  (1<<AS0)
		OUTI		TCCR0, 0b00000001
		ldi			b3, 0
		sei
		rjmp		temperature

; =======includes ======================

.include "lib/wire1.asm"	
.include "lib/eeprom.asm"
.include "lib/lcd.asm"
.include "lib/printf.asm"

; ======================main ==============================
main:
	
	rjmp		main
	
; =======================subroutine=========================
temperature:
	rcall		wire1_reset							;reset pulse
	CA			wire1_write, skipROM				;skip ROM identification
	CA			wire1_write, convertT				;initaite temperature convertion
	WAIT_MS		750							
	rcall		wire1_reset
	CA			wire1_write, skipROM
	CA			wire1_write, readScratchpad
	rcall		wire1_read							;read temperature LSB
	mov			c0,a0
	rcall		wire1_read							;read temperature MSB
	mov			a1, a0
	mov			a0, c0
	rcall		LCD_clear
	PRINTF		LCD
.db	"temp=",FFRAC2+FSIGN,a,4,$42,"C  ",CR,0
	rjmp		temperature