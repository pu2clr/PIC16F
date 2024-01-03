/**
 * @file pic16flcd.c
 * @author Ricardo LIma Caratti (pu2clr@gmail.com)
 * @brief This library is a creation resulting from my learning journey about PIC microcontrollers. It is designed to control a 16x2 LCD
 * @version 1.0
 * @date 2023-12-30
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#ifndef LCD_H
#define LCD_H

#include <xc.h>

#ifndef _XTAL_FREQ
#define _XTAL_FREQ 4000000 // You must set it for the frequency you are using
#endif

// Structure for LCD pin configuration
typedef struct {
    volatile unsigned char *port;
    unsigned char rs_pin;
    unsigned char en_pin;
    unsigned char d4_pin;
    unsigned char d5_pin;
    unsigned char d6_pin;
    unsigned char d7_pin;
} Lcd_PinConfig;

// Function prototypes
void Lcd_Init(Lcd_PinConfig *config);
void Lcd_Command(Lcd_PinConfig *config, unsigned char cmd);
void Lcd_Clear(Lcd_PinConfig *config);
void Lcd_SetCursor(Lcd_PinConfig *config, unsigned char row, unsigned char column);
void Lcd_WriteChar(Lcd_PinConfig *config, unsigned char data);
void Lcd_WriteString(Lcd_PinConfig *config, char *str);
void Lcd_CreateCustomChar(Lcd_PinConfig *config, unsigned char location, unsigned char *charmap);
void inline Lcd_WriteCustomChar(Lcd_PinConfig *config, unsigned char location);

#endif
