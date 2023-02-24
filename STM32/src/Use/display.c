#include "display.h"
#include "ssd1306.h"
#include "MathExtern.h"
#include "main.h"
#include "UART.h"

uint8_t onDisplay[2] = {0, 0};

void display() {
  if (onDisplay[0] == 0) {
    valueShow();
  }

  if (onDisplay[0] != 0 && onDisplay[1] == 0) {
    menuShow(onDisplay[0]);
  }

  if (onDisplay[0] != 0 && onDisplay[1] != 0) {
    setPointShow(onDisplay[1]);
  }

  SSD1306_UpdateScreen();
}

void valueShow() {
  SSD1306_GotoXY(10,0);
  SSD1306_Puts("Temp: ", &Font_7x10, SSD1306_COLOR_WHITE);
  SSD1306_Puts((char *)numberToString(temp), &Font_7x10, SSD1306_COLOR_WHITE);
  SSD1306_Puts(".", &Font_7x10, SSD1306_COLOR_WHITE);
  SSD1306_Puts((char *)numberToString((temp - (uint16_t)temp) * 10), &Font_7x10, SSD1306_COLOR_WHITE);
  SSD1306_Puts("C", &Font_7x10, SSD1306_COLOR_WHITE);
  SSD1306_Puts("             ", &Font_7x10, SSD1306_COLOR_WHITE);

  SSD1306_GotoXY(10,15);
  SSD1306_Puts("Air: ", &Font_7x10, SSD1306_COLOR_WHITE);
  SSD1306_Puts((char *)numberToString(airHum), &Font_7x10, SSD1306_COLOR_WHITE);
  SSD1306_Puts(".", &Font_7x10, SSD1306_COLOR_WHITE);
  SSD1306_Puts((char *)numberToString((airHum - (uint16_t)airHum) * 10), &Font_7x10, SSD1306_COLOR_WHITE);
  SSD1306_Puts("%", &Font_7x10, SSD1306_COLOR_WHITE);
  SSD1306_Puts("             ", &Font_7x10, SSD1306_COLOR_WHITE);

  SSD1306_GotoXY(10,30);
  SSD1306_Puts("Humi: ", &Font_7x10, SSD1306_COLOR_WHITE);
  SSD1306_Puts((char *)numberToString(pHHum), &Font_7x10, SSD1306_COLOR_WHITE);
  SSD1306_Puts("%", &Font_7x10, SSD1306_COLOR_WHITE);
  SSD1306_Puts("             ", &Font_7x10, SSD1306_COLOR_WHITE);

  SSD1306_GotoXY(10,45);
  SSD1306_Puts("Light: ", &Font_7x10, SSD1306_COLOR_WHITE);
  SSD1306_Puts((char *)numberToString(lightHum), &Font_7x10, SSD1306_COLOR_WHITE);
  SSD1306_Puts("Lux", &Font_7x10, SSD1306_COLOR_WHITE);
  SSD1306_Puts("             ", &Font_7x10, SSD1306_COLOR_WHITE);
}

void menuShow(uint8_t line) {
  SSD1306_GotoXY(10,0);
  SSD1306_Puts("Set Temp SP  ", &Font_7x10, line == 1 ? SSD1306_COLOR_BLACK : SSD1306_COLOR_WHITE);

  SSD1306_GotoXY(10,15);
  SSD1306_Puts("Set Air SP   ", &Font_7x10, line == 2 ? SSD1306_COLOR_BLACK : SSD1306_COLOR_WHITE);

  SSD1306_GotoXY(10,30);
  SSD1306_Puts("Set Humu SP  ", &Font_7x10, line == 3 ? SSD1306_COLOR_BLACK : SSD1306_COLOR_WHITE);

  SSD1306_GotoXY(10,45);
  SSD1306_Puts("Set Light SP ", &Font_7x10, line == 4 ? SSD1306_COLOR_BLACK : SSD1306_COLOR_WHITE);
}

void setPointShow(uint8_t type) {
  float values[4] = {tempSP, airHumSP, pHHumSP, lightHumSP};

  SSD1306_GotoXY(10,0);
  SSD1306_Puts("  Set Point           ", &Font_7x10,SSD1306_COLOR_WHITE);

  SSD1306_GotoXY(10,30);

  if (offReceive == 1) {
    SSD1306_Puts(" Wait to set                 ", &Font_7x10,SSD1306_COLOR_WHITE);
  } else {
    if (values[type] < 100) {
      SSD1306_Puts("     ", &Font_7x10,SSD1306_COLOR_WHITE);
      SSD1306_Puts((char *)numberToString(SP), &Font_7x10,SSD1306_COLOR_WHITE);
    }
    if (values[type] < 10000 && values[type] >= 100) {
      SSD1306_Puts("    ", &Font_7x10,SSD1306_COLOR_WHITE);
      SSD1306_Puts((char *)numberToString(SP), &Font_7x10,SSD1306_COLOR_WHITE);
    }
    SSD1306_Puts("                    ", &Font_7x10,SSD1306_COLOR_WHITE);
  }


  SSD1306_GotoXY(10,15);
  SSD1306_Puts("                    ", &Font_7x10,SSD1306_COLOR_WHITE);

  SSD1306_GotoXY(10,45);
  SSD1306_Puts("                    ", &Font_7x10,SSD1306_COLOR_WHITE);
}