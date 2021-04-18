; file	string2_s.asm		target ATmega128L-4MHz-STK300
; purpose lab extraction de sous-chaînes

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; === interrupt table ===
.org	0
	jmp	reset

.org	0x46
.include "string.asm"		; include string manipulation routines	
.include "uart.asm"		; include UART routines
.include "printf.asm"		; include formatted printing routines

reset:	
	LDSP	RAMEND		; Load Stack Pointer (SP)
	rcall	UART0_init
	rjmp	main

; === string constants in program memory ===	
cs1:	.db	"hello world. ",0
cs2:	.db	"how are you today?",0
cs3:	.db	0

; === string buffers in SRAM ===
.dseg
sbf1:	.byte	32
sbf2:	.byte	32
sbf3:	.byte	32
.cseg

main:	
	CXZ	strstrldi,sbf1,2*cs1	; load string constants into buffer SRAM
	CXZ	strstrldi,sbf2,2*cs2
	CXZ	strstrldi,sbf3,2*cs3

	ldi	a0,			; COMPLETE HERE
	ldi	b0,			; COMPLETE HERE

	CXY	strstr_left,sbf1,sbf2	; test str_left routine; comment others
	;CXZ	strstr_right,sbf1,sbf2	; uncomment to test
	;CXZ	strstr_mid,sbf1,sbf2	; uncomment to test
	
	rjmp main

strstr_left:
	ld	w,y+
					; COMPLETE HERE (3 lines)
	tst	w
	brne	strstr_left
	ret

strstr_right:
					; COMPLETE HERE (5 lines)
	dec	yh			; adjust in case of carry

	ld	w,y+
					; COMPLETE HERE (2 lines)

	brne	PC-3
	ret

strstr_mid:
					; COMPLETE HERE (6 lines)

	ld	w,y+
					; COMPLETE HERE (2 lines)
	st	x+,w
	tst	w
					; COMPLETE HERE (1 line)
	ret
