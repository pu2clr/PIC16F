#include <xc.h>

#pragma config FOSC = INTOSCCLK // Internal OSC
#pragma config WDTE = OFF       // Disable Watchdog Timer
#pragma config PWRTE = OFF      // Disable Timer  Power-up
#pragma config MCLRE = ON       // 
#pragma config BOREN = ON       // 
#pragma config LVP = OFF        // 
#pragma config CPD = OFF        // 
#pragma config CP = OFF         // 

#define _XTAL_FREQ 4000000 // Internal Clock 4MHz

void main()
{
    TRISB = 0;            // Sets PORTB - output
    CCP1CON = 0b00001100; // Sets PWM
    T2CON = 0b00000111;   // Sets Timer2 prescaler of 16
    PR2 = 255;             // Sets PWM period

 
    TMR2 = 0;   // Resets Timer2 
    TMR2ON = 1; // Sets Timer2 ON 

    while (1)
    {
        // Minimum Speed
        CCPR1L = 27;
        __delay_ms(5000);
        
        // Average Speed
        CCPR1L = 33;
        __delay_ms(5000);

        // Maximum Speed
        CCPR1L = 55;
        __delay_ms(5000);
    }
}

