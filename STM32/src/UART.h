#ifndef __UART_H
#define __UART_H

#include "stm32f1xx_hal.h"

void transmitInterval();
void receiveInterval();
extern uint8_t offReceive;

#endif