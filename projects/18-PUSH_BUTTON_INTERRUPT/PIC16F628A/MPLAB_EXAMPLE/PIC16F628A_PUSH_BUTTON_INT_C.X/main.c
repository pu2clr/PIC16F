/**
 * PUSH BUTTON DETECTING USING INTERRUPT
 * 
 * Simple way to blink a LED 
 * 
 * Author: Ricardo Lima Caratti
 * Mar/2004
 */
#include <xc.h>
 
#pragma config FOSC = INTOSCIO  // Internal oscillator.
#pragma config WDTE = OFF       // Watchdog Timer disabled 
#pragma config PWRTE = OFF      // Power-up Timer disable
#pragma config MCLRE = ON       // MCLR pin function is digital input
#pragma config BOREN = OFF      // Brown-out Reset enabled
#pragma config LVP = OFF        // Low Voltage Programming disabled
#pragma config CPD = OFF        // Data EEPROM Memory Code Protection disabled
#pragma config CP = OFF         // Flash Program Memory Code Protection disabled

#define _XTAL_FREQ 4000000      // internal clock



/**
 * Configures the PIC16F628A to trigger a function call as a result of RB0 level changes
 * See  Data Sheet (page 25 and 26)  
 */
void  initInterrupt() {
    OPTION_REG = 0B01000000;          
    INTE = 1;                      // RB0/INT External Interrupt Enable bit
    GIE = 1;                       // GIE: Enable Global Interrupt
}


/**
 * Handle PUSH BUTTON
 */
void __interrupt() ISR(void)
{
    if ( INTE ) {
        
        // TODO
        
        INTE = 0 ;
    }
    
}


void main() {

    // Digital Input and Output pins

    initInterrupt();
    
    while (1) {

    }
}
