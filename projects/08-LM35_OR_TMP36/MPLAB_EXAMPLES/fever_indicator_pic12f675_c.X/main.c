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
    ANSEL = 0b00000010;           // AN1 is analog input
    ADCON0 = 0x01;               // Enable ADC, channel 0
}

unsigned int inline readADC() {
    ADCON0bits.GO = 1;           // Start conversion
    while (ADCON0bits.GO_nDONE); // Wait for conversion to finish
    return ((ADRESH << 8) + ADRESL); // Combine result into a single word
}

unsigned int inline readTemperature() {
    unsigned int adcValue = readADC();
    unsigned int voltage = (adcValue * 5) / 1024; // Convert ADC value to voltage
    return  voltage * 10 ;

}

void main() {
    TRISIO = 0x00; // 
    GPIO =  0b00000010; // turns GP1 (pin 6) as input and the others output
    
    initADC();
         
    while (1) {
        unsigned int temperature = readTemperature();
        if (temperature > 1 )
            GP0 = 1;
        else 
            GP0 = 0;
        __delay_ms(1000); 
    }
}

