; file	uart1.asm   target ATmega128L-4MHz-STK300		
/*.include "lib/macros.asm"		; include macro definitions
.include "lib/definitions.asm"	; include register/constant definitions*/
.equ	baud	= 9600

/*reset:	
	LDSP	RAMEND		; load stack pointer SP
	OUTI	DDRE,0b00000010	; make Tx (PE1) an output
	sbi		PORTE,PE1	; set Tx to high	
	ldi		a0, 0x08
	rjmp	main*/


wait_bit:
	WAIT_C	(clock/baud)-18	; subtract overhead
	ret
/*wait_1bit5:
	WAIT_C	(3*clock/2/baud)-18
	ret*/
	
putc:	
	cbi		PORTE,PE1	; set start bit to 0
	rcall	wait_bit	; wait 1-bit period (start bit)
	sec					; set carry
loop:	ror	b0		; shift LSB into carry
//loop:	ror	a0		; shift LSB into carry
 	C2P	PORTE,PE1	; carry to port
 	rcall	wait_bit	; wait 1-bit period (data bit)
	clc			; clear carry
	tst	b0		; test c for zero
	//tst	a0		; test c for zero
	brne	loop		; loop back if not zero
	sbi	PORTE,PE1	; set stop bit to 1
	rcall	wait_bit	; wait 1-bit period (stop bit)
	ret	
	
/*getc:	
	WP1	PINE,PE0	; wait if pin Rx=1
	rcall	wait_1bit5	; wait 1.5-bit period (start bit)
	ldi	a0,0x80		; preload c
loop2:	
	P2C	PINE,PE0	; port to carry
	ror	a0		; shift carry into MSB
	rcall	wait_bit	; wait 1-bit period (data bit)
	brcc	loop2		; loop back if carry=0
	ret*/

/*main:
	ldi		a0, 0x00	
	rcall	putc		; put a character back to the terminal 
	WAIT_MS	1000
	rjmp	main*/
