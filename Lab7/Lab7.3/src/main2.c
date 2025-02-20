/*#include "stm32l476xx.h"
#include "utils.h"

#define DO 261.6
#define RE 293.7
#define MI 329.6
#define FA 349.2
#define SO 392.0
#define LA 440.0
#define SI 493.9
#define HI_DO 523.3

float freq = -1;
int curr = -2, prev = -3, check = -4;
int duty_cycle = 50;
int keypad_disable = 0, last = -1, target = -1;

void timer_init()
{
	RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
	// enable TIM2 timer clock
	GPIOB->AFR[0] |= GPIO_AFRL_AFSEL3_0;
	// select AF1 for PB3 (PB3 is TIM2_CH2)
	TIM2->CR1 |= TIM_CR1_DIR;
	// counter used as downcounter
	TIM2->CR1 |= TIM_CR1_ARPE;
	// enable auto-reload preload (buffer TIM2_ARR)
	TIM2->ARR = (uint32_t) 100;
	// auto-reload prescaler value
	TIM2->CCMR1 &= 0xFFFFFCFF;
	// select compare 2 (channel 2 is configured as output)
	TIM2->CCMR1 |= (TIM_CCMR1_OC2M_2 | TIM_CCMR1_OC2M_1);
	// set output compare 2 mode to PWM mode 1
	TIM2->CCMR1 |= TIM_CCMR1_OC2PE;
	// enable output compare 2 preload register on TIM2_CCR2
	TIM2->CCER |= TIM_CCER_CC2E;
	// enable compare 2 output
	TIM2->EGR = TIM_EGR_UG;
	// re-initialize the counter and generates an update of the registers
}

void timer_config()
{
	TIM2->PSC = (uint32_t) (4000000 / freq / 100);
	// prescaler value
	TIM2->CCR2 = duty_cycle;
	// compare 2 preload value
}

void keypad_ctrl(int timesup)
{
	while (1)
	{
		if(curr != -1){
			freq = DO;
			timer_config();
			TIM2->CR1 |= TIM_CR1_CEN;
		}
		if(timesup && !(GPIOC->IDR & 0b10000000000000)){
			TIM2->CR1 &= ~TIM_CR1_CEN;
			freq = -1;
			curr = -1;
			return;
		}
	}
}
void SystemClock_Config() {
	//turn on HSI16
	RCC->CR|=0x100;
	RCC->CFGR |= 1;
	//for prescaler 2
	RCC->CFGR |= 0x80;

	//external clock source
	// tickint
	SysTick->CTRL |= 2;
}
void SysTick_Handler() {
	SysTick->CTRL &= 0xfffffffe;
	while (1)
	{
		if(curr != -10){
			freq = DO;
			TIM2->PSC = (uint32_t) (4000000 / freq / 100);
			// prescaler value
			TIM2->CCR2 = duty_cycle;
			// compare 2 preload value
			TIM2->CR1 |= TIM_CR1_CEN;
		}
		if(!(GPIOC->IDR & 0b10000000000000)){
			TIM2->CR1 &= ~TIM_CR1_CEN;
			freq = -1;
			curr = -1;
			keypad_disable = 0;
			break;
		}
	}
}
int main()
{
	fpu_enable();
	gpio_init();
	timer_init();
	keypad_init();
	SystemClock_Config();

	while(1){
		while(1){
			curr = keypad_scan();
			if(curr < SysTick->VAL && curr != last && curr != -1 && keypad_disable){
				last = curr;
				int tmp = SysTick->VAL;
				SysTick->LOAD = tmp - curr * 1000000;
				SysTick->VAL = 0;

			}
			else if(curr == -1 || keypad_disable){
				last = curr;
				continue;
			}
			else break;
		}
		keypad_disable = 1;
		// 3 second
		if(curr)SysTick->LOAD = curr * 1000000;
		else SysTick->LOAD = 10;
		target = curr;
		last = curr;
		SysTick->VAL = 0;
		//enable
		SysTick->CTRL |= 1;
	}
}*/
