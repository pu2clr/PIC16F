/**
 * This example works with PIC16F628A
 */

#include <xc.h>
// #include <stdio.h>
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
    char strDistance[7];
    TRISB = 0x00; // You need to set this register as output
    
    // Turns off the comparator and converts its pins in digital I/O.     
    CMCONbits.CM = 0x07; 

    // Sets the PORT A and B    
    TRISA0 = 0;  // TRIG pin  (HC-S04 TRIGGER output)
    TRISA1 = 1;  // ECHO pin  (HC-S04 ECHO input)    
    
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
    Lcd_WriteString(&lcd, "PIC16F628A-HCS04");
    Lcd_SetCursor(&lcd, 2, 1); // Display message (Line 2 and Column 2)
    Lcd_WriteString(&lcd, "Distance: ");
    __delay_ms(10000); 
    while(1) {
        TMR1H = 0;  // sets the high byte of the Timer1 counter to 0
        TMR1L = 0;  // sets the low byte of the Timer1 counter to 0
        
        RA0 = 1;
        __delay_us(10);
        RA0 = 0;
        while(!RA1); // Wait for ECHO/RA1 pin becomes HIGH
        TMR1ON = 1;  // Turns TIMER1 on
        while(RA1);  // Wait for ECHO/RA1 pin becomes LOW
        TMR1ON = 0;  // Turns TIMER1 off  
        
        unsigned int duration = (unsigned int) (TMR1H << 8) | TMR1L;
        unsigned int distance = (float) duration *0.034/2;        
        
        // sprintf(strDistance,"%u3",distance);
        // Lcd_SetCursor(&lcd, 2, 11);
        // Lcd_WriteString(&lcd,strDistance);
        __delay_ms(100);
    }
}

