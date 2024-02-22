/**
 * 
 */

#include <xc.h>
#include "pic16flcd.h"

#pragma config FOSC = INTOSCIO  // Internal oscillator.
#pragma config WDTE = OFF       // Watchdog Timer disabled 
#pragma config PWRTE = OFF      // Power-up Timer disable
#pragma config MCLRE = ON       // MCLR pin function is digital input
#pragma config BOREN = OFF      // Brown-out Reset enabled
#pragma config LVP = OFF        // Low Voltage Programming disabled
#pragma config CPD = OFF        // Data EEPROM Memory Code Protection disabled
#pragma config CP = OFF         // Flash Program Memory Code Protection disabled
#define _XTAL_FREQ 4000000      // internal clock


// Bitmap for Celsius degree symbol
unsigned char celsiusChar[8] = {
    0b11000, // **
    0b11000, // **  
    0b00000, //
    0b01111, //  ****
    0b01000, //  *
    0b01000, //  *
    0b01111, //  ****
    0b00000 //  
};

/**
 * @brief Gets the current byte available from DHT11 sensor 
 * @return  byte read or -1 if error 
 */
char readByteFromDHT11() {

    return 0;
}

/**
 * @brief Read all current data from DHT11 (humidity, temperature and checksum)
 * @param humidity     - Humidity 
 * @param fracHumidity - Fractional part of the humidity
 * @param temp         - Temperature 
 * @param fracTemp     - Fractional part of the temperature 
 * @return 1 if success or 0 if error
 */
uint8_t readDataFromDHT11(uint8_t *humidity, uint8_t *fracHumidity, uint8_t *temp, uint8_t *fracTemp) {

    return 0;
}

/**
 * Converts a integer to an array of char
 * @param value     Integer value to be converted
 * @param strValue  point to char array
 * @param len       number of digits to be converted    
 */
void convertToChar(uint8_t value, char *strValue, uint8_t len) {
    char d;
    for (int i = (len - 1); i >= 0; i--) {
        d = value % 10;
        value = value / 10;
        strValue[i] = d + 48;
    }
    strValue[len] = '\0';
}

void main() {
    uint8_t humidity, fracHumidity, temperature, fracTemperature;
    char strOut[8];
    char i;
    TRISB = 0x00; // You need to set this register as output
    // Define the LCD pin configuration for PIC16F628A
    Lcd_PinConfig lcd = {
        .port = &PORTB, // Port to be used to control the LCD 
        .rs_pin = 2, // RB2 for RS
        .en_pin = 3, // RB3 for EN
        .d4_pin = 4, // RB4 for D4
        .d5_pin = 5, // RB5 for D5
        .d6_pin = 6, // RB6 for D6
        .d7_pin = 7 // RB7 for D7
    };
    Lcd_Init(&lcd); // Initialize the LCD
    Lcd_Clear(&lcd);
    Lcd_SetCursor(&lcd, 1, 1); // Display message (Line 1 and Column 1)
    Lcd_WriteString(&lcd, "T.:");
    Lcd_SetCursor(&lcd, 2, 1); // Display message (Line 2 and Column 1)
    Lcd_WriteString(&lcd, "H.:");
    Lcd_CreateCustomChar(&lcd, 0, celsiusChar);

    while (1) {
        if (readByteFromDHT11(&humidity, &fracHumidity, &temperature, &fracTemperature)) {
            convertToChar(temperature, strOut, 2);
            strOut[2] = '.';
            convertToChar(fracTemperature, &strOut[3], 2);
            Lcd_SetCursor(&lcd, 1, 5);
            Lcd_WriteString(&lcd, strOut);
        }
    }
}

