#include <xc.h>

// 
#pragma config FOSC = INTRCIO   // Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = OFF      // Power-Up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = ON       // GP3/MCLR pin function select (GP3/MCLR pin function is MCLR)
#pragma config BOREN = ON       // Brown-out Detect Enable bit (BOD enabled)
#pragma config CP = OFF         // Code Protection bit (Program Memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)

#define _XTAL_FREQ 4000000      // internal clock


void initADC() {
    TRISIO = 0b00000010;
    ANSEL =  0b00000010;          // AN1 is analog input
    ADCON0 = 0b10000101;          // Right justified; VDD;  01 = Channel 01 (AN1); A/D converter module is operating
}

unsigned int readADC() {
    ADCON0bits.GO = 1;           // Start conversion
    while (ADCON0bits.GO_nDONE); // Wait for conversion to finish
    // return (unsigned int) (ADRESH << 8) + (unsigned int) ADRESL; // Combine result into a single word
    return ADRESL;
}

void main() {
    TRISIO = 0x00;  // Sets All GPIO as output 
    GPIO =  0x0;    // Turns all GPIO pins low
    
    initADC();
    
    while (1) {
        unsigned int value = readADC();
        if ( value >= 77)
            GP0 = 1;    // Turn GP0 HIGH
        else
            GP0 = 0;    // Turn GP0 LOW
        __delay_ms(1000); 
    }
}

