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
#pragma config MCLRE = ON      // Master Clear Enable (GP3/MCLR pin fuction is digital I/O, MCLR internally tied to VDD)

#define _XTAL_FREQ  4000000



void inline doClock() { 
    GP1 = 1; 
    __delay_us(100);
    GP1 = 0;
    __delay_us(100);
}

void inline doEnable() {
    GP2 = 1;
    __delay_us(100); 
    GP2 = 0;
}

void inline sendData(unsigned char data) {
    for (unsigned char i = 0; i < 8; i++) { 
        GP0 = ( data >> i & 0B00000001);
        doClock();
    }
    doEnable();
}

void main(void) {
    TRIS = 0B00000000;          // All GPIO (GP0:GP3) pins as output
    GPIO = 0;
    
    sendData(0B11111111);
    __delay_ms(5000);
    sendData(0);
    __delay_ms(5000);   
    
    unsigned char data = 1;
    while(1) {
        __delay_ms(1000);
        sendData(data);
        data = (unsigned char) (data <<  1);
        if (data == 0) {
            sendData(0);
            data = 1;
        }
    }
    
}
