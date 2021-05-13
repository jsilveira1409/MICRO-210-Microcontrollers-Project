; file	uart1.asm   target ATmega128L-4MHz-STK300		
; purpose RS232 UART emulation (internal UART modules not used)
; module: FTDI cable, I/O port: UART
.include "libPerso/per_macro.asm"		; include macro definitions
.include "lib/definitions.asm"	; include register/constant definitions

; === definitions ===
;.equ	baud	= 19200		; Baud rate of UART
.equ	baud	= 9600
;.def	c 	= r20		; character

reset:	
	LDSP	RAMEND		; load stack pointer SP
	ldi		a0, 0x01
	OUTI	DDRD,0b00000010	; make Tx (PE1) an output
	sbi	PORTD,PD3	; set Tx to high	
	rjmp	main

; === subroutines ===	
wait_bit:
	WAIT_C	(clock/baud)-18	; subtract overhead
	ret
wait_1bit5:
	WAIT_C	(3*clock/2/baud)-18
	ret
	
putc:
	cbi	PORTD,PD3	; set start bit to 0
	rcall	wait_bit	; wait 1-bit period (start bit)
	sec			; set carry
loop:	
	ror	a0		; shift LSB into carry
 	C2P	PORTD,PD3	; carry to port
 	rcall	wait_bit	; wait 1-bit period (data bit)
	clc			; clear carry
	tst	a0		; test c for zero
	brne	loop		; loop back if not zero
	sbi	PORTD,PD1	; set stop bit to 1
	rcall	wait_bit	; wait 1-bit period (stop bit)
	ret	
	
; === main program ===
main:
	rcall	putc		; put a character back to the terminal 
	WAIT_MS		300
	rjmp	main
