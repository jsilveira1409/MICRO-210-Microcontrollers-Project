eeprom_store:
; in:	xh:xl 	EEPROM address
;		b0	EEPROM data byte to store
; out:	->EEPROM

	sbic	EECR,EEWE		; skip if EEWE=0 (wait it EEWE=1)
	rjmp	PC-1			; jump back to previous address
	out		EEARL,xl		; load EEPROM address low	
	out		EEARH,xh		; load EEPROM address high
	out		EEDR,b0			; set EEPROM data register
	brie	eeprom_cli		; if I=1 then temporarily disable interrupts
	sbi		EECR,EEMWE		; set EEPROM Master Write Enable
	sbi		EECR,EEWE		; set EEPROM Write Enable
	ret

.macro	STEEPROM
; in:	xh:xl 	EEPROM address
;		b0	EEPROM data byte to store
; out:	->EEPROM

	sbic	EECR,EEWE		; skip if EEWE=0 (wait it EEWE=1)
	rjmp	PC-1			; jump back to previous address
	out		EEARL,xl		; load EEPROM address low	
	out		EEARH,xh		; load EEPROM address high
	out		EEDR,b0			; set EEPROM data register
	brie	eeprom_cli		; if I=1 then temporarily disable interrupts
	sbi		EECR,EEMWE		; set EEPROM Master Write Enable
	sbi		EECR,EEWE		; set EEPROM Write Enable
	.endmacro

eeprom_cli:
	cli					; disable interrupts
	sbi	EECR,EEMWE		; set EEPROM Master Write Enable
	sbi	EECR,EEWE		; set EEPROM Write Enable
	sei					; enable interrupts
	ret

eeprom_load:
;in:	xh:xl 	EEPROM address
	sbic	EECR,EEWE	; skip if EEWE=0 (wait it EEWE=1)
	rjmp	PC-1		; jump back to previous address
	out		EEARL,xl	
	out		EEARH,xh
	sbi		EECR,EERE	; set EEPROM Read Enable
	in		b0,EEDR		; read data register of EEPROM
	ret

record:
	ldi			yl, 0
loop_bis:								
	ld			b0, y+
	rcall		eeprom_store			
	adiw		xl,1						; incrementation de l'adresse de la eeprom (-> word)
	cpi			yl, bufferLen
	brne		loop_bis				

	cpi			xl, low(eepromLen)			;xl max
	brne		PC+5
	cpi			xh, high(eepromLen)			;xh max
	brne		PC+3
	ldi			xl, low(0)					;remise à zéro des pointeurs EEPROM
	ldi			xh, high(0)

	ldi			yl, 0

	ret

