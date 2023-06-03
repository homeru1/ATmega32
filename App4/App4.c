#include <avr/io.h>
#define F_CPU 8000000UL
#include <avr/interrupt.h>

int cur[4] = {0,0,0,0};
int overall[3] = {0,0,0}; // h.m.s
int mode = 1; // 0 - hh.mm 1- mm.ss
int settings = 0; // 0 - off 1 - on
int PosOfSet = 0; //
int seconds=0;
int put = 0;
int stage = 0;

void UptadeNumbers(){
	cur[0] = overall[0+mode]/10;
	cur[1] = overall[0+mode]%10;
	cur[2] = overall[1+mode]/10;
	cur[3] = overall[1+mode]%10;
}

void MinusDraw(int pos){
	switch (pos){
		case 3: //sec
		overall[1+mode]--;
		case 2: //sec
		overall[1+mode]-=10;
		break;
		case 1: // min
		overall[0+mode]--;
		break;
		case 0: // hour
		overall[0+mode]-=10;
		break;
		default: // seconds for draw
		overall[2]--;
		break;
	}
	if (overall[2]<0){ // seconds
		overall[2] = 59;
		overall[1]--;
	}
	if (overall[1]<0){
		overall[1] = 59;
		overall[0]--;
	}
	if (overall[0]<0)overall[0] = 23;
	UptadeNumbers();
	return;
}

void draw(int pos){
	switch (pos){
		case 3:
		overall[1+mode]++;
		case 2:
		overall[1+mode]+=10;
		break;
		case 1:
		overall[0+mode]++;
		break;
		case 0:
		overall[0+mode]+=10;
		break;
		default: // seconds for draw
		overall[2]++;
		break;
	}
	if (overall[2]>=60){ // seconds
		overall[2] = 0;
		overall[1]++;
	}
	if (overall[1]>=60){
		overall[1] = 0;
		overall[0]++;
	}
	if (overall[0]>=24)overall[0] = 0;
	UptadeNumbers();
	return;
}

ISR (TIMER1_COMPA_vect){
	cli();
	if (put){
		seconds++;
		if(seconds == 2)stage++;
		else if (seconds==4)stage++;
	}
	draw(4);
	sei();
}

ISR( INT0_vect ) // chagne mode
{
	if(settings == 0){
		settings = 1;
		mode = 0;
		UptadeNumbers();
		PosOfSet = 0;
		return;
	}
	PosOfSet++;
	if(PosOfSet==4&&mode==0){
		mode = 1;
		PosOfSet = 0;
		UptadeNumbers();
		}else if(PosOfSet==4){
		settings=0;
	}
	return;
}

ISR( INT1_vect ) // shift time
{
	if(settings == 1 )return;
	mode = mode? 0:1;
	UptadeNumbers();
	return;
	
}

void InitTimer(void){
	//cli();
	TCCR1A = 0;
	TCCR1B = (1<<WGM12) | (1<<CS12) | (1<<CS10);//0b0001101; //	cs12 = 1, cs10 = 1, wgm12 = 1 || clk/1024 and CTC			8m / 1024 = 7812,5 ==== 0,000128 s <<compare int>>
	TCNT1 = 0; //  0,000128 s * 256 = 0,032768 === 0,03  /// === 8,38848 ������ �� ���� ���
	OCR1A = 7812; // compare number
	TIMSK = 1<<OCIE1A;// 0b00010000; // OCIE1A = 1  allow compare interrupts
	sei(); // allow interrupts
}

void IntInit(void){
	MCUCR = 0x0F;
	GICR = 0xC0;
	GIFR = 0xC0;
}

void PortInit(void){
	DDRA = 0xFF;
	DDRC = 0xFF;
	DDRD = 0;
}

void StageOp(int operation){ // operation 1-plus 0-minus
	switch(stage){
		case 1:
		if(seconds>=2){
			if(TCNT1%1562 == 0){ // every 0,2 sec inc
				if(operation==1){
					draw(PosOfSet);
					} else {
					MinusDraw(PosOfSet);
				}
			}
		}
		case 2:
		if(seconds>=4){
			if(TCNT1%781 == 0){
				if(operation==1){
					draw(PosOfSet);
					} else {
					MinusDraw(PosOfSet);
				}
			}
		}
		return;
		default:
		return;
	}
}

void PutSide(void){ //pd0+ pd1-
	static int side = -1; // 0 - minus, 1 - plus -1 nothing
	int input = PIND & 0b00000011;
	if(input == 0){
		stage = 0;
		side = -1;
		put = 0;
		seconds=0;
		return;
	}
	if (side == -1){
		//stage = 0;
		put = 1;
		if (input == 0b00000001)side = 1; // if plus
		else if (input == 0b00000010)side = 0;
		if(side==1){
			draw(PosOfSet);
			} else {
			MinusDraw(PosOfSet);
		}
	}
	switch(side){
		case 1:
		StageOp(1);
		return;
		case 0:
		StageOp(0);
		return;
		default:
		return;
		
	}
}
int main(void)
{
	PortInit();
	IntInit();
	InitTimer();
	char seg[10] = {0xC0,0xf9,0xa4,0xb0,0x99,0x92,0x82,0xf8,0x80,0x90}; //0 1 2 4 5 6 9
	char pos[4] = {0x01,0x02,0x04,0x08};
	int endge = 3906;
	while (1)
	{
		if(settings==0){
			for(int i = 0; i<4;i++){
				PORTA = pos[i];
				PORTC = seg[cur[i]];
				for(int i = 0; i<50;i++)__asm__ __volatile__ ("nop");
			}
			}else {
			for(int i = 0; i<4;i++){
				if(i!=PosOfSet || TCNT1 > endge){
					PORTA = pos[i];
					PORTC = seg[cur[i]];
					for(int i = 0; i<50;i++)__asm__ __volatile__ ("nop");
				}
			}
			PutSide();
		}
	}
}
