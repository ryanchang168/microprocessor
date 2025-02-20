#include "stm32l476xx.h"
#include "utils.h"

unsigned int x_pin[4] = {X0, X1, X2, X3};
unsigned int y_pin[4] = {Y0, Y1, Y2, Y3};
unsigned int table[4][4] = {{15, 7, 4, 1}, {0, 8, 5, 2}, {14, 9, 6, 3}, {13, 12, 11, 10}};
int scan_state = 0, key_value = 0, prev = 0, check_dup = 0;

void SysTick_UserConfig();
void SysTick_Handler();
void EXTI4_IRQHandler();
void EXTI9_5_IRQHandler();
void scan();

void led_init(){
	GPIOA->MODER&=0xFFFFFFFC;
	GPIOA->MODER|=0x1;
	GPIOA->PUPDR&=0xFFFFFFFC;
	GPIOA->PUPDR|=0x1;
	GPIOA->ODR&=0xFFFFFFFE;
}

int main()
{
	SysTick_UserConfig();
	gpio_init();
	led_init();
	keypad_init();
	exti_init();
	while (1)
	{
		prev = YPORT->IDR;
	}
}

void SysTick_UserConfig()
{
	// 第一個 enable, 第二個 是否數到零發生意外 Tickint, 第三個選擇時鐘 clksource
	SysTick->CTRL |= 0x00000004;
	SysTick->LOAD = 400000; // 0.1 second
	SysTick->VAL = 0;
	SysTick->CTRL |= 0x00000003;
}

void SysTick_Handler()
{
	EXTI->IMR1 = 0;
	scan_state = (scan_state + 1) % 4;
	int i;
	for(i=0; i<4; i++){
		XPORT->BRR = x_pin[i];
		if(i == scan_state) XPORT->BSRR = x_pin[i];
	}
	// IMR 啟動中斷
	EXTI->IMR1 |= EXTI_IMR1_IM4 | EXTI_IMR1_IM5 | EXTI_IMR1_IM6 | EXTI_IMR1_IM7;
}

void EXTI4_IRQHandler()
{
	uint32_t *ptr;
	ptr = (uint32_t *) NVIC_ICPR;
	ptr[0] = 0x00000400;
	scan();
	EXTI->PR1 |= EXTI_PR1_PIF4;
}

void EXTI9_5_IRQHandler()
{
	uint32_t *ptr;
	ptr = (uint32_t *) NVIC_ICPR;
	ptr[0] = 0x00800000;
	scan();
	// PR 是做清除動作
	EXTI->PR1 |= EXTI_PR1_PIF5 | EXTI_PR1_PIF6 | EXTI_PR1_PIF7;
}

void scan(){
	int now = YPORT->IDR, i, j;
	for(i=0; i<4; i++)
		for(j=0; j<4; j++)
			if((prev & y_pin[j]) && !(now & y_pin[j]) && scan_state == i) key_value = table[i][j];

	for(int i=0;i<2*key_value;i++){
		if((GPIOA->ODR&1)==1)
			GPIOA->ODR&=0xFFFFFFFE;
		else
			GPIOA->ODR|=0b1;
		delay_1s();
	}
	GPIOA->ODR&=0xFFFFFFFE;
}
