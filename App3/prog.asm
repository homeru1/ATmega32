.org $000 
	JMP RESET ; ��������� �� ������ ��������� 
.org INT0addr 
	JMP EXT_INT0 ; ��������� �� ���������� ���������� int0 
.org INT1addr 
	JMP EXT_INT1 ; ��������� �� ���������� ���������� int1

.def light = R25
.def gz = R17
.def od = R18
.def tmp = r19


RESET: ; ������ �������� ��������� 
	LDI R20, HIGH(RAMEND) ; ������� ������� ������ 
	OUT SPH, R20 ; ��������� ������� ����� � ����� ��� 
	LDI R20, LOW(RAMEND) ; ������� ������� ������ 
	OUT SPL, R20 ; ��������� ������� ����� � ����� ��� 
	SER R16 
	LDI od, 0b01010001 ;										num;light;int0, int1; x
	OUT DDRA, R16 ; ��������� PORTA �� ����� 
	OUT DDRB, R16 ; ��������� PORTB �� ����� 
	OUT DDRC, R16 ; ��������� PORTB �� ����� 
	LDI R16, 0b11110011
	OUT DDRD, od ; ��������� PORTB �� ����� 
	LDI light, 0
	LDI R16, 0x0F 
	OUT MCUCR, R16 ; ��������� ���������� int0 � int1 �� ������� 0/1 
	LDI R16, 0xC0 
	OUT GICR, R16 ; ���������� ���������� int0 � int1 
	OUT GIFR, R16 ; �������������� ������������ int0 � int1 ��� ��������� ���������� 
	RCALL EERead
	SEI ; ��������� ����������
	jmp mod1
DEBAG:
	ldi od, 1
	ldi r20, 0xaa
	ldi r21, 0xff
	eor r21, r20
	db:
	out porta, R20
	out portb, r21
	out portc, od
	inc od
	ldi R22, 184;x
	ldi R23, 75;y
	ldi R24, 235 ;z
	wait1:
		DEC R22
	BRNE wait1
	DEC R23
	BRNE wait1
	NOP
	INC R24
	BRNE wait1
	NOP
	jmp db 
MOD1:
	ANDI od, 0b00111111
	LDI R20, 0xFF
MOD11:
	LDI tmp, 0b11000000
	AND tmp, od
	cpi tmp, 0b10000000
	BRNE skip1
	SUBI od, 0b10000000
	skip1:
	LDI tmp, 0b01000000
	CALL CHOOSEGZ
	add od, tmp
	LDI tmp, 0xff
	OUT PORTD, od
	out PORTA, r20
	out PORTB, R20
	out PORTC, R20
	rcall WAIT
	cpi light, 1
	BREQ MOD2
	cpi light,2
	BREQ MOD3
	EOR R20, tmp
	jmp MOD11
reti

MOD2:
	ANDI od, 0b00111111
	LDI R20, 1
MOD21:
	LDI tmp, 0b11000000
	AND tmp, od
	cpi tmp, 0b10000000
	BRNE skip2
	SUBI od, 0b10000000
	skip2:
	LDI tmp, 0b01000000
	CALL CHOOSEGZ
	add od, tmp
	out PORTA, R20
	out PORTB, R20
	out PORTC, R20
	OUT PORTD, od
	rcall WAIT
	cpi light, 0
	BREQ MOD1
	cpi light,2
	BREQ MOD3
	cpi r20, 1
	breq skip22
	ldi r20, 1
	jmp MOD21
	skip22:
	ldi r20, 2
	jmp MOD21
reti

bridge:
	jmp mod1

MOD3:
	ANDI od, 0b00111111 ; r20 -> r21 -> r26 ->r20
	LDI R20, 0xff
	LDI R21, 0
	LDI R26, 0
MOD31:
	LDI tmp, 0b11000000
	AND tmp, od
	cpi tmp, 0b10000000
	BRNE skip3
	SUBI od, 0b10000000
	skip3:
	LDI tmp, 0b01000000
	CALL CHOOSEGZ
	add od, tmp
	LDI tmp, 0xff
	OUT PORTD, od
	out PORTA, R20
	out PORTB, R21
	out PORTC, R26
	rcall WAIT
	cpi light, 0
	BREQ bridge
	cpi light,1
	BREQ MOD2

	mov tmp,r20
	mov r20, r26 ;r20+
	mov r26, r21 ;r26+
	mov r21, tmp ;r21+
	jmp MOD31
reti

WAIT: 
	DEC R22
	BRNE WAIT
	DEC R23
	BRNE WAIT
	NOP
	INC R24
	BRNE WAIT
	NOP
	RETI

	
CHOOSEGZ: ;T = 0,25 sec, 1 sec, 2 sec
	CPI gz, 0
	BREQ m1
	CPI gz,1
	BREQ m2
	CPI gz, 2
	BREQ m3
	re:
	RETI 
m1: ;0.25 sec
	ldi R22, 184;x
	ldi R23, 99;y
	ldi R24, 247 ;z
	jmp re
m2: ;1 sec
	ldi R22, 203;x
	ldi R23, 199;y
	ldi R24, 220 ;z
	jmp re
m3: ; 2 sec
	ldi R22, 199;x
	ldi R23, 201;y
	ldi R24, 175 ;z
	jmp re

EXT_INT0: ; ���������� ���������� int0 ;change light
	PUSH R16 ; ���������� �������� �������� R16 � �����
	IN R16, SREG 
	PUSH R16 ; ���������� �������� �������� SREG � ����� 
	inc light
	cpi light, 3
	brne next1
	ldi light, 0
	next1:
	ANDI od, 0b11001111
	ROR light
	ROR light
	ROR light
	ROR light
	or od, light
	ROL light
	ROL light
	ROL light
	ROL light
	OUT PORTD, od
	POP R16 
	OUT SREG, R16 ; �������������� �������� SREG �� ����� 
	POP R16 ; �������������� �������� R16 �� ����� 
	RETI ; ������� �� ����������� ���������� � ���������� ����������

EXT_INT1: ; ���������� ���������� int1 Change X
	PUSH R16 ; ���������� �������� �������� R16 � ����� 
	IN R16, SREG 
	PUSH R16 ; ���������� �������� �������� SREG � ����� 
	inc gz
	cpi gz, 3
	brne next
	ldi gz, 0
	next:
	RCALL EEWrite
	ANDI od, 0b11111100
	or od, gz
	OUT PORTD, od
	POP R16 
	OUT SREG, R16 ; �������������� �������� SREG �� ����� 
	POP R16 ; �������������� �������� R16 �� ����� 
	RETI ; ������� �� ����������� ���������� � ���������� ����������

EEWrite:	
	SBIC EECR,EEWE		; ���� ���������� ������ � ������. �������� � �����
	RJMP EEWrite 		; �� ��� ��� ���� �� ��������� ���� EEWE
	CLI					; ��������� ����������.
	OUT EEARL,R16 		; ��������� ����� ������ ������
	OUT EEDR,gz 		; � ���� ������, ������� ��� ����� ���������
	SBI EECR,EEMWE		; ������� ��������������
	SBI EECR,EEWE		; ���������� ����
	SEI 				; ��������� ����������
	RETI

EERead:	
	SBIC EECR,EEWE		; ���� ���� ����� ��������� ������� ������.
	RJMP EERead	
	CLI				; ����� �������� � �����.
	OUT EEARL, R16		; ��������� ����� ������ ������
	SBI EECR,EERE 		; ���������� ��� ������
	IN gz, EEDR 		; �������� �� �������� ������ ���������
	RETI



