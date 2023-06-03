start:
	SER R21
	OUT DDRA,R21 
	OUT DDRB,R21  
	OUT DDRC,R21  
	OUT DDRD,R21  
B: ;>>2
LDI R19, 0b10111001
LDI R20, 0b11100111  ;b
CP R28, R19
BRCS Negb
E:
LDI R24, 0
LDI R25, 0b00000100
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
Negb:
LDI R27, 255
EOR R19, R27
EOR R20, R27
ADD R20, R26
ADC R19, R24
ADD R19, R28
rjmp E

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
CP R28, R16 ;R28 - 1000 0000
BRCS Nega
G:
ADD R18, R25
ADC R17, R24 ; сложение с учётом переполнения при сложении младших байтов
ADC R16, R24
rjmp D
Nega:
LDI R27, 255
EOR R16, R27
EOR R17, R27
EOR R18, R27
ADD R18, R26 ;R26 - 1
ADC R17, R24 ;R24 - 0
ADC R16, R24
ADD R16, R28
rjmp G
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
CP R28, R21
BRCS Negc
H:
CP R23, R18 ;c
CPC R22, R17 ; сравнение с учётом результата предыдущего сравнения
CPC R21, R16 ; Z = 0, A!=C Z=1 A==c C=1 A>C  C = 0 A<C

BREQ Zero
BRCS ABig
OUT PORTD, R27
CP R28, R16 ;R28 - 1000 0000
BRCS Negaa
rjmp OutP
Negc:
LDI R27, 255
EOR R21, R27
EOR R22, R27
EOR R23, R27
ADD R23, R26 ;R26 - 1
ADC R22, R24 ;R24 - 0
ADC R21, R24
ADD R21, R28
rjmp H
ABig:
LDI R27,1
OUT PORTD, R27
CP R28, R16 ;R28 - 1000 0000
BRCS Negaa
rjmp OutP
Zero:
LDI R27, 0
OUT PORTD, R27
CP R28, R16 ;R28 - 1000 0000
BRCS Negaa
rjmp OutP
Negaa:
LDI R27, 255
EOR R16, R27
EOR R17, R27
EOR R18, R27
ADD R18, R26 ;R26 - 1
ADC R17, R24 ;R24 - 0
ADC R16, R24
ADD R16, R28
rjmp OutP
OutP:
	OUT PORTA, R16
	OUT PORTB, R17
	OUT PORTC, R18
	rjmp start 
