/*
 * PIC10F200 and 74HC595 with 7 seg display
 * UNDER CONSTRUCTION...
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
        GP0 = (data >> i & 0B00000001);
        doClock();
    }
    doEnable();
}

void main(void) {
    TRIS = 0B00000000; // All GPIO (GP0:GP3) pins as output
    GPIO = 0;

    do {
        // sendData(0b11111010);
        // __delay_ms(1000);
        // sendData(0b01100000);
        // __delay_ms(1000);
        // sendData(0b11011100);
        // sendData(0b11110100);
        __delay_ms(1000);
        // sendData(0b01100110);
        // sendData(0b10110110);
        __delay_ms(1000);
        // sendData(0b10111110);
        // sendData(0b11100000);
        __delay_ms(1000);
        // sendData(0b11111110);
        // sendData(0b11100110);
        __delay_ms(1000);
        sendData(0);

    } while (1);


}
