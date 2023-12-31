#include <xc.h>
#include "lcd.h"

#define _XTAL_FREQ 8000000 // Adjust this according to your system clock

void main() {
    // Define the LCD pin configuration for PIC16F887
    Lcd_PinConfig lcdConfig_16F887 = {
        .port = &PORTD, // Assuming you're using PORTD for LCD on PIC16F887
        .rs_pin = 0, // RD0 for RS
        .en_pin = 1, // RD1 for EN
        .d4_pin = 4, // RD4 for D4
        .d5_pin = 5, // RD5 for D5
        .d6_pin = 6, // RD6 for D6
        .d7_pin = 7  // RD7 for D7
    };

    // Initialize the LCD
    Lcd_Init(&lcdConfig_16F887);
    Lcd_Clear(&lcdConfig_16F887);

    // Display message
    Lcd_SetCursor(&lcdConfig_16F887, 1, 1);
    Lcd_WriteString(&lcdConfig_16F887, "Oi Mundo");

    while(1) {
        // Main loop
    }
}
