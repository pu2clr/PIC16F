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
 * Handle PUSH BUTTON
 */
void __interrupt() ISR(void)
{
    GIE = 0;
    //  checks RB0/INT External Interrupt 
    if ( INTF ) {   
        RB3 = !RB3;                 // Toggle the LED (on/off) 
        INTF = 0 ;
    }
    GIE =  1;
}


void main() {
 
    // Digital Input and Output pins
    TRISB = 0B00000001; // RB0 as digital input and all other pins as digital output

  
    // Configures the PIC16F628A to trigger a function call as a result of RB0 level changes
    // See  Data Sheet (page 25 and 26)      
    OPTION_REG = 0B01000000;          
    INTE = 1;                      // RB0/INT External Interrupt Enable bit
    GIE = 1;                       // GIE: Enable Global Interrupt
 
    
    RB3 = 1;
    __delay_ms(3000);
    RB3 = 0;    
    
    while (1) {
      // Puts the system to sleep.  
      // It will wake-up if:  
      // 1. External Reset input on MCLR pin
      // 2. Watchdog Timer wake-up (if WDT was enabled) - NOT USED IN THIS PROJECT
      // 3. Interrupt from RB0/INT pin, RB port change, or any peripheral interrupt.
      // See page 113 of the PIC16F627A/628A/648A DATA SHEET 
      SLEEP();   
    }
}
