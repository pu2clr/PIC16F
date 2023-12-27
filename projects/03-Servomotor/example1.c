#include <xc.h>

// Chip configuration
#pragma config FOSC = INTOSCIO  // Internal oscillator, port function on RA6 and RA7
#pragma config WDTE = OFF       // Watchdog Timer disabled
#pragma config PWRTE = OFF      // Power-up Timer disabled
#pragma config MCLRE = ON       // MCLR pin function is digital input
#pragma config BOREN = ON       // Brown-out Reset enabled
#pragma config LVP = OFF        // Low Voltage Programming disabled
#pragma config CPD = OFF        // Data EE Memory code protection off
#pragma config CP = OFF         // Flash Program Memory code protection off

#define _XTAL_FREQ 4000000  // Internal Oscillator Frequency set to 4MHz

void main() {
    TRISB = 0;              // Set PORTB as output
    CCP1CON = 0b00001100;   // Configure PWM mode
    T2CON = 0b00000101;     // Enable Timer2 with prescaler of 4

    PR2 = 255;              // PWM Period

    while (1) {
        CCPR1L = 31;        // PWM value for servo position (adjust as needed)
        __delay_ms(1000);   // Wait for 1 second
        CCPR1L = 125;       // Another PWM value to move the servo
        __delay_ms(1000);   // Wait for 1 second
    }
}

