#include "stm32l476xx.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define TIME_SEC 2.34

extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);
extern void max7219_init();
unsigned int millisecond;
unsigned int second;
unsigned int get_current_counter_value;
void Timer_init( TIM_TypeDef *timer){
    RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
    TIM2->CR1 &= 0x0000;
    TIM2->PSC = 39999U;
    TIM2->ARR = 99U;
    TIM2->EGR = 0x0001;
}
void Timer_start(TIM_TypeDef *timer){
    TIM2->CR1 |= TIM_CR1_CEN;
    TIM2->SR &= ~(TIM_SR_UIF);
}
void timer_display(int data,int len){
    unsigned int tmp_ms = millisecond, tmp_s = second;
    if( data == 0 && len == 3 ){
        for(int i = 1;i <= len;i++){
            if(i == 3)
                max7219_send(i,(data % 10) | (0x80));
            else
                max7219_send(i,data % 10);
            data /= 10;
        }
    }
    else if(data == 87 && len ==87) //stop the timer!!
    {
        tmp_s = (int) TIME_SEC;
        tmp_ms = TIME_SEC*100-tmp_s*100;
        for(int i = 1;i <= len;i++){
            if(i<3){
                max7219_send(i,tmp_ms % 10);
                tmp_ms /= 10;
            }
            else if(i == 3){
                max7219_send(i,(tmp_s % 10) | (0x80)); //the float digit bit has to be turned on
                tmp_s /= 10;
                if(tmp_s == 0)
                    break;
            }
            else {
                max7219_send(i,tmp_s % 10);
                tmp_s /= 10;
                if(tmp_s == 0)
                    break;

            }

        }
    }
    else
    {
        for(int i = 1;i <= len;i++)
        {
            if(i<3)
            {
                max7219_send(i,tmp_ms % 10);
                tmp_ms /= 10;
            }
            else if(i == 3)
            {
                max7219_send(i,(tmp_s % 10) | (0x80)); //the float digit bit has to be turned on
                tmp_s /= 10;
                if(tmp_s == 0)
                {
                    break;
                }
            }
            else
            {
                max7219_send(i,tmp_s % 10);
                tmp_s /= 10;
                if(tmp_s == 0)
                {
                    break;
                }
            }

        }
    }


}
int display_clr()
{
    for(int i = 1;i <= 8;i++)
    {
        max7219_send(i,0xF);
    }
    return 0;
}
int main()
{
 	GPIO_init();
	max7219_init();
	Timer_init(TIM2);
	Timer_start(TIM2);
    display_clr();
    millisecond = 0;
    get_current_counter_value = 0;
    int TARGET_SEC = TIME_SEC / 1;
    int TARGET_MSEC = TIME_SEC * 100 - ( TARGET_SEC * 100 );
	while(1)
	{
		//todo: Polling the timer count and do lab requirements
        if(TIME_SEC < 0.01 || TIME_SEC > 10000.0)
        {
            timer_display(0,3); //3 bit float number, 0.00
        }
        get_current_counter_value = TIM2->CNT; //get the current counter value since it symbolizes the millisecond
        millisecond = get_current_counter_value;
        if( second == TARGET_SEC && TIM2->CNT == TARGET_MSEC)
        {
            timer_display(87,87);
            while(1); //halt here
        }
        get_current_counter_value = TIM2->CNT; //get the current counter value since it symbolizes the millisecond
        millisecond = get_current_counter_value;
        timer_display(6,8);
        if(TIM2->SR & 0x0001) //one second is reached
        {
            second+=1;
            TIM2->SR &= ~(TIM_SR_UIF); //reset again for next counter event
        }
        get_current_counter_value = TIM2->CNT; //get the current counter value since it symbolizes the millisecond
        millisecond = get_current_counter_value;
        timer_display(6,8);
	}
    return 0;
}
