#include <xc.h>

// PIC16F887 chip configurations

#pragma config FOSC = INTRC_NOCLKOUT  // Internal oscillator, no clock out
#pragma config WDTE = OFF             // Watchdog Timer disabled
#pragma config PWRTE = OFF            // Power-up Timer disabled
#pragma config MCLRE = ON             // MCLR pin enabled, RE3 input pin disabled
#pragma config CP = OFF               // Program memory code protection disabled
#pragma config CPD = OFF              // Data memory code protection disabled
#pragma config BOREN = ON             // Brown-out Reset enabled
#pragma config IESO = OFF             // Internal External Switchover bit disabled
#pragma config FCMEN = OFF            // Fail-Safe Clock Monitor disabled
#pragma config LVP = OFF              // Low Voltage Programming disabled

#define _XTAL_FREQ 4000000  // Sets the internal oscillator frequency to 4MHz

void main() {

    unsigned char i;

    OSCCON = 0x60; // Configure internal oscillator to 4MHz

    TRISC = 0; // Set PORTC as output
    CCP1CON = 0x0C; // PWM mode
    T2CON = 0x07; // Timer2 ON, prescaler of 16
    PR2 = 255; // PWM period

    while (1) {

        for (i = 40; i < 120; i += 20) {
            CCPR1L = i;
            __delay_ms(1000);
        }
        __delay_ms(5000);
        for (i = 40; i < 100; i += 5) {
            CCPR1L = i;
            __delay_ms(500);
        }
        __delay_ms(5000);
    }
}
