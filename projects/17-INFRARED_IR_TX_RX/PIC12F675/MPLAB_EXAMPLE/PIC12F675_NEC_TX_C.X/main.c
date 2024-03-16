/*
 * UNDER CONSTRUCTON...
 * 
 * File:   main.c
 * Author: rcaratti
 *
 * Created on March 15, 2024, 10:57 PM
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

void sendFrame(unsigned char address, unsigned char command) // this routine send the whole frame including 9ms leading pulse 4.5ms space address ~address command ~command end of message bit.
{
    TMR1 = 0x00;
	
    
}

void sendByte(unsigned char byte) // this function is called only by the sendFrame , to send each byte of data total 4bytes.
{

}

void sendRepeate() {

}

/**
 * Handle the push button 
 */
void __interrupt() ISR(void)
{
    if (INTF) {
        __delay_ms(10);              // mitigate noise/glitches during button press (debounce)
        if ( GP5 ) {
            sendFrame(0x01, 0xF8);
        }
        INTF = 0;
    } else if ( T0IF ) {
        
        if (GP0 ) {
            TMR0 = PWM;
            GP0 = 0;
        } else {
            TMR0 = 255 - PWM;
            GP0 = 1;
        }
        
        T0IF = 0;
    }
    
}

void main() {

    // Interrupt setup    
    TRISIO2 = 1;            // set GP2 as interrupt
    INTCON |= 0x90;         // Enable global interrupt 
    OPTION_REG |= 0x40;     // Defines that the interrupt will be triggered on the rising edge (POSEDGE triggered) 

    T0IE = 1; 
    GIE = 1;
    
    PWM = 127;
    
    while (1) {
        SLEEP(); //put the MCU into Sleep mode forever , will wake-up when ever any key press is detected. 
        // the measured current consumption in this mode is ~ 29na ( much lower then the datasheet claim 50na)
    }
}



