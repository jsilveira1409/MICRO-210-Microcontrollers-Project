; file	eeprom.asm   target ATmega128L-4MHz-STK300
; purpose library, internal EEPROM

eeprom_store:
; in:	xh:xl 	EEPROM address
;		b0	EEPROM data byte to store
; out:	->EEPROM

	sbic	EECR,EEWE	; skip if EEWE=0 (wait it EEWE=1)
	rjmp	PC-1		; jump back to previous address
	out		EEARL,xl		; load EEPROM address low	
	out		EEARH,xh		; load EEPROM address high
	out		EEDR,b0			; set EEPROM data register
	brie	eeprom_cli	; if I=1 then temporarily disable interrupts
	sbi		EECR,EEMWE		; set EEPROM Master Write Enable
	sbi		EECR,EEWE		; set EEPROM Write Enable
	ret

.macro	STEEPROM			;use a macro to speed up the storage process
; in:	xh:xl 	EEPROM address
;		b0	EEPROM data byte to store
; out:	->EEPROM

	sbic	EECR,EEWE	; skip if EEWE=0 (wait it EEWE=1)
	rjmp	PC-1		; jump back to previous address
	out		EEARL,xl		; load EEPROM address low	
	out		EEARH,xh		; load EEPROM address high
	out		EEDR,b0			; set EEPROM data register
	brie	eeprom_cli	; if I=1 then temporarily disable interrupts
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
; in:	xh:xl 	EEPROM address
; out:	a0	EEPROM data byte to load

	sbic	EECR,EEWE	; skip if EEWE=0 (wait it EEWE=1)
	rjmp	PC-1		; jump back to previous address
	out	EEARL,xl	
	out	EEARH,xh
	sbi	EECR,EERE		; set EEPROM Read Enable
	in	b0,EEDR			; read data register of EEPROM
	ret

record:
loop_bis:
	ld			b0, y+
	rcall		eeprom_store			; stockage du LSB?? de la temperature
	//STEEPROM							; macro to store in EEPROM ??
	adiw		xl,1					; incrementation de l'adresse de la eeprom (incrémentation de xl, xh -> word)
	cpi		yl, bufferLen
	brne	loop_bis

	cpi		xl, low(eepromLen)			;xl max
	brne	PC+5
	cpi		xh, high(eepromLen)			;xh max
	brne	PC+3
	//ldi		xl, low(EEPROM_START)		;remise à "zéro" des pointeurs EEPROM
	//ldi		xh, high(EEPROM_START)
	ldi		xl, low(0)					;remise à zéro des pointeurs EEPROM
	ldi		xh, high(0)

	ret

