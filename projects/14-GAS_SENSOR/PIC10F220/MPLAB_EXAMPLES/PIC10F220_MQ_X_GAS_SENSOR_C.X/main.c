/**
* My PIC Journey  - MQ-2 Gas sensor and PIC10F220
* 
* This application displays three possible situations to represent the gas level: a lit red LED means danger, 
* a blinking green and red LED at the same time means caution or alert, and a lit green LED means safe.    
* 
* ATTENTION: This experiment is solely intended to demonstrate the interfacing of an MQ series gas sensor 
* with PIC microcontrollers. The gas concentration values and thresholds used in the example programs have 
* been arbitrarily set to illustrate high, medium, or low gas concentration levels. However, it is crucial 
* to emphasize that these values may not accurately reflect the real concentrations that pose a health risk. 
* Therefore, if you plan to use the examples provided, it is strongly recommended to consult the gas sensor's Datasheet. 
* This is essential to ascertain the exact values that define dangerous, tolerable, or low gas concentrations.  
* Author: Ricardo Lima Caratti
* Feb/2022
*/
// CONFIG
#pragma config IOSCFS = 4MHZ    // Internal Oscillator Frequency Select bit (4 MHz)
#pragma config MCPU = OFF       // Master Clear Pull-up Enable bit (Pull-up disabled)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config CP = OFF         // Code protection bit (Code protection off)
#pragma config MCLRE = OFF      // GP3/MCLR Pin Function Select bit (GP3/MCLR pin function is digital I/O, MCLR internally tied to VDD)

#define _XTAL_FREQ  4000000

#include <xc.h>


void DelayMS(uint8_t param) 
{
    for (uint8_t i = 0; i < param; i ++) {
         for (uint8_t j = 0; j < 255; j ++) {
             asm("nop");
         }
    }
}


uint8_t readADC() {
    ADCON0bits.GO = 1;              // Start conversion
    while (ADCON0bits.GO_nDONE);    // Wait for conversion to finish
    return ADRES;                   // return the ADC 8 bit integer value 255 ~= 5V, 127 ~= 2.5V, ... 0 = 0V
}

void main(void) {

    // bit 7 - ANS1: 0 = GP1/AN1 configured as digital I/O
    // bit 6 - ANS0: 1 = GP0/AN0 configured as an analog input
    // bit 5 - Unimplemented
    // bit 4 - Unimplemented
    // bit 3:2 - CHS<1:0>: ADC Channel Select bits - 00 = Channel00(GP0/AN0)
    // bit 1 - 1 = ADC conversion in progress. Setting this bit starts an ADC conversion cycle.
    // bit 0 - 1 = ADC module is operating
    ADCON0 = 0B01000011;    // See DS41270E-page 30 of the datasheet
    OPTION = 0B10011111;    // See DS40001239F-page 16 of the datasheet
    TRIS = 0B00000001;      // Set GP1 and GP2 as output        

  
    GP1 = 1;  // Green
    GP2 = 0;  // Red  
    while (1) {
        uint8_t gasLevel = readADC();
        if (gasLevel > 210) {
            GP2 = 1;
            GP1 = 0;
        } else if (gasLevel > 127) {
            GP1 = GP2 = 1;
            DelayMS(100);  
            GP1 = GP2 = 0;
        } else {    
            GP2 = 0;
            GP1 = 1;        
        } 
        DelayMS(100);
    }
}
