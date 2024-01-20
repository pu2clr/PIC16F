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

void inline initADC() {
    TRISIO = 0b00011000;          // input setup - GP4/AN3  
    ANSEL =  0b00011000;          // AN3 as analog input
    ADCON0 = 0b10001101;          // Right justified; VDD;  01 = Channel 03 (AN3); A/D converter module is 
}

unsigned inline char readADC() {
    ADCON0bits.GO = 1;           // Start conversion
    while (ADCON0bits.GO_nDONE); // Wait for conversion to finish
    // Assuming that the body's maximum temperature will not exceed 127 (about 62 degrees Celsius).
    return ADRESL; // In this case, ADRESL was ignored.  
}

/**
 * Turns All LEDS Off 
 */
void inline AllOff() {
    GPIO =  0;
}

/**
 * Turns Green LED On
 */
void inline GreenOn() {
    AllOff();
    GPIO =  1;
}

/**
 * Turns Yellow LED On
 */
void inline YellowOn() {
    AllOff();
    GPIO =  2;
}

/**
 * Turns Red LED On
 */
void RedOn() {
    AllOff();
    GPIO =  4;
}

void main() {
    GPIO =  0x0;    // Turns all GPIO pins low
    initADC();
    while (1) {
        unsigned char value = readADC();
         // To optimize accuracy, it might be necessary to perform calibration in order to 
        // determine a more precise value. the ADC vales 77 is near to 37 degree Celsius in my experiment
        if ( value == 77)  { 
            YellowOn();
            __delay_ms(2000);
        }
        else if ( value > 77 )
            RedOn();
        else
            GreenOn();
        __delay_ms(100); 
    }
}




