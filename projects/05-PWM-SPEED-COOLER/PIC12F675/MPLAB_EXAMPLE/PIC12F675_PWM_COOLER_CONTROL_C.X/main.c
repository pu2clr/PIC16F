/*
 * UNDER CONSTRUCTON...
 * 
 * File:   main.c
 * Author: rcaratti
 *
 * Created on March 15, 2024, 10:57 PM
 * Reference: https://saeedsolutions.blogspot.com/2012/07/pic12f675-pwm-code-proteus-simulation.html
 */


#pragma config FOSC = INTRCIO   // Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = OFF      // Power-Up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = ON       // GP3/MCLR pin function select (GP3/MCLR pin function is MCLR)
#pragma config BOREN = ON       // Brown-out Detect Enable bit (BOD enabled)
#pragma config CP = OFF         // Code Protection bit (Program Memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)


#define _XTAL_FREQ 8000000			// required for delay Routines. 

#include <xc.h>

uint8_t PWM;

/**
 * Handle timer overflow
 */
void __interrupt() ISR(void)
{
    if ( T0IF ) {
        
        if (GP5 ) {
            TMR0 = PWM;
            GP5 = 0;
        } else {
            TMR0 = 255 - PWM;
            GP5 = 1;
        }
        
        T0IF = 0;
    }
    
}

void main() {
   
    // Interrupt and I/O setup      
    // set GP0 as input
    // set GP2 as interrupt
    // see data sheet (page 20)
    TRISIO = 0B00000001;            // GP0 as input (if you want use a push button)
    
 
    // INTEDG: Interrupt Edge Select bit -  Interrupt will be triggered on the rising edge
    // Prescaler Rate: 1:64 - It generates about 73Hz 
    OPTION_REG = 0B01000101;       // see  data sheet (page 12)    
    T0IE = 1;   // TMR0: Overflow Interrupt 
    GIE = 1;    // GIE: Enable Global Interrupt
       
    PWM = 127;
    
    while (1) {
        // Now you can get an analogic or digital value and control de cooler by changing PWV value
    }
}



