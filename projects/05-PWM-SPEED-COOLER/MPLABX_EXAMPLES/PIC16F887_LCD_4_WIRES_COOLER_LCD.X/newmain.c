#include <xc.h>
#include <stdio.h>
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

void initPWM() {
    OSCCON = 0x60;
    TRISC = 0; // Set port to output   
    T2CON = 0x07;
    PR2 = 0xFF; // Set PWM period
    CCP1CON = 0x0C; // Set PWM mode and duty cycle to 0
    CCPR1L = 0x00;
    T2CON = 0x04; // Timer2 ON, Prescaler set to 1
}

void initADC() {
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
    // double tmp;
    double voltage = (float) ((float) adcValue / 1024.0) * 5.0; // Convert ADC value to voltage
    return(float) voltage / (float) 0.01; // Convert voltage to temperature in (Celsius?)
    // return (tmp - 32)/9 * 5;
    
}

void main() {
    initPWM();
    initADC();

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
    Lcd_WriteString(&lcd, "Cooler & LM35");
    Lcd_SetCursor(&lcd, 2, 1);
    Lcd_WriteString(&lcd, "Temp:");


    while (1) {
        char strTemp[6];
        double temperature;
        double sum = 0;
        
        // Calculate the 
        for (unsigned char i =0; i < 10; i++ ) {
            sum +=  readTemperature();
            __delay_ms(100);
        }
        temperature = sum / 10.0;

        sprintf(strTemp, "%4u", (int) temperature);
        Lcd_SetCursor(&lcd, 2, 7);
        Lcd_WriteString(&lcd, strTemp );

        if (temperature > 33.0)
            CCPR1L = 200;
        else if (temperature > 30.0)
            CCPR1L = 60;
        else if (temperature > 26.0)
            CCPR1L = 35;
        else if (temperature > 20.0)
            CCPR1L = 15;
        __delay_ms(2000);
    }
}
