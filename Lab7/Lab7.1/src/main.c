#include "stm32l476xx.h"

void GPIO_init() {
	RCC->AHB2ENR |=0b1;

	GPIOA->MODER &= 0xFFFFFFFC;
	GPIOA->MODER |= 0b1;
	GPIOA->PUPDR &= 0xFFFFFFFC;
	GPIOA->PUPDR |= 0b1;
	GPIOA->ODR |= 0b1;

}
void SystemClock_Config() {
	//turn on HSI16
	RCC->CR |= 0x100;
	RCC->CFGR |= 1;
	//for prescaler 2
	RCC->CFGR |= 0x80;

	//external clock source
	// tickint
	SysTick->CTRL |= 2;
	// 3 second
	SysTick->LOAD = 3 * 1000000;
	SysTick->VAL = 0;
	//enable
	SysTick->CTRL |= 1;
}
void SysTick_Handler(void) {
	GPIOA->ODR ^= 1;
}
int main(){
	GPIO_init();
	SystemClock_Config();

	while (1);

}
