;	PORT B

; ==========================macros =====================================
	
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
	ret