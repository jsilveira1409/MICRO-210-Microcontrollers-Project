reset:
	ldi		r16, 0xff
	out		DDRE,r16
main:
	sbi		PORTE,7
	cbi		PORTE,7
	sbi		PORTE,7
	nop
	nop
	cbi		PORTE,7
	nop
	nop
	nop
	nop
	rjmp	main