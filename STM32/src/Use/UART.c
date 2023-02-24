#include "UART.h"
#include "MathExtern.h"
#include "string.h"
#include "main.h"
#include "stdlib.h"

uint8_t offReceive = 0;

char* insertString(char* destination, char* seed)
{
    char * strC;

    strC = (char*)malloc(strlen(destination)+strlen(seed)+1);
    strcpy(strC,destination);
    strC[strlen(destination)] = '\0';
    strcat(strC,seed);
    
    return strC;
}

uint8_t * _float_to_char(float x, char *p) {
    char *s = p + 20; // go to end of buffer
    uint16_t decimals;  // variable to store the decimals
    uint16_t units;  // variable to store the units (part to left of decimal place)
    if (x < 0) { // take care of negative numbers
        decimals = (uint16_t)(x * -100) % 100; // make 1000 for 3 decimals etc.
        units = (uint16_t)(-1 * x);
    } else { // positive numbers
        decimals = (uint16_t)(x * 100) % 100;
        units = (uint16_t)x;
    }
    
    *--s = '\0';
    // *--s = (decimals % 10) + '0';
    decimals /= 10; // repeat for as many decimal places as you need
    *--s = (decimals % 10) + '0';
    *--s = '.';

    if (units == 0) {
        *--s = '0';
    } else
    while (units > 0) {
        *--s = (units % 10) + '0';
        units /= 10;
    }
    if (x < 0) *--s = '-'; // unary minus sign for negative numbers
    return (uint8_t *)s;
}

void transmitInterval() {
    char buf[20];

    if (offReceive == 1) {
        transmitString((uint8_t *)"{ \n  ");
        transmitString((uint8_t *)"\"TempSP\": ");
        transmitString(_float_to_char(tempSP, buf));

        transmitString((uint8_t *)", \n  ");
        transmitString((uint8_t *)"\"AirSP\": ");
        transmitString(_float_to_char(airHumSP, buf));

        transmitString((uint8_t *)", \n  ");
        transmitString((uint8_t *)"\"HumiSP\": ");
        transmitString(_float_to_char(pHHumSP, buf));

        transmitString((uint8_t *)", \n  ");
        transmitString((uint8_t *)"\"LightSP\": ");
        transmitString(_float_to_char(lightHumSP, buf));

        transmitString((uint8_t *)"\n}");

        transmitString((uint8_t *)"@");
        
        return;
    }

    transmitString((uint8_t *)"{ \n  ");
    transmitString((uint8_t *)"\"Temp\": ");
    transmitString(_float_to_char(temp, buf));

    transmitString((uint8_t *)", \n  ");
    transmitString((uint8_t *)"\"Air\": ");
    transmitString(_float_to_char(airHum, buf));

    transmitString((uint8_t *)", \n  ");
    transmitString((uint8_t *)"\"Humi\": ");
    transmitString(_float_to_char(pHHum, buf));

    transmitString((uint8_t *)", \n  ");
    transmitString((uint8_t *)"\"Light\": ");
    transmitString(_float_to_char(lightHum, buf));

    transmitString((uint8_t *)", \n  ");
    transmitString((uint8_t *)"\"TempSP\": ");
    transmitString(_float_to_char(tempSP, buf));

    transmitString((uint8_t *)", \n  ");
    transmitString((uint8_t *)"\"AirSP\": ");
    transmitString(_float_to_char(airHumSP, buf));

    transmitString((uint8_t *)", \n  ");
    transmitString((uint8_t *)"\"HumiSP\": ");
    transmitString(_float_to_char(pHHumSP, buf));

    transmitString((uint8_t *)", \n  ");
    transmitString((uint8_t *)"\"LightSP\": ");
    transmitString(_float_to_char(lightHumSP, buf));

    transmitString((uint8_t *)"\n}");

    // transmitNumber(pHHum);
    transmitString((uint8_t *)"#");
}

void receiveInterval() {
    uint8_t* buf = receiveString();

    char key = buf[0];

    if (key == '1') {
        offReceive = 0;
        receiveClear();
    }
    if (key != '1' && key != '\0' && strlen(buf) > 2) {
        while(buf[0] > 0x40 || buf[0] == '\0') {
            buf++;
        }
        if (key == 't') {
            tempSP = atof((char *)buf);
            // transmitString((uint8_t *)"$");
        }
        if (key == 'a') {
            airHumSP = atof((char *)buf);
            // transmitString((uint8_t *)"$");
        }
        if (key == 'h') {
            pHHumSP = atof((char *)buf);
            // transmitString((uint8_t *)"$");
        }
        if (key == 'l') {
            lightHumSP = atof((char *)buf);
            // transmitString((uint8_t *)"$");
        }
        receiveClear();
    }
}