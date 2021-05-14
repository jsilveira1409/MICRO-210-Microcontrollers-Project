.include "lib/definitions.asm"
.include "libPerso/per_macro.asm"

reset:	
	LDSP	RAMEND		; load stack pointer SP
	OUTI	DDRE,0b00000010	; make Tx (PE1) an output
	sbi		PORTE,PE1	; set Tx to high	
	rjmp	main

.include "libPerso/per_uart.asm"

main:
	rcall		putc
	WAIT_MS		1000
	rjmp main