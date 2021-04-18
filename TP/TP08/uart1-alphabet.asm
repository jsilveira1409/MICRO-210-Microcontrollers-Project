; file	uart1-alphabet.asm   target ATmega128L-4MHz-STK300		
; purpose display alphabet to UART terminal, UART emulation (internal UART modules not used)
; module: FTDI cable, I/O port: UART
.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; === definitions ===
;.equ	baud	= 19200		; Baud rate of UART
.equ	baud	= 9600
.def	ctx 	= r20		; character

reset:	LDSP	RAMEND		; load stack pointer SP
	OUTI	DDRE,0b00000010	; make Tx (PE1) an output
	sbi	PORTE,PE1	; set Tx to high	
	rjmp	main

; === subroutines ===	
wait_bit:
	WAIT_C	(clock/baud)-18	; subtract overhead
	ret
wait_1bit5:
	WAIT_C	(3*clock/2/baud)-18
	ret
	
putc:	cbi	PORTE,PE1	; set start bit to 0
	rcall	wait_bit	; wait 1-bit period (start bit)
	sec			; set carry
loop:	ror	ctx		; shift LSB into carry
 	C2P	PORTE,PE1	; carry to port
 	rcall	wait_bit	; wait 1-bit period (data bit)
	clc			; clear carry
	tst	ctx		; test c for zero
	brne	loop		; loop back if not zero
	sbi	PORTE,PE1	; set stop bit to 1
	rcall	wait_bit	; wait 1-bit period (stop bit)
	ret	
	
getc:	WP1	PINE,PE0	; wait if pin Rx=1
	rcall	wait_1bit5	; wait 1.5-bit period (start bit)
	ldi	ctx,0x80		; preload c
loop2:	P2C	PINE,PE0	; port to carry
	ror	ctx		; shift carry into MSB
	rcall	wait_bit	; wait 1-bit period (data bit)
	brcc	loop2		; loop back if carry=0
	ret

; === main program ===
main:	ldi	  ,    	; initialize char to 'a'
next:	mov	  , r23
	rcall	putc		; put character c
	WAIT_MS	100		; wait 100 ms
	 	r23		; increment c
		r23, 'z' 	; compare c with 'z'
	brne	  		; branch to next if not equal
	rjmp	main
