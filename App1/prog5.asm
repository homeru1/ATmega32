start:
	SER R21
	OUT DDRA,R21  ;Вывести данные из регистра R20 в выход DDRA
	OUT DDRB,R21  
	OUT DDRC,R21  
	OUT DDRD,R21  
B:
LDI R27, 21 ;15 00010101
LDI R28, 120 ; 78  01111000
LDI R24, 36 ; 24 00100100
LDI R25, 98 ; 62 01100010
LDI R26, 87; 57 01010111   x = 246257 00100100 01100010 01010111 = R24 R25 R26
LDI R29, 0b00100101
LDI R30, 0b00100101
LDI R31, 0b01101001 ; z = 252 569
LDI R16, 0 ;y = 1578
LDI R17, 0b00001111
LDI R18, 0b00001111
AND R17, R27 ; записываю младшие 4 разряда в другие регистры и двигаю основные на 4 право по итогу у меня будет 4 регистра 
AND R18, R28
LDI R19, 4
LDI R20, 0
right:
LSR R27
LSR R28
DEC R19
CP R19, R20
BRNE right ; y = R27 R17 R28 R18
ADD R27,R27 ; умножение каждого разряда на 4
ADD R27,R27
ADD R17,R17
ADD R17,R17
ADD R28,R28
ADD R28,R28
ADD R18,R18
ADD R18,R18
LDI R19, 0b00001010

mark4:
CP R18, R19 ; проверка на запрещенную комбинацию  (10 0b1010)
BRLO end4;Переход если меньше те в малдших битах нет запрещенной комбинации 
SUB R18,R19 ; вычет этой комбинации (10 0b1010)
INC R28 ; добавления 1 в следующий разряд
jmp mark4
end4:

mark3:
CP R28, R19
BRLO end3;Переход если меньше те в малдших битах нет запрещенной комбинации 
SUB R28,R19
INC R17
jmp mark3
end3:

mark2:
CP R17, R19
BRLO end2;Переход если меньше те в малдших битах нет запрещенной комбинации 
SUB R17,R19
INC R27
jmp mark2
end2:

mark1:
CP R27, R19
BRLO end1;Переход если меньше те в малдших битах нет запрещенной комбинации 
SUB R27,R19
jmp mark1
end1:

		  ;y =		R27 R17 R28 R18
P26: 	  ;x =  R24 R25	    R26
LDI R19, 0b00001010
LDI R20, 0b00001111
AND R20, R26
ADD R18, R20
mark5:
CP R18,R19
BRLO end5
SUB R18,R19
INC R28
jmp mark5
end5:

CP R28,R19
BRLO end6
SUB R28,R19
INC R17
end6:

LSR R26
LSR R26
LSR R26
LSR R26
ADD R28, R26
mark6:
CP R28,R19
BRLO end7
SUB R28,R19
INC R17
jmp mark6
end7:    ;   R28 R18 = R26 + R28 R18 вот тут вот
P25:

		  ;y =		R27 R17 R28 R18
		  ;x =  R24 R25	    R26
LDI R20, 0b00001111
AND R20, R25
ADD R17, R20
mark7:
CP R17,R19
BRLO end51
SUB R17,R19
INC R27
jmp mark7
end51:
CP R27,R19
BRLO end8
SUB R27,R19
INC R24
end8:

LSR R25
LSR R25
LSR R25
LSR R25
ADD R27, R25
mark8:
CP R27,R19
BRLO end9
SUB R27,R19
INC R24
jmp mark8
end9:    ;   R27 R17 = R25 + R27 R17 вот тут вот
LDI R20, 0b00001111
AND R20, R24
P24:
CP R20,R19
BRLO end10
SUB R24,R19
ADIW R24,0b00010000
end10:

LSL R28
LSL R28
LSL R28
LSL R28
LSL R27
LSL R27
LSL R27
LSL R27
ADD R28,R18
ADD R27,R17
MOV R25,R27
MOV R26,R28
LDI R27, 0b11100111


compare:
cp R24, R29
BRLO less ; переход если меньше
BREQ next; если равно
BRSH big; больше или равно
next:
cp R25, R30
BRLO less ; переход если меньше
BREQ next1; если равно
BRSH big; больше или равно
next1:
cp R26, R31
BRLO less ; переход если меньше
BREQ next2; если равно
BRSH big; больше или равно
next2:
LDI R27, 0
jmp OutP
big:
LDI R27, 0x01
jmp OutP
less:
LDI R27, 0xff
jmp OutP
OutP:
	OUT PORTA, R24
	OUT PORTB, R25
	OUT PORTC, R26
	OUT PORTD, R27
	rjmp start
