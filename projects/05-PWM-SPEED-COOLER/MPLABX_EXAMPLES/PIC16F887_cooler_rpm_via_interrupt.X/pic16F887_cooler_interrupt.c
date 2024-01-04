#include <xc.h>
#include <stdio.h> // Necessário para sprintf
#include "../../pic16flcd.h"

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

#define TACH_PIN PORTBbits.RB0 // Tachometer signal connected to RB0


volatile unsigned int pulseCount = 0;


void __interrupt() ISR() {
    if (INTCONbits.INTF) {  // Check if the INT0 interrupt occurred
        pulseCount++;       // Increment pulse count for each tachometer pulse
        INTCONbits.INTF = 0; // Clear the INT0 interrupt flag
    }
}


void initPulseReader() {
    TRISBbits.TRISB0 = 1;   // Set RB0 as input
    // Enable external interrupt INT0
    INTCONbits.INTE = 1;    // Enable INT0 interrupt
    INTCONbits.INTF = 0;    // Clear INT0 interrupt flag
    INTCONbits.GIE = 1;     // Enable global interrupts
}


void initPWM() {
    T2CON = 0x07;
    PR2 = 0xFF; // Set PWM period
    CCP1CON = 0x0C; // Set PWM mode and duty cycle to 0
    CCPR1L = 0x00;
    T2CON = 0x04; // Timer2 ON, Prescaler set to 1
}


void initADC() {
    TRISC = 0;
    ANSEL = 0x01; // RA0/AN0 is analog input
    ADCON0 = 0x01; // Enable ADC, channel 0
    ADCON1 = 0x80; // Right justified, Fosc/32
}

unsigned int readADC() {
    ADCON0bits.GO = 1; // Start conversion
    while (ADCON0bits.GO_nDONE); // Wait for conversion to finish
    return (unsigned int) ((ADRESH << 8) + ADRESL); // Combine result into a single word
}

double readTemperature() {
    unsigned int adcValue = readADC();
    double voltage = (adcValue / 1024.0) * 5.0; // Convert ADC value to voltage
    return voltage / 0.01; // Convert voltage to temperature in Celsius
}

long map(long x, long in_min, long in_max, long out_min, long out_max) {
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}


void main() {

    initPWM();
    initADC();
    initPulseReader();


    // Defines the LCD pin configuration for PIC16F887

    Lcd_PinConfig lcd = {
        .port = &PORTD, // Assuming you're using PORTD for LCD on PIC16F887
        .rs_pin = 2, // RD2 for RS
        .en_pin = 3, // RD3 for EN
        .d4_pin = 4, // RD4 for D4
        .d5_pin = 5, // RD5 for D5
        .d6_pin = 6, // RD6 for D6
        .d7_pin = 7 // RD7 for D7
    };

    // Initialize the LCD
    TRISD = 0;

    Lcd_Init(&lcd);
    Lcd_Clear(&lcd);

    // Display message
    Lcd_SetCursor(&lcd, 1, 1);
    Lcd_WriteString(&lcd, "COOLER RPM Counter");
    Lcd_SetCursor(&lcd, 2, 1);
    Lcd_WriteString(&lcd, "RPM: ");


    while (1) {
        char rpm[10];
        unsigned int adcResult = readADC();
        // __delay_ms(1000);
        unsigned int fanRPM = (pulseCount / 2) * 60;
        
        sprintf(rpm, "%4u", fanRPM);
        Lcd_SetCursor(&lcd, 2, 6);
        Lcd_WriteString(&lcd, rpm);

        // Speed control via potentiometer
        CCPR1L = (unsigned char) map(adcResult, 0, 930,0,255);
        // CCPR1L = adcResult >> 2; // Scale ADC result to fit PWM duty cycle register
        pulseCount = 0;      // Reset pulse count
        __delay_ms(10);
    }
}
