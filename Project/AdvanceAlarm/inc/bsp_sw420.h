#ifndef __BSP_SW420_H__
#define __BSP_SW420_H__

/* 包含头文件 ----------------------------------------------------------------*/
#include "stm32l476xx.h"

/* 类型定义 --------------------------------------------------------------*/
typedef enum
{
  SW420_LOW   = 0,
  SW420_HIGH = 1,
}SW420_State_TypeDef;

/* 宏定义 --------------------------------------------------------------------*/
#define SW420_RCC_CLK_ENABLE()         __HAL_RCC_GPIOD_CLK_ENABLE()
#define SW420_GPIO_PIN                 GPIO_PIN_3
#define SW420_GPIO                     GPIOD
#define SW420_ACTIVE_LEVEL             1

/* 扩展变量 ------------------------------------------------------------------*/
/* 函数声明 ------------------------------------------------------------------*/
void SW420_GPIO_Init(void);
SW420_State_TypeDef SW420_StateRead(void);


#endif  // __BSP_SW420_H__
