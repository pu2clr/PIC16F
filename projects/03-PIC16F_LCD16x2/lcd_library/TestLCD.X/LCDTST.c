#include <xc.h>
#include "pic16flcd.h"

#define _XTAL_FREQ 4000000 // Adjust this according to your system clock


void main() {
    // Define the LCD pin configuration for PIC16F628A
    Lcd_PinConfig lcdConfig_16F628A = {
        .port = &PORTB,
        .rs_pin = 0, // RB0 for RS
        .en_pin = 1, // RB1 for EN
        .d4_pin = 4, // RB4 for D4
        .d5_pin = 5, // RB5 for D5
        .d6_pin = 6, // RB6 for D6
        .d7_pin = 7  // RB7 for D7
    };

    // Initialize the LCD
    Lcd_Init(&lcdConfig_16F628A);
    Lcd_Clear(&lcdConfig_16F628A);

    // Display message
    Lcd_SetCursor(&lcdConfig_16F628A, 1, 1);
    Lcd_WriteString(&lcdConfig_16F628A, "Oi Mundo");

    while(1) {
        // Main loop
    }
}

