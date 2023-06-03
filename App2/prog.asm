.org $000 
	JMP START ; ��������� �� ������ ��������� 

.def runner = R16
.def inputd = R17
.def zero = R18
.def up = R19
.def tmp = R20
.def counter = R21 ;
.def mask = R22
.def outportc = R23
.def outportd = R24
.def inputc = R25
; X - r27 r26

Debag:
clr r27
ldi r26, 100
	LD tmp, X+; if not the last
	out PORTA, r24
	LD r17, X; if not the last
l:
out porta, 	tmp
out portb, r17
jmp l

START:
	LDI R20, HIGH(RAMEND) ; ������� ������� ������ 
	OUT SPH, R20 ; ��������� ������� ����� � ����� ��� 
	LDI R20, LOW(RAMEND) ; ������� ������� ������ 
	OUT SPL, R20 ; ��������� ������� ����� � ����� ��� 
	CALL INIT

Loop:
	IN inputc, PINC
	IN inputd, PIND
	AND inputc, mask
	CPSE inputc, zero
		call Switch
	CPSE inputd, zero
		call Addnum
	out portc,outportc
	call delay
	jmp Loop

overflow:
	ldi tmp, 0b10000000
	out portC, tmp
	call WaitforD
	ret

Addnum:
	cpi counter, 15 ; �������� �� ������������
	BREQ overflow
	call delay
	call OutNum
	call WaitForD ; �������� ������� ������ 
	ST X+, inputd
	call get
	brne skip
	skip:
	call XorMask
	ret

Switch:
	call WaitForC
	ldi tmp,0b00000011
	and tmp,inputc
	cp tmp, zero
		brne ChangeMode
	ldi tmp, 0b00001100
	and tmp, inputc
	CPSE tmp, zero
		call MoveMode
	ret

OverflowChange:
	ldi tmp, 0b10000000
	out portC, tmp
	call delay
	ret

ChangeMode:
	cpi tmp, 0b00000010
		BREQ SmallToBig
		ST X+, zero
		call IncAmount
		call delay
		out porta, zero
		call XorMask
		ret
	SmallToBig:
		cpi counter, 15 ; �������� �� ������������
			BREQ OverflowChange
		call Addnum
		ret

MoveMode:
	clr r27
	ldi tmp, 0b00001100
	and tmp, inputc
	cpi tmp, 0b00001000
		breq back ; �����
	cp runner, counter ;������
		breq end
	inc runner
	ldi r26, 98
	add r26,runner
	add r26,runner
	call ShowNew
	LD tmp, X+; if not the last
	out PORTA, tmp
	LD tmp, X; if not the last
	out PORTB, tmp
	jmp end
	back:
	cpi runner, 1
		BREQ end
	dec runner
	ldi r26, 98
	add r26,runner
	add r26,runner
	call ShowNew
	LD tmp, X+; if not the last
	out PORTA, tmp
	LD tmp, X; if not the last
	out PORTB, tmp
	end:
	;call MakeBack
	ldi r26, 98
	add r26, counter
	add r26,counter
	ret

MakeBack:
	ldi r26, 98
	add r26, counter
	add r26,counter
	LSL counter
	LSL counter
	LSL counter
	LSL counter
	andi outportc, 0b00000011
	OR outportc,runner
	LSR counter
	LSR counter
	LSR counter
	LSR counter

	ret

WaitForC:
	e:
	in tmp, pinc
	andi tmp,0b00001111
	and tmp,mask
	cp tmp, zero
	BRNE e
ret

ShowNew:
	LSL runner
	LSL runner
	LSL runner
	LSL runner
	andi outportc, 0b00000011
	OR outportc,runner
	LSR runner
	LSR runner
	LSR runner
	LSR runner
	;call debag
	ret

XorMask:

	ldi tmp, 0b00000011
	eor mask,tmp
	;out porta,outportc
	eor outportc,tmp
	;out portb,outportc
	mov tmp,mask
	ldi r28, 0xff
	eor tmp,r28
	out portc, zero
	out DDRC, tmp
	;out portc,outportc
	;call debag
	;call delay
	ret

WaitForD:
	w:
	in tmp, pind
	cp tmp, zero
	BRNE w
	;out portc,outportc
ret

delay:
	LDI R28, 1; z
	LDI R29, 200; y
	LDI R30, 3; x
	delay_sub:
		DEC  R28
		BRNE delay_sub
		DEC R29
		BRNE delay_sub
		DEC R30
		BRNE delay_sub
	ret

OutNum:
	call get
	IN inputd, PIND
	breq big
	out porta, inputd
	ret
	big:
	out portb, inputd
	call WaitForD
	out porta, zero
	out portb, zero
	call IncAmount
	;ldi tmp, 0b00010000
	;add outportc, tmp
	;inc counter
	ret

IncAmount:
	cpi counter, 15
		BREQ exit
	inc counter
	mov runner, counter
	LSL counter
	LSL counter
	LSL counter
	LSL counter
	andi outportc, 0b00000011
	OR outportc,counter
	LSR counter
	LSR counter
	LSR counter
	LSR counter
	;call debag
	exit:
	ret

Get:
	MOV tmp, mask
	andi tmp, 0b00000011
	cpi tmp, 0b00000001
	ret
INIT:
	SER R20
	CLR R21
	OUT DDRA, R20 ;�����
	OUT DDRB, R20 ;�����
	OUT PORTA, R21
	OUT PORTB, R21

	OUT DDRD, R21 ; ����

	LDI R20, 0b11110001 ; 1 ����� 0 ����
	OUT DDRC, R20

	CLR R20
	CLR R21

	;Memory
	;LDI R25, 15
	;CLR R27
	;LDI R26, 100
	;l:
	;ST X+, R20
	;CP R26, R25
	;BRNE l
	;CLR R25
	LDI R26, 100

	; variables
	CLR zero
	CLR tmp
	LDI counter, 1
	ldi up, 15
	ldi runner,1
	LDI mask, 0b00001110
	LDI outportc, 0b00010001
	OUT PORTA, zero
	OUT PORTB, zero
	OUT PORTC, outportc
	RET
