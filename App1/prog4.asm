start:
	SER R21
	OUT DDRA,R21
	OUT DDRB,R21  
	OUT DDRC,R21  
	OUT DDRD,R21  
B: ;>>2
LDI R19, 198
LDI R20, 25  ;b
LDI R24, 0
LDI R25, 4
LDI R26, 1
LDI R28, 128
LDI R27, 128 ; 1000 000
AND R27, R19 ; Получение бита знака
CP R27, R24 ; 1 - 0 Z=0
BREQ positive
LSR R19
ROR R20 ; сдвиг с учётом младшего разряда старшего байта
OR R19, R28
LSR R19
ROR R20 ; сдвиг с учётом младшего разряда старшего байта
OR R19, R28
rjmp A
positive:
LSR R19
ROR R20 ; сдвиг с учётом младшего разряда старшего байта
LSR R19
ROR R20 ; сдвиг с учётом младшего разряда старшего байта
rjmp A
A: ;+4
LDI R16, 123
LDI R17, 6 
LDI R18, 249 ;a

ADD R18, R25
ADC R17, R24 ; сложение с учётом переполнения при сложении младших байтов
ADC R16, R24

D: ;A-B

SUB R20, R26
SBC R19, R24
LDI R27, 255
EOR R20, R27    ; A: R16 R17 R18
EOR R19, R27    ; B: 000 R19 R20

ADD R18, R20
ADC R17, R19 ; сложение с учётом переполнения при сложении младших байтов
ADC R16, R24

C:   ; C: R21:R22:R23 A: R16:R17:R18
LDI R21, 123
LDI R22, 6 
LDI R23, 249
CP R23, R18 ;c
CPC R22, R17 ; сравнение с учётом результата предыдущего сравнения
CPC R21, R16 ; Z = 0, A!=C Z=1 A==c C=1 A>C  C = 0 A<C

BREQ Zero
BRCS ABig
OUT PORTD, R27
rjmp OutP
ABig:
LDI R27,1
OUT PORTD, R27
rjmp OutP
Zero:
LDI R27, 0
OUT PORTD, R27
rjmp OutP

OutP:
	OUT PORTA, R16
	OUT PORTB, R17
	OUT PORTC, R18
	rjmp start
