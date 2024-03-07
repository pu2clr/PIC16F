// CONFIG
// CONFIG
#pragma config IOSCFS = 4MHZ    // Internal Oscillator Frequency Select bit (4 MHz)
#pragma config MCPU = OFF       // Master Clear Pull-up Enable bit (Pull-up disabled)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config CP = OFF         // Code protection bit (Code protection off)
#pragma config MCLRE = OFF      // GP3/MCLR Pin Function Select bit (GP3/MCLR pin function is digital I/O, MCLR internally tied to VDD)

#define _XTAL_FREQ  4000000

#include <xc.h>


void DelayMS() {
    for (uint8_t i = 0; i < 255; i ++) {
         for (uint8_t j = 0; j < 255; j ++) {
             asm("nop");
         }
    }
}



void main(void) {


    ADCON0 = 0B01000011;     
    TRIS = 0B00000001;           

    while (1) {
           GP1 = 1;
           DelayMS();
           GP1 = 0;
           DelayMS();   
    }
}
