start:
	SER R20
	OUT DDRA,R20  ;Вывести данные из регистра R20 в выход DDRA
	OUT DDRB,R20  
	OUT DDRC,R20  
	OUT DDRD,R20  
inis:
	LDI R16, 1
	LDI R17, 1
	LDI R18, 1;a
	LDI R19, 2
	LDI R20, 180; b
	LDI R21, 1
	LDI R22, 2
	LDI R23, 1; c
	LDI R24, 4
	LDI R25, 0
	LDI R26, 1
	LDI R27, 255
Log:
	LSR R19
	ROR R20
	ADD R18, R24
	ADC R17, R25
	ADC R16, R25
	SUB R18, R20
	SBC R17, R19
	SBC R16, R25
	CP R21, R16
	BREQ Action1
	BRCS One
	OUT PORTD, R27
	rjmp OutP
Action1:
	CP R22, R17
	BREQ Action2
	BRCS One
	OUT PORTD, R27
	rjmp OutP
Action2:
	CP R23, R18
	BREQ Zer
	BRCS One
	OUT PORTD, R27
	rjmp OutP
Zer:
	OUT PORTD, R25
	rjmp OutP
One:
	OUT PORTD, R26
	rjmp OutP
	
OutP:
	OUT PORTA, R16
	OUT PORTB, R17
	OUT PORTC, R18

	rjmp start
