;	

; ==========================macros =====================================
	
; =======================subroutine=========================
temperature:		;PORT B
		
		rcall		wire1_reset							;reset pulse
		CA			wire1_write, skipROM				;skip ROM identification
		CA			wire1_write, convertT				;initaite temperature convertion
		WAIT_MS		10					
		rcall		wire1_reset
		CA			wire1_write, skipROM
		CA			wire1_write, readScratchpad
		rcall		wire1_read							;read temperature LSB
		;mov			b0,a0
		mov			b2,a0
		;mov			b2,b0
		rcall		wire1_read							;read temperature MSB
		mov			b1, a0
		;mov			b1, b0
		mov			b0, b2
		ret

light:										;PORT F, pin 0	
		;clr			r23						; stocke l'info dans a1-a0
		sbi			ADCSR,ADSC
		WP1			ADCSR,ADSC
		in			b0,ADCL
		in			b1,ADCH
		WAIT_MS		200
		ret

humidity:										;PORT F, pin 1
		;clr			r23						; stocke l'info dans a1-a0
		sbi			ADCSR,ADSC
		WP1			ADCSR,ADSC
		in			b0,ADCL
		in			b1,ADCH
		WAIT_MS		200
		ret
