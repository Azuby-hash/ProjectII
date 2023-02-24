#include "MathExtern.h"
#include "main.h"

uint16_t getMax(uint16_t num1, uint16_t num2) {
	if (num1 > num2) {
		return num1;
	}

	return num2;
}
uint8_t * numberToString(uint16_t val){
	if (val == 0) return (uint8_t *)"0";
  
	static uint8_t buf[32] = {0};
	
	int i = 30;
	
	for(; val && i ; --i, val /= 10)
	
		buf[i] = "0123456789abcdef"[val % 10];
	
	return &buf[i+1];
	
}
uint16_t getADCValue(uint32_t channel) {
	ADC_ChannelConfTypeDef sConfig = {0};
	
	sConfig.Channel = channel;
    sConfig.Rank = ADC_REGULAR_RANK_1;
    sConfig.SamplingTime = ADC_SAMPLETIME_1CYCLE_5;
    if (HAL_ADC_ConfigChannel(&hadc1, &sConfig) != HAL_OK)
    {
        Error_Handler();
    }
	
	HAL_ADC_Start(&hadc1);
	HAL_ADC_PollForConversion(&hadc1, 10);
	uint16_t value = HAL_ADC_GetValue(&hadc1);
	HAL_ADC_Stop(&hadc1);

	return value;
}
void transmitString(uint8_t * value) {
	HAL_UART_Transmit(&huart1, value, strlen((char *)value), 10);	
} 
void transmitNumber(uint16_t value) {
	uint8_t * string = numberToString(value);
	HAL_UART_Transmit(&huart1, string, strlen((char *)string), 10);
} 

static uint8_t value[100] = {0};

uint8_t* receiveString() {
	HAL_UART_Receive(&huart1, value, 100, 400);

	// Clear data in Rx register

	return value;
} 

void receiveClear() {
	for(uint8_t i = 0; i < 100; i++) {
		value[i] = 0;
	}
}