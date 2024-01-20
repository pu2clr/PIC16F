/*
 * This experiment using the PIC12F675 and the HC-S04 ultrasonic distance sensor 
 * utilizes three LEDs (Red, Yellow, and Green) to indicate, respectively, a distance 
 * of less than 10 cm, between 10 and 30 cm, and more than 30 cm. 
 * In this case, there is no requirement to compute the exact distance 
 * to determine if it falls within specific ranges, such as being greater than 10, 
 * less than 30, or exceeding these values. Instead, you simply need to measure and 
 * compare the elapsed time corresponding to each of these distance thresholds.
 * 
 * Author: Ricardo Lima Caratti
 * Jan/2024
 */

#pragma config FOSC = INTRCIO   // Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = OFF      // Power-Up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = ON       // GP3/MCLR pin function select (GP3/MCLR pin function is MCLR)
#pragma config BOREN = ON       // Brown-out Detect Enable bit (BOD enabled)
#pragma config CP = OFF         // Code Protection bit (Program Memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)

// 4Mhz internal oscillator
#define _XTAL_FREQ 4000000
#include <xc.h>


/**
 * Turns All LEDS Off
 */
void AllOff() {
    GPIO =  0;
}

/**
 * Turns Green LED On
 */
void inline GreenOn() {
    AllOff();
    GPIO =  1;
}

/**
 * Turns Yellow LED On
 */
void inline YellowOn() {
    AllOff();
    GPIO =  2;
}

/**
 * Turns Red LED On
 */
void inline RedOn() {
    AllOff();
    GPIO =  4;
}


void main(void)
{   
    TRISIO = 0;        // Trigger (GP5), and GP0, GP1 and GP2 (LEDs) are output   
    TRISIO4 = 1;       // Echo
    ANSEL = 0;         // Digital input setup          
    
    while (1)
    {
        // Reset TMR1
        TMR1H = 0;
        TMR1L = 0;

        // Send 10uS signal to the Trigger pin
        GP5 = 1;
        __delay_us(10);
        GP5 = 0;

        // Wait for echo
        while (!GP4);
        TMR1ON = 1;
        while (GP4);
        TMR1ON = 0;    
        // Now you have the elapsed time stored in TMR1H and TMR1L
        unsigned int duration = (unsigned int) (TMR1H << 8) | TMR1L;
        // There is no requirement to compute the exact distance to determine if it falls within specific ranges, 
        // such as being greater than 10, less than 30, or exceeding these values. Instead, you simply need to 
        // measure and compare the elapsed time corresponding to each of these distance thresholds.
        // This approach saves memory.
        if ( duration < 830)       // This time is about 10 cm
            RedOn();
        else if (duration <= 2450 ) // This time is about 30 cm 
            YellowOn();
        else
            GreenOn();
        __delay_ms(100); 
    }

}
