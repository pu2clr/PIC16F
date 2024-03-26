/*
 * 
 * Created on March 15, 2024, 10:57 PM
 * Reference: https://saeedsolutions.blogspot.com/2012/07/pic12f675-pwm-code-proteus-simulation.html
 */


#pragma config FOSC = INTRCIO   // Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = OFF      // Power-Up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = OFF       // GP3/MCLR pin function select (GP3/MCLR pin function is MCLR)
#pragma config BOREN = ON       // Brown-out Detect Enable bit (BOD enabled)
#pragma config CP = OFF         // Code Protection bit (Program Memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)


#define _XTAL_FREQ 8000000			// required for delay Routines. 

#include <xc.h>



/**
 * Configures the PIC12F675 to trigger a function call as GP0 / PUSH BUTTON ACTION.
 */
void  initInterrupt() {
    // INTEDG: Interrupt Edge Select bit -  Interrupt will be triggered on the rising edge
    OPTION_REG = 0B01000000;       // see  data sheet (page 12)    
    INTE = 1;                      // 
    GIE = 1;                       // GIE: Enable Global Interrupt
}


/**
 * Handle timer overflow
 */
void __interrupt() ISR(void)
{
    if ( INTF ) {
        
        GP5 = !GP5;              // LED
        
        INTF = 0;
    }
    
}


void main() {
   
    initInterrupt();
    
    while (1) {

    }
}



