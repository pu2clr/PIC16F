/**
 * This example works with PIC16F628A
 */

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
    char i;
    TRISB = 0x00; // You need to set this register as output
    // Define the LCD pin configuration for PIC16F628A
    Lcd_PinConfig lcd = {
        .port = &PORTB,  // Port to be used to control the LCD 
        .rs_pin = 2,     // RB2 for RS
        .en_pin = 3,     // RB3 for EN
        .d4_pin = 4,     // RB4 for D4
        .d5_pin = 5,     // RB5 for D5
        .d6_pin = 6,     // RB6 for D6
        .d7_pin = 7      // RB7 for D7
    };
    Lcd_Init(&lcd);  // Initialize the LCD
    Lcd_Clear(&lcd); 
    Lcd_SetCursor(&lcd, 1, 1); // Display message (Line 1 and Column 1)
    Lcd_WriteString(&lcd, "Hello");
    Lcd_SetCursor(&lcd, 2, 1); // Display message (Line 2 and Column 2)
    Lcd_WriteString(&lcd, "World");
    __delay_ms(10000); 
    while(1) {
        Lcd_Clear(&lcd); 
        for (i = 1; i <= 16; i++) {
            Lcd_SetCursor(&lcd, 1, i); 
            Lcd_WriteChar(&lcd,'A' + (i-1));
            __delay_ms(500);
        }
        __delay_ms(5000); 

        for (i = 1; i <= 16; i++) {
            Lcd_SetCursor(&lcd, 2, i); 
            Lcd_WriteChar(&lcd,'I' + (i-1));
            __delay_ms(500);
        }  
        __delay_ms(5000);
    }
}

