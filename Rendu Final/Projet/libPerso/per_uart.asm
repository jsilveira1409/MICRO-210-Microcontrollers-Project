.equ	baud	= 9600

wait_bit:
	WAIT_C	(clock/baud)-18	; subtract overhead
	ret

putc:	
	cbi		PORTE,PE1	; set start bit to 0
	rcall	wait_bit	; wait 1-bit period (start bit)
	sec					; set carry
loop:	
	ror		d0			; shift LSB into carry
 	C2P		PORTE,PE1	; carry to port
 	rcall	wait_bit	; wait 1-bit period (data bit)
	clc					; clear carry
	tst		d0			; test c for zero
	brne	loop		; loop back if not zero
	sbi		PORTE,PE1	; set stop bit to 1
	rcall	wait_bit	; wait 1-bit period (stop bit)
	ret	
