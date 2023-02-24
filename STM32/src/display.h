#ifndef __DISPLAY_H
#define __DISPLAY_H

#include "stm32f1xx_hal.h"

void display();
void valueShow();
void menuShow(uint8_t line);
void setPointShow(uint8_t type);
uint8_t onDisplay[2];

#endif