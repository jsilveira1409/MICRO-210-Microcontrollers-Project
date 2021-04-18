
temperature:
	rcall		wire1_reset
	CA			wire1_write, skipROM
	CA			wire1_write, convertT
	WAIT_MS		500
	rcall		lcd_home
	rcall		wire1_reset
	CA			wire1_write, skipROM
	CA			wire1_write, readScratchpad
	rcall		wire1_read
	mov			c0,a0
	rcall		wire1_read
	mov			a2, a1
	mov			a1, c0
	PRINTF		LCD
.db	"temp=",FFRAC2+FSIGN,a,4,$42,"C  ",CR,0
	rjmp		temperature
	

