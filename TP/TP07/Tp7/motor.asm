; file	motor.asm   target ATmega128L-4MHz-STK300
; purpose stepper motor control
; module: M1, output port: PORTA
.include "macros.asm"
.include "definitions.asm"

.equ	t1 	= 1000			; waiting period in micro-seconds
.equ	port_mot= PORTA		; port to which motor is connected

.macro	MOTOR
	ldi	w,@0
	out	port_mot,w			; output motor pin pattern
	rcall	wait			; wait period
.endmacro		
	
reset:	LDSP	RAMEND		; load stack pointer SP
	OUTI	DDRA,0x0f		; make motor port output
loop:	
	MOTOR	0b			; output motor patterns COMPLETE HERE
	MOTOR	0b	
	MOTOR	0b
	MOTOR	0b
	MOTOR	0b
	MOTOR	0b
	rjmp	loop
	
wait:	WAIT_US	t1			; wait routine
	ret