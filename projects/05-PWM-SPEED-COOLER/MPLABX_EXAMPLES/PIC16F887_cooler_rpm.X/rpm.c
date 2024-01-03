#include <xc.h>
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


void initPWM() {
    OSCCON = 0x60;                // configures the internal oscillator frequency (4 MHz) 
    TRISC = 0;                   // Set port to output   
    T2CON = 0x07;
    PR2 = 0xFF;                  // Set PWM period
    CCP1CON = 0x0C;              // Set PWM mode and duty cycle to 0
    CCPR1L = 0x00;
    T2CON = 0x04;                // Timer2 ON, Prescaler set to 1
}

/**
 * RPM reader setup
 */
void initRPM() {

    TRISBbits.TRISB0 = 1;   // Set RB0 as input
    ANSELH = 0x00;          // Disable analog inputs on PORTB

    OPTION_REGbits.T0CS = 0; // Timer0 Clock Source: Internal instruction cycle clock (CLKO)
    OPTION_REGbits.PSA = 0; // Prescaler is assigned to the Timer0 module
    OPTION_REGbits.PS = 0b111; // Prescaler 1:256
    TMR0 = 0; // Reset Timer0
}


unsigned int countPulses() {
    unsigned int pulseCount = 0;
    unsigned char lastState = TACH_PIN;
    unsigned char currentState;

    TMR0 = 0; // Reset Timer0
    INTCONbits.TMR0IF = 0; // Clear Timer0 overflow flag

    while (!INTCONbits.TMR0IF) { // Wait for Timer0 to overflow
        currentState = TACH_PIN;

        if (currentState != lastState && currentState == 1) { // Detect rising edge
            pulseCount++;
        }
        lastState = currentState;
    }

    return pulseCount;
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

double readTemperature() {
    unsigned int adcValue = readADC();
    double voltage =  (adcValue / 1024.0) * 5.0; // Convert ADC value to voltage
    return voltage /  0.01; // Convert voltage to temperature in Celsius
}

void main() {   
    initPWM();
    initADC();
    initRPM();


    // Defines the LCD pin configuration for PIC16F887
    TRISC = 0; // You need to set this register as output
    Lcd_PinConfig lcd = {
        .port = &PORTC, // Assuming you're using PORTC for LCD on PIC16F887
        .rs_pin = 1, // RC1 for RS
        .en_pin = 2, // RC2 for EN
        .d4_pin = 4, // RC4 for D4
        .d5_pin = 5, // RC5 for D5
        .d6_pin = 6, // RC6 for D6
        .d7_pin = 7  // RC7 for D7
    };

    // Initialize the LCD
    Lcd_Init(&lcd);
    Lcd_Clear(&lcd);
    
    // Display message
    Lcd_SetCursor(&lcd, 1, 1);
    Lcd_WriteString(&lcd, "COOLER RPM Counter");
    
    
    while(1) {
        double temperature = readTemperature();
        unsigned int pulses = countPulses();
        unsigned int fanRPM = (unsigned int) ( (pulses / 2) * (60 / (256.0 / _XTAL_FREQ * 256))); // Calculate RPM
        // fanRPM now contains the fan's RPM

        if (temperature > 33.0)
            CCPR1L = 150;
        else if (temperature > 30.0)
            CCPR1L = 18;      
        else 
            CCPR1L = 9;
        __delay_ms(2000);          
    }
}
