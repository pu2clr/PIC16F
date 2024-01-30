/*
 * PIC10F200 and 74HC595 with 8 LEDs
 * File:   main.c
 * Author: Ricardo Lima Caratti
 *
 * Created on January 30
 */


#include <xc.h>

// CONFIG
#pragma config WDTE = OFF       // Watchdog Timer (WDT disabled)
#pragma config CP = OFF         // Code Protect (Code protection off)
#pragma config MCLRE = OFF      // Master Clear Enable (GP3/MCLR pin fuction is digital I/O, MCLR internally tied to VDD)

#define _XTAL_FREQ  4000000



void inline doClock() { 
    GP1 = 1; 
    __delay_ms(100);
    GP1 = 0;
    __delay_ms(100);
}

void inline doEnable() {
    GP2 = 1;
    __delay_ms(100); 
    GP2 = 0;
}

void inline sendData(unsigned char data) {
    do { 
        GP0 = ( data & 0B00000001);
        doClock();
        data = data >> 1;
    } while (data);
    doEnable();
}

void main(void) {
    TRIS = 0B00000000;          // All GPIO (GP0:GP3) pins as output
       
    sendData(0B01010101);
    while(1);
    
}
