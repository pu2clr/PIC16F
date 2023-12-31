#include <xc.h>
#include "pic16flcd.h"

#pragma config FOSC = INTOSCIO  // Internal oscillator.
#pragma config WDTE = OFF       // Watchdog Timer disabled 
#pragma config PWRTE = OFF      // Power-up Timer disable
#pragma config MCLRE = ON       // MCLR pin function is digital input
#pragma config BOREN = OFF      // Brown-out Reset enabled
#pragma config LVP = OFF        // Low Voltage Programming disabled
#pragma config CPD = OFF        // Data EEPROM Memory Code Protection disabled
#pragma config CP = OFF         // Flash Program Memory Code Protection disabled
#define _XTAL_FREQ 4000000      // internal clock

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
    Lcd_Init(&lcdConfig_16F628A);  // Initialize the LCD
    Lcd_Clear(&lcdConfig_16F628A); 
    Lcd_SetCursor(&lcdConfig_16F628A, 1, 1); // Display message
    Lcd_WriteString(&lcdConfig_16F628A, "Hello");
    while(1) {}
}

