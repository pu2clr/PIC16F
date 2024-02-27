#include <xc.h>
#include "pic16flcd.h"


#pragma config FOSC = HS      // 
#pragma config WDTE = OFF       // Watchdog Timer disabled 
#pragma config PWRTE = OFF      // Power-up Timer disabled
#pragma config BOREN = OFF      // Brown-out Reset disabled
#pragma config LVP = OFF        // Low Voltage Programming disabled
#pragma config CPD = OFF        // Data EEPROM Memory Code Protection disabled
#pragma config CP = OFF         // Flash Program Memory Code Protection disabled


#ifndef _XTAL_FREQ
#define _XTAL_FREQ 8000000      // internal clock
#endif


/**
 Custom Char (Smile)
 */
unsigned char smile[8] = {
    0b00000,
    0b01010,
    0b01010,
    0b00000,
    0b10001,
    0b01110,
    0b00000,
    0b00000
};

/**
 Custom char (sad face)
 */
unsigned char sad[8] = {
    0b00000,
    0b01010,
    0b01010,
    0b00000,
    0b00000,
    0b01110,
    0b10001,
    0b00000
};

void main() {
    char i;



    // Define the LCD pin configuration for PIC16F887
    TRISC = 0; // You need to set this register to output
    Lcd_PinConfig lcd = {
        .port = &PORTC, // Assuming you're using PORTC for LCD on PIC16F887
        .rs_pin = 2, // RD0 for RS
        .en_pin = 3, // RD1 for EN
        .d4_pin = 4, // RD4 for D4
        .d5_pin = 5, // RD5 for D5
        .d6_pin = 6, // RD6 for D6
        .d7_pin = 7 // RD7 for D7
    };

    // Initialize the LCD
    Lcd_Init(&lcd);
    Lcd_Clear(&lcd);

    // Display message
    Lcd_SetCursor(&lcd, 1, 1);
    Lcd_WriteString(&lcd, "Hello");
    Lcd_SetCursor(&lcd, 2, 1);
    Lcd_WriteString(&lcd, "World");
    __delay_ms(5000);

    Lcd_Clear(&lcd);
    // Creating the character
    Lcd_CreateCustomChar(&lcd, 0, smile);
    Lcd_CreateCustomChar(&lcd, 1, sad);    
    // Displaying the character
    Lcd_SetCursor(&lcd, 1, 1);
    Lcd_WriteCustomChar(&lcd, 0);
    __delay_ms(5000);

    while (1) {
        Lcd_Clear(&lcd);
        for (i = 1; i <= 16; i++) {
            Lcd_SetCursor(&lcd, 1, i);
            Lcd_WriteChar(&lcd, 'A' + (i - 1));
            __delay_ms(150);
        }
        __delay_ms(2000);

        for (i = 1; i <= 16; i++) {
            Lcd_SetCursor(&lcd, 2, i);
            Lcd_WriteChar(&lcd, 'Q' + (i - 1));
            __delay_ms(150);
        }
        __delay_ms(2000);
        for (i = 1; i <= 16; i++) {
            Lcd_SetCursor(&lcd, 1, i);
            Lcd_WriteCustomChar(&lcd, 0); // Happy face
            __delay_ms(150);
            Lcd_SetCursor(&lcd, 2, i);
            Lcd_WriteCustomChar(&lcd, 1); // Sad face
            __delay_ms(200);
        }
        __delay_ms(2000);
    }
}
