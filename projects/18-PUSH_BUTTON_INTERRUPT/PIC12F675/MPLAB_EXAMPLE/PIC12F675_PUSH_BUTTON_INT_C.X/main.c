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


#define _XTAL_FREQ 4000000			// required for delay Routines. 

#include <xc.h>

/**
 * Handle timer overflow
 */
void __interrupt() ISR(void) {
    GIE = 0;
    if (INTF) {
        GP5 = !GP5;     // Toggle the LED (ON/OFF)
        __delay_ms(100);  // Debounce
        INTF = 0;
    }
    GIE = 1;
}

void main() {

    TRISIO = 0B00000100; // GP2 as digital input / GP5 as digital output 
    ANSEL  = 0;

    // Configures the PIC12F675 to trigger a function call as GP0 / PUSH BUTTON ACTION.

    // INTEDG: Interrupt Edge Select bit -  Interrupt will be triggered on the rising edge
    OPTION_REG = 0B01000000; // see  data sheet (page 12)    
    INTE = 1; // GP2/INT External Interrupt Enable bit
    GIE = 1; // GIE: Enable Global Interrupt

    // Status    
    GP5 = 1;
    __delay_ms(1500);
    GP5 = 0;

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



