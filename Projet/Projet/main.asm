.include "lib/macros.asm"
.include "lib/definitions.asm"

.org 0
		jmp			reset

.org	OVF0addr
		inc		r17
		out		PORTB, r17
		reti


reset:
		LDSP		RAMEND
		outi		DDRB, 0xff
		outi		PORTB, 0x00
		rcall		wire1_init
		rcall		lcd_init
		OUTI		TIMSK, (1<<TOIE0)
		OUTI		ASSR,  (1<<AS0)
		OUTI		TCCR0,7
		
		rcall		wire1_init
		rcall		lcd_init
		rcall		encoder_init
		ldi			a0, 0
		
		jmp		intro

.include "lib/printf.asm"
.include "lib/lcd.asm"
.include "lib/encoder.asm"
.include "lib/wire1.asm"	
.include "lib/menu.asm"	

intro :
		PRINTF	LCD
.db	"Hello world", 0
		WAIT_MS		2000
		rcall		lcd_clear
		PRINTF	LCD
.db	"Getting Ready....", 0
		WAIT_MS		2000
		rcall		lcd_clear
		sei
		rjmp loop


loop:
	rcall			main_menu
	rjmp			loop
	

main_menu:
		rcall		encoder
		brts		mesurements_choice			
		CYCLIC		a0,0,2
		PRINTF		LCD
.db		CR, CR, FHEX,a,0
		rcall		menui
.db		"Temperature|Humidity   |Light      ",0		
		WAIT_MS		1
		rjmp		main_menu

mesurements_choice:				; switch case selon le choix du menu (-> a0) pour l'affichage de la mesure
		ldi			w, 0x0000		;Temperature code
		cp			a0,w
		ldi			w, 0x0001		;Humidity code
		cp			a0,w
		ldi			w, 0x0002
		cp			a0,w
		rjmp		mesurements_choice

temperature:
	rcall		wire1_reset
	CA			wire1_write, skipROM
	CA			wire1_write, convertT
	WAIT_MS		1
	rcall		lcd_home
	rcall		wire1_reset
	CA			wire1_write, skipROM
	CA			wire1_write, readScratchpad
	rcall		wire1_read
	mov			c0,a0
	rcall		wire1_read
	mov			a1, a0
	mov			a0, c0
	PRINTF		LCD
.db	"temp=",FFRAC2+FSIGN,a,4,$42,"C  ",CR,0
	rcall		encoder
	brts		come_back
	rjmp		temperature

humidity:
	PRINTF		LCD
.db	"humidity=",FFRAC2+FSIGN,a,4,$42,"per cent",CR,0
	rcall		encoder
	brts		come_back
	rjmp		humidity

light:
	PRINTF		LCD
.db	"light=",FFRAC2+FSIGN,a,4,$42,"lm  ",CR,0
	rcall		encoder
	brts		come_back
	rjmp		light


come_back:
	ldi			a0, 0
	rcall		lcd_clear
	rjmp		loop

	
	


