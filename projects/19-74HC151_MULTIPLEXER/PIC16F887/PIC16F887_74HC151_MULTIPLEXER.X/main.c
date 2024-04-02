/**
 * UNDER CONSTRUCTION...
 * Author: Ricardo Lima Caratti
 * Feb/2024 
 */

#include <xc.h>
#include <stdio.h>
#include <math.h>
#include "pic16flcd.h"

#pragma config FOSC = INTRC_NOCLKOUT
#pragma config WDTE = OFF       // Watchdog Timer disabled 
#pragma config PWRTE = OFF      // Power-up Timer disable
#pragma config MCLRE = ON       // MCLR pin function is digital input
#pragma config BOREN = OFF      // Brown-out Reset enabled
#pragma config LVP = OFF        // Low Voltage Programming disabled
#pragma config CPD = OFF        // Data EEPROM Memory Code Protection disabled
#pragma config CP = OFF         // Flash Program Memory Code Protection disabled

#define _XTAL_FREQ 4000000      // Frequency (Clock)

#define NUM_SAMPLE 10

/**
 Custom Char (Smile / happy face)
 */
unsigned char smile[8] = {
    0b00000,    
    0b01010,    
    0b01010,    
    0b00000,
    0b10001,
    0b01110,
    0b00000,
    0b00000
};

/**
 Custom char (sad face)
 */
unsigned char sad[8] = {
    0b00000,
    0b01010,
    0b01010,
    0b00000,
    0b00000,
    0b01110,
    0b10001,
    0b00000
};


void initADC() {
    ANSEL = 0x01; // RA0/AN0 is analog input
    ADCON0 = 0x01; // Enable ADC, channel 0
    ADCON1 = 0x80; // Right justified, Fosc/32
}

uint16_t readADC() {
    ADCON0bits.GO = 1; // Start conversion
    while (ADCON0bits.GO_nDONE); // Wait for conversion to finish
    return (unsigned int) ((ADRESH << 8) + ADRESL); // Combine result into a single word
}


/**
 * Selects the sensor and performs the reading.
 * @param  - ensorNumber - Sensor number to be read
 * @return - Average of values from a sample 
 */
uint16_t getSensorData(uint8_t sensorNumber) {
    uint16_t sumValue = 0;
 
    // Selects the sensor 
    sensorNumber = (uint8_t) (sensorNumber << 1);
    // GPIO = (GPIO & 0B11111001) | sensorNumber; // Sets sensor Number to GP1 and GP2 (0, 1, 2 or 3)
    for (uint8_t i = 0; i < NUM_SAMPLE; i++ ) { 
        sumValue += readADC();
        __delay_us(10);
    }
    // Returns the average of values get from adcRead
    return sumValue / NUM_SAMPLE;
}


float getIrms() {
    
  uint16_t sumValue = 0;  
  for ( uint8_t i = 0; i < NUM_SAMPLE; i++ ) { 
      sumValue += readADC();
  } 

  
  return sqrt(sumValue / NUM_SAMPLE);    
}

void main() {

    char strAux[16];
    initADC();
    
    TRISC = 0B00000001; // PORT C: RC0 as input and all other pins as output
    

    // Define the LCD pin configuration for PIC16F887
    
    Lcd_PinConfig lcd = {
        .port = &PORTC, // Assuming you're using PORTC for LCD on PIC16F887
        .rs_pin = 2, // RC2 for RS
        .en_pin = 3, // RC3 for EN
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
    Lcd_WriteString(&lcd, "MQ-2 Gas");
    Lcd_SetCursor(&lcd, 2, 1);
    Lcd_WriteString(&lcd, "Sensor");

    // Creating the character
    Lcd_CreateCustomChar(&lcd, 0, smile);
    Lcd_CreateCustomChar(&lcd, 1, sad);    
    
    __delay_ms(3000);
    
    while(1) {
        
    }
}