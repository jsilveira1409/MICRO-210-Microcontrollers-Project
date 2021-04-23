
;.include "sensors1.asm"

main_menu:
		rcall		encoder
		brts		temperature
		CYCLIC		a0,0,2
		PRINTF		LCD
.db		CR, CR, FHEX,a,0
		rcall		menui
.db		"Temperature|Humidity   |Light      ",0		
		WAIT_MS		1
		rjmp		main_menu


temperature:
	rcall		encoder
	brts		main_menu
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
	rjmp		temperature
	


