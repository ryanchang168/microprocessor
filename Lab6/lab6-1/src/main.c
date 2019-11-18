#include "stm32l476xx.h"
#include <stdio.h>
#include <stdlib.h>
extern void GPIO_init();
extern void delay_1s();
void SystemClock_Config(int clock_type){
    //TODO: Change the SYSCLK source and set the corresponding Prescaler value.
	//open HSI
	RCC->CR |= RCC_CR_HSION;
	while((RCC->CR & RCC_CR_HSIRDY) == 0);

	RCC->CFGR = 0x00000000;
	RCC->CR  &= 0xFEFFFFFF;
	while (RCC->CR & 0x02000000);

	RCC->PLLCFGR &= 0x00000001;
	if(clock_type == 0){

		RCC->PLLCFGR |= 0b011000000000000100001110001;
	}
	else if(clock_type == 1){

		RCC->PLLCFGR |= 0b001000000000000110000110001;
	}
	else if(clock_type == 2){

		RCC->PLLCFGR |= 0b001000000000001010000110001;
	}
	else if(clock_type == 3){

		RCC->PLLCFGR |= 0b001000000000010000000110001;
	}
	else{

		RCC->PLLCFGR |= 0b001000000000101000000110001;
	}

	RCC->CR |= RCC_CR_PLLON;
	while((RCC->CR & RCC_CR_PLLRDY) == 0);

	RCC->CFGR |= RCC_CFGR_SW_PLL;
	while ((RCC->CFGR & RCC_CFGR_SWS_PLL) != RCC_CFGR_SWS_PLL);
}

int user_press_button(){

	int k = 0;
	if((GPIOC -> IDR & 0b0010000000000000) == 0){
		k = 500;
	    while(k > 0){
	    	if((GPIOC -> IDR & 0b0010000000000000) == 0){
	    		k = 2;
	    	}
	    	else{
	    		k --;
	    	}
	    }
	    return 1;
	}
	return 0;
}
int main(){
	int clock_type = 0;
	GPIO_init();
	SystemClock_Config(clock_type);
	while(1){
		if (user_press_button())
		{
			//TODO: Update system clock rate
			clock_type ++;
			if(clock_type == 5){

				clock_type = 0;
			}
			SystemClock_Config(clock_type);
		}
		GPIOA->BSRR = (1<<5);
		delay_1s ();
		GPIOA->BRR = (1<<5);
		delay_1s ();
	}
}
