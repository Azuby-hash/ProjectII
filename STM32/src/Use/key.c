#include "key.h"
#include "display.h"
#include "main.h"
#include "UART.h"

static char key = '\0';
static uint32_t time = 0;
static uint8_t onClick = 0;

void endClick() {
    time = HAL_GetTick();
    onClick = 0;
}

void action() {
    if (onClick || (HAL_GetTick() - time) < 50) { return; }
    onClick = 1;

    if (key == 'M') {
        onDisplay[0] = onDisplay[0] == 0 ? 1 : 0;
        if (onDisplay[0] == 0) {
            onDisplay[1] = 0;
        }
        display();
        return;
    }

    float* values[4] = {&tempSP, &airHumSP, &pHHumSP, &lightHumSP};

    if (onDisplay[1] == 0) {
        if (key == 'E') {
            onDisplay[1] = onDisplay[0];
            SP = *values[onDisplay[1] - 1];
            display();
            return;
        }
        if (key == '+') {
            onDisplay[0]--;
        }
        if (key == '-') {
            onDisplay[0]++;
        }
        if (onDisplay[0] > 4) {
            onDisplay[0] = 1;
        }
        if (onDisplay[0] < 1) {
            onDisplay[0] = 4;
        }
    } else {
        if (offReceive == 1) { return; }
        if (key == 'E') {
            onDisplay[0] = onDisplay[0] == 0 ? 1 : 0;
            if (onDisplay[0] == 0) {
                *values[onDisplay[1] - 1] = SP;
                onDisplay[1] = 0;
            }
            offReceive = 1;

            display();
            return;
        }
        if (key == '+') {
            SP++;
        }
        if (key == '-') {
            SP--;
        }
    }
    display();
}

void enterKey() {
    uint16_t pin[4] = {GPIO_PIN_3, GPIO_PIN_4, GPIO_PIN_5, GPIO_PIN_6};
    char ch[4] = {'M', 'E', '+', '-'};

    for (uint8_t i = 0; i < 4; i++) {
        if (HAL_GPIO_ReadPin(GPIOA, pin[i]) == 1) {
            if (key != ch[i]) {
                endClick();
            }
            key = ch[i];
            action();
            return;
        }
    }

    key = '\0';
    endClick();
}