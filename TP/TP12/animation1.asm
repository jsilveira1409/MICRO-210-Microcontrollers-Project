; file	animation1.asm   target ATmega128L-4MHz-STK300	
; pupose display a button-controlled character scrolling animatio
.include "macros.asm"
.include "definitions.asm"

reset:
	LDSP	RAMEND
	rcall	LCD_init
	jmp	main
.include "lcd.asm"
.include "printf.asm"

str0:
.db	0x03,0
arrow0:
.db	0b00000100,0b00001110,0b00011111,0b00000100,0b00000100,0b00000100,0b00000100,0b00000000

main:	
	ldi	r22,8
	
   prog0:
    	in	r25,PIND
	com	r25
	tst	r25
	breq	_dnm
	
	rcall	LCD_home
	PRINTF	LCD
.db	"  Arrowhead down ",0
	rcall	LCD_drCGRAMdnw		;load animation arrowhead downwards
	rjmp	_gon
		
  _dnm:	rcall	LCD_home
	PRINTF	LCD
.db	"  Arrowhead up  ",0,0
	rcall	LCD_drCGRAMupw	;load animation arrowhead upwards
		
	
 _gon:	ldi	r16,str0	;load text, including animated character
	ldi	zl, low(2*str0)	;load pointer to string
	ldi	zh,high(2*str0)
	rcall	LCD_putstring	;display string
 	WAIT_MS	200		;wait
	dec	r22		;decrement offset
	_BRNE	prog0		;animated sequence steps not completed
	rjmp	main		;infinite loop

LCD_putstring:
; in	z 
	lpm			;load program memory into r0
	tst	r0		;test for end
	breq	done
	mov	a0,r0		;load argument
	rcall	LCD_putc
	adiw	zl,1
	rjmp	LCD_putstring
done:	ret	

LCD_drCGRAMupw: 
	lds	u, LCD_IR		;read IR to check busy flag  (bit7)
	JB1	u,7,LCD_drCGRAMupw	;Jump if Bit=1 (still busy)
	ldi	r16, 0b01011000		;2MSBs:write into CGRAM(instruction),
					;6LSBs:address in CGRAM and in charact.
	sts	LCD_IR, r16		;store w in IR
	ldi	zl,low(2*arrow0)+8
	ldi	zh,high(2*arrow0)
	mov	r23,zl			;upper address limit
	dec	r23
	mov	r24,r23			;store upper limit of character in memory
	ldi	r18,8			;load size of caracter in table arrow0
	sub	zl,r22			;subtract current value of moving offset

   loop01: 
  	lds	u, LCD_IR		;read IR to check busy flag  (bit7)
	JB1	u,7,loop01		;Jump if Bit=1 (still busy)
	lpm				;load from z into r0
	mov	r16,r0
	adiw	zl,1
	mov	r23,r24			;garantee z remains in character memory
	sub	r23,zl			;zone, if not then restart at the begining
	brge	_reg1			;subtract current value of moving offset
	subi	zl,8
	
  _reg1:sts	LCD_DR, r16		;load definition of one charecter line 
	dec	r18
	brne	loop01
	rcall	LCD_home		;leaving CGRAM
	ret

LCD_drCGRAMdnw: 
	lds	u, LCD_IR	
	JB1	u,7,LCD_drCGRAMdnw	
	ldi	r16, 	
	sts		
	ldi	zl,low(2*arrow0)+8
	ldi	zh,high(2*arrow0)
	mov	r23,zl		
		r23,9
	mov	r24,r23
	ldi	r18,8		
	sub	zl,r22		

   loop02: 
  	lds	u, LCD_IR	
	JB1	u,7,loop02	
	lpm
	mov	r16,r0
		zl
	mov	r23,r24
	sub	r23,
	 	_reg2
	 	zl,8
	
  _reg2:sts	LCD_DR, r16
	dec	r18
	brne	
	rcall	LCD_home	
	ret