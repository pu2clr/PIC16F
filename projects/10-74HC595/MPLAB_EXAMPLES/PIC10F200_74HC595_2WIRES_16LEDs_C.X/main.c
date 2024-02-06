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


void  sendData(unsigned int data) {
    for (unsigned char i = 0; i <= 16; i++) {
        GP0 = (data >> i & 1);
        GP1 = 1;
        __delay_us(2);
        GP1 = 0;
        __delay_us(2);
    }
}

void main(void) {
    TRIS = 0B00000000; // All GPIO (GP0:GP3) pins as output
    GPIO = 0;          // Data => GP0; Clock and Latch => GP1 
    
    // Turn all LEDs on
    sendData(0B1111111111111111);
    __delay_ms(5000);
    // Turn all LEDs off
    sendData(0);
    __delay_ms(5000);

    // 
    unsigned int data = 1;
    while (1) {
        __delay_ms(1000);
        sendData(data);
        data = (unsigned int) (data << 1);
        if (data == 0) {
            sendData(0);
            data = 1;
        }
    }

}
