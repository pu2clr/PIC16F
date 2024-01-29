/*
 * Blink a LED with the PIC10F200
 * File:   main.c
 * Author: Ricardo Lima Caratti
 *
 * Created on January 28
 */


#include <xc.h>

// CONFIG
#pragma config WDTE = OFF       // Watchdog Timer (WDT disabled)
#pragma config CP = OFF         // Code Protect (Code protection off)
#pragma config MCLRE = OFF      // Master Clear Enable (GP3/MCLR pin fuction is digital I/O, MCLR internally tied to VDD)

#define _XTAL_FREQ  4000000


/**
 * Due to the PIC10F200's limited memory, it may be more efficient to develop your 
 * own delay function instead of using the "__delay_ms()" function. 
 * This is an approach to consider if timing is not critical for your application.
 */
void myDelay() {
    for (unsigned char i = 0; i < 255; i++) {
        for (unsigned char j = 0; j < 255; j++ ) {
            asm("nop");
            asm("nop");
        }
    }  
}

void main(void) {
    TRIS = 0B00000000;          // All GPIO (GP0:GP3) pins as output
       
    do {
        GP0 = 1;                // Turn the LED on
        // __delay_ms(1000);
        myDelay();
        GP0 = 0;                // Turn the LED off
        // __delay_ms(1000); 
        myDelay();
    } while(1);
}
