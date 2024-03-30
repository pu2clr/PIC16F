/**
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


uint8_t PWM = 50;

void inline initADC() {
    TRISIO = 0b00000001;    // input setup - GP4/AN0   
    ANSEL = 0b00000001;     // AN0 as analog input
    ADCON0 = 0b10001101;    // Right justified; VDD;  01 = Channel 03 (AN0); A/D converter module is 
}

void initInterrupt() {
    // INTEDG: Interrupt Edge Select bit -  Interrupt will be triggered on the rising edge
    // Prescaler Rate: 1:64 - It generates about 73Hz (assigned to the TIMER0 module)
    OPTION_REG = 0B01000101; // see  data sheet (page 12)    
    // T0IE = 1; // TMR0: Overflow Interrupt 
    // GIE = 1; // GIE: Enable Global Interrupt
}

/**
 * Handle timer overflow
 */
void __interrupt() ISR(void) {
    if (T0IF) {
        if (GP5) {
            TMR0 = PWM;
            GP5 = 0;
        } else {
            TMR0 = 255 - PWM;
            GP5 = 1;
        }
        T0IF = 0;
    }
}

uint16_t readADC() {
    ADCON0bits.GO = 1; // Start conversion
    while (ADCON0bits.GO_nDONE); // Wait for conversion to finish
    return ((unsigned int) ADRESH << 8) + (unsigned int) ADRESL; // return the ADC 10 bit integer value 1024 ~= 5V, 512 ~= 2.5V, ... 0 = 0V
}

uint16_t getSensorData(uint8_t sensorNumber) {
    sensorNumber = (uint8_t) (sensorNumber << 1);
    GPIO = (GPIO & 0B11111001) | sensorNumber;
    return readADC();
}


void alert(uint8_t sensorNumber) {
    // GIE = 1;    // Enable interrupt
    __delay_ms(100);
    for (uint8_t count = 0; count < 5; count++) {
        for (uint8_t led = 1; led <= sensorNumber; led++) {
            GP4 = 1;
            __delay_ms(500);
            GP4 = 0;
        }
        __delay_ms(10000);
    }
    // GIE = 0;    // Disable interrupt
}


void main() {
    GPIO = 0x0; // Turns all GPIO pins low

    initADC();
    initInterrupt();

    GP4 = 1;
    __delay_ms(2000);
    GP4 = 0;
    
    while (1) {
        for (uint8_t i = 0; i < 4; i++) {
            uint16_t sensorValue = getSensorData(i);
            if (sensorValue < 100 ) {
                alert(i);
            }
        }
        __delay_ms(100);
    }
}