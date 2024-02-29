/**
 * My PIC Journey  - MQ-2 Gas sensor and PIC12F675
 * 
 * ATTENTION: This experiment is solely intended to demonstrate the interfacing of an MQ series gas sensor 
 * with PIC microcontrollers. The gas concentration values and thresholds used in the example programs have 
 * been arbitrarily set to illustrate high, medium, or low gas concentration levels. However, it is crucial 
 * to emphasize that these values may not accurately reflect the real concentrations that pose a health risk. 
 * Therefore, if you plan to use the examples provided, it is strongly recommended to consult the gas sensor's Datasheet. 
 * This is essential to ascertain the exact values that define dangerous, tolerable, or low gas concentrations. 
 * 
 * Author: Ricardo Lima Caratti
 * Feb/2024 
 */


#include <xc.h>

#pragma config FOSC = INTRCIO   // Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = OFF      // Power-Up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = ON       // GP3/MCLR pin function select (GP3/MCLR pin function is MCLR)
#pragma config BOREN = ON       // Brown-out Detect Enable bit (BOD enabled)
#pragma config CP = OFF         // Code Protection bit (Program Memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)

#define _XTAL_FREQ 4000000      // internal clock

void inline initADC() {
    TRISIO = 0b00011000;          // input setup - GP4/AN3   
    ANSEL =  0b00011000;          // AN0 as analog input
    ADCON0 = 0b10001101;          // Right justified; VDD;  01 = Channel 03 (AN3); A/D converter module is 
}

unsigned inline int readADC() {
    ADCON0bits.GO = 1;              // Start conversion
    while (ADCON0bits.GO_nDONE);    // Wait for conversion to finish
    return ((unsigned int) ADRESH << 8) + (unsigned int) ADRESL;  // return the ADC 10 bit integer value 1024 ~= 5V, 512 ~= 2.5V, ... 0 = 0V
}



void main() {
    GPIO =  0x0;    // Turns all GPIO pins low
    initADC();
    while (1) {
        unsigned int gasLevel = readADC();
        if (gasLevel > 800)                   // TODO: Check the right level
            GPIO = 0B00000100;       // Red on
        else if (gasLevel < 400) 
            GPIO = 0B00000001;       // Gren on
        else
            GPIO = 0B00000010;       // Yellow on

        __delay_ms(2000); 
    }
}