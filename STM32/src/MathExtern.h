#ifndef __MATHEXTERN_H
#define __MATHEXTERN_H

#include "stm32f1xx_hal.h"
#include "math.h"
#include "stdio.h"
#include "string.h"

extern ADC_HandleTypeDef hadc1;
extern I2C_HandleTypeDef hi2c1;
extern TIM_HandleTypeDef htim4;
extern UART_HandleTypeDef huart1;

uint16_t getMax(uint16_t num1, uint16_t num2);
uint8_t * numberToString(uint16_t val);
uint16_t getADCValue(uint32_t channel);
void transmitString(uint8_t * value);
void transmitNumber(uint16_t value);
uint8_t* receiveString();
void receiveClear();

#endif