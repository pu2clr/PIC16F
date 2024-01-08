#include <xc.h>

// Chip settings
#pragma config FOSC = INTOSCCLK // Internal oscillator, CLKOUT on RA6
#pragma config WDTE = OFF       // Disables Watchdog Timer
#pragma config PWRTE = OFF      // Disables Power-up Timer
#pragma config MCLRE = ON       // MCLR pin function is digital input
#pragma config BOREN = ON       // Enables Brown-out Reset
#pragma config LVP = OFF        // Low voltage programming disabled
#pragma config CPD = OFF        // Data EE memory code protection disabled
#pragma config CP = OFF         // Flash program memory code protection disabled

#define _XTAL_FREQ 4000000 // Internal oscillator frequency set to 4MHz

void main()
{
    TRISB = 0;            // Configures PORTB as output
    CCP1CON = 0b00001100; // PWM mode configuration
    T2CON = 0b00000111;   // Activates Timer2 with prescaler of 16
    PR2 = 13;             // PWM period

    // Starts Timer2
    TMR2 = 0;   // Resets Timer2 counter
    TMR2ON = 1; // Turns on Timer2

    while (1)
    {
        // Approximate values for 1.5 ms (center position)
        CCPR1L = 6;
        __delay_ms(1000);

        // Approximate values for 1 ms (0 degrees)
        CCPR1L = 20;
        __delay_ms(1000);

        // Approximate values for 2 ms (180 degrees)
        CCPR1L = 30;
        __delay_ms(1000);
    }
}
