/*
 * PIC10F200 and two 74HC595 with 16 LEDs
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

void inline sendData(unsigned int data) {
     GP2 = 0; // Latch low
    __delay_us(20);
    for (unsigned char i = 0; i < 16; i++) {
        GP0 = (data >> i & (unsigned int ) 1);
        __delay_us(100);
        GP1 = 1;
        __delay_us(100);
        GP1 = 0;
        __delay_us(100);
    }
    GP2 = 1; // Latch HIGH
    __delay_us(20);
}

void main(void) {
    TRIS = 0B00000000; // All GPIO (GP0:GP3) pins as output
    GPIO = 0; // Data => GP0; Clock => GP1; Latch = GP2 

    sendData(0);
    __delay_ms(3000);

    // 
    unsigned int data = 0B1010101010101010;

    while (1) {
        sendData(data);
        data = ~data;
        __delay_ms(3000);         
    }
}
