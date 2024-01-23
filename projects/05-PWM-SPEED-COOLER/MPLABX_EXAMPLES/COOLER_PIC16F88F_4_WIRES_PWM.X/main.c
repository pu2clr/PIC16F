/**
 * 4-Wires Cooler controller with PIC16F887
 * 
 * Author: Ricardo Lima Caratti
 * Jan 2024
 */
#include <xc.h>

// Configuration Bits
#pragma config FOSC = INTRC_NOCLKOUT  // Internal Oscillator, no clock out
#pragma config WDTE = OFF             // Watchdog Timer disabled
#pragma config PWRTE = OFF            // Power-up Timer disabled
#pragma config MCLRE = ON             // MCLR pin function is digital input
#pragma config BOREN = ON             // Brown-out Reset enabled
#pragma config LVP = OFF              // Low Voltage Programming disabled
#pragma config CPD = OFF              // Data EEPROM Memory Code Protection disabled
#pragma config CP = OFF               // Flash Program Memory Code Protection disabled

#define _XTAL_FREQ 4000000  // 4 MHz Crystal Frequency

void initPWM() {
    OSCCON = 0x60;
    TRISC = 0;                   // Set port to output   
    T2CON = 0x07;
    PR2 = 0xFF;                  // Set PWM period
    CCP1CON = 0x0C;              // Set PWM mode and duty cycle to 0
    CCPR1L = 0x00;
    T2CON = 0x04;                // Timer2 ON, Prescaler set to 1
}

void initADC() {
    ANSEL = 0x01;                // RA0/AN0 is analog input
    ADCON0 = 0x01;               // Enable ADC, channel 0
    ADCON1 = 0x80;               // Right justified, Fosc/32
}

unsigned int readADC() {
    ADCON0bits.GO = 1;           // Start conversion
    while (ADCON0bits.GO_nDONE); // Wait for conversion to finish
    return (unsigned int) ((ADRESH << 8) + ADRESL); // Combine result into a single word
}

float readTemperature() {
    unsigned int adcValue = readADC();
    float voltage = (float) ((float) adcValue / 1024.0) * 5.0; // Convert ADC value to voltage
    return (float) voltage / (float) 0.01; // Convert voltage to temperature in Celsius
}

void main() {   
    initPWM();
    initADC();

    CCPR1L = 100;       // Turn the Cooler on for 5 seconds
    __delay_ms(5000);
    CCPR1L = 0;
    
    while(1) {
        float temperature = readTemperature();
        if (temperature > 33.0)
            CCPR1L = 200;
        else if (temperature > 30.0)
            CCPR1L = 18;      
        else if (temperature > 20.0)
            CCPR1L = 9;
        __delay_ms(2000);          
    }
}
