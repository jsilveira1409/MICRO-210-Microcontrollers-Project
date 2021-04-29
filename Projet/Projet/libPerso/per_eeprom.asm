; file	eeprom.asm   target ATmega128L-4MHz-STK300
; purpose library, internal EEPROM

eeprom_store:
; in:	xh:xl 	EEPROM address
;	a0	EEPROM data byte to store

	sbic	EECR,EEWE	; skip if EEWE=0 (wait it EEWE=1)
	rjmp	PC-1		; jump back to previous address
	out		EEARL,xl		; load EEPROM address low	
	out		EEARH,xh		; load EEPROM address high
	out		EEDR,b0			; set EEPROM data register
	brie	eeprom_cli	; if I=1 then temporarily disable interrupts
	sbi		EECR,EEMWE		; set EEPROM Master Write Enable
	sbi		EECR,EEWE		; set EEPROM Write Enable
	ret	
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
	mov			w,b0					; garder la valeur b0 avant de la perdre dans eeprom_store
	mov			b0, b1					; transfer pour que eeprom_store prenne le MSB?? de la temperature
	//mov			xl,	yl
	rcall		eeprom_store			; stockage du LSB?? de la temperature
	adiw		xl,1					; incrementation de l'adresse de la eeprom
	mov			b0, w
	rcall		eeprom_store			; stockage du MSB de la temperature
	adiw		xl,1					; incrementation de l'adresse de la eeprom
	ret

