#include "stm32l476xx.h"
extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);

#define X0 0b0000000000000001
#define X1 0b0000000000000010
#define X2 0b0000000000000100
#define X3 0b0000000000001000
#define Y0 0b0000000001000000
#define Y1 0b0000000000100000
#define Y2 0b0000000000010000
#define Y3 0b0000000000001000

unsigned int x_pin[4] = {X0, X1, X2, X3};
unsigned int y_pin[4] = {Y0, Y1, Y2, Y3};
unsigned int table[4][4] = {{15, 7, 4, 1}, {0, 8, 5, 2}, {14, 9, 6, 3}, {13, 12, 11, 10}};

int display(int data, int num_digs)
{
	int i;
	for (i = 1; i <= num_digs; i++)
	{
		if(data >= 0){
			max7219_send(i , data % 10);
			data /= 10;
		}
		else max7219_send(i , 15);
	}
	for (i = num_digs ; i <= 8; i++)
		max7219_send(i, 15);
	return (data > 99999999) ? -1 : 0;
}
/* TODO: initial keypad gpio pin, X as output and Y as input */
void keypad_init()
{
	RCC->AHB2ENR   |= 0b110;

	GPIOC->MODER   &= 0b11111111111111111111111100000000;
	GPIOC->MODER   |= 0b00000000000000000000000001010101;
	GPIOC->PUPDR   &= 0b11111111111111111111111100000000;
	GPIOC->PUPDR   |= 0b00000000000000000000000001010101;
	GPIOC->OSPEEDR &= 0b11111111111111111111111100000000;
	GPIOC->OSPEEDR |= 0b00000000000000000000000001010101;
	GPIOC->ODR     |= 0b00000000000000000000000000001111;

	GPIOB->MODER   &= 0b11111111111111111100000000111111;
	GPIOB->PUPDR   &= 0b11111111111111111100000000111111;
	GPIOB->PUPDR   |= 0b00000000000000000010101010000000;
	GPIOB->OSPEEDR &= 0b11111111111111111111111100000000;
	GPIOB->OSPEEDR |= 0b00000000000000000000000001010101;
}

/* TODO: scan keypad value
return:
 >=0: key pressedvalue
 -1: no keypress
*/
int keypad_scan()
{
	int i, j;
	for(i=0; i<=3; i++){
		for(j=0; j<=3; j++){
			GPIOC->BRR = x_pin[j];
		}
		GPIOC->BSRR = x_pin[i];
		for(j=0; j<=3; j++){
			if(GPIOB->IDR & y_pin[j]) return table[i][j];
		}
	}
	return -1;
}

int main()
{
	GPIO_init();
	max7219_init();
	keypad_init();
	while (1)
	{
		int input = keypad_scan();
		if (input >= 10)
			display(input, 2);
		else if (input >= 0)
			display(input, 1);
		else
			display(input, 0);
	}
}
