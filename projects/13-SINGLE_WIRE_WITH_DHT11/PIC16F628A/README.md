# PIC16F628A and DHT11 example

This project uses a DHT11 sensor to  measure humidity and temperature. This application with the PIC16F628A uses a LCD16x2 to show the current temperature and humidity. 

## Content

1. [Schematic](#pic16f628a-dht11-and-lcd16x2-schematic)
    * [KiCad schematic](./KiCad/)
2. [PIC16F628A PINOUT](#pic16f628a-pinout)    
3. [DHT11 PINOUT](#dht11-pinout)    
4. [Source code in C](#source-code-in-c)
5. [MPLAB X IDE project](./MPLAB_EXAMPLE/)    
6. [References](#references)


## PIC16F628A, DHT11 and LCD16x2 Schematic

![PIC16F628A, DHT11 and LCD16x2 Schematic](./schematic_pic16f628a_dht11_lcd16x2.jpg)


## PIC16F628A PINOUT

![PIC16F628A PINOUT](./../../../images/PIC16F628A_PINOUT.png)


## DHT11 PINOUT 

![DHT11 PINOUT](../images/DHT11_V1.jpg)

| PIN # | DESCRIPTION | 
| ----- | ----------- | 
|   1   | GND (-)     | 
|   2   | DATA / SIGNAL | 
|   3   | VCC (+)     | 


## Source code in C

```cpp
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

#define DHT11_PIN   RB0
#define DHT11_PIN_INPUT     TRISB0 = 1
#define DHT11_PIN_OUTPUT    TRISB0 = 0

#define CHECK_SUM_ERROR     1
#define DEVICE_NOT_PRESENT  2
#define READOK              0 


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
uint8_t readByteFromDHT11() {
    uint8_t dht11Byte = 0;
    for (uint8_t i = 0; i < 8; i++) {
        do {
            __delay_us(2);
        } while (DHT11_PIN == 0);
        __delay_us(30);
        if (DHT11_PIN == 1)
            dht11Byte |= (uint8_t) (1 << (7 - i));
        do {
            __delay_us(2);
        } while (DHT11_PIN == 1);
    }
    return dht11Byte;
}

/**
 * @brief Read all current data from DHT11 (humidity, temperature and checksum)
 * @param humidity     - Humidity 
 * @param fracHumidity - Fractional part of the humidity
 * @param temp         - Temperature 
 * @param fracTemp     - Fractional part of the temperature 
 * @return 1 if success or 0 if error
 */

int8_t readDataFromDHT11(uint8_t *humidity, uint8_t *fracHumidity, uint8_t *temp, uint8_t *fracTemp) {
    uint8_t checkSum;
    uint8_t detected = 0;

    // Start communication process with DHT11 device
    DHT11_PIN_OUTPUT;   // Set pin connected to DHT11 as output
    DHT11_PIN = 0; 
    __delay_ms(20);     // make the bus down for 18ms
    DHT11_PIN = 1;      // make the bus high for 40us    
    __delay_us(30);
    DHT11_PIN_INPUT;    // Set pin connected to DHT11 as input

    for (uint8_t i = 0; i < 13; i++) {
        if (DHT11_PIN == 0) {
            detected = 1;
            break;
        }
        __delay_us(2);
    }
    if (detected == 0) return DEVICE_NOT_PRESENT;

    __delay_us(80);
    
    //  Wait the DHT11 release the bus
    do {
        __delay_us(2);
    } while (DHT11_PIN == 1);

    
    // Now read data from DHT11 device
    *humidity = readByteFromDHT11();
    *fracHumidity = readByteFromDHT11();
    *temp = readByteFromDHT11();
    *fracTemp = readByteFromDHT11();
    checkSum = readByteFromDHT11();

    if (checkSum != (*humidity + *fracHumidity + *temp + *fracTemp))
        return CHECK_SUM_ERROR;

    return READOK;
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
        int8_t status;
        __delay_ms(5000);
        status = readDataFromDHT11(&humidity, &fracHumidity, &temperature, &fracTemperature);
        if (status == READOK) {
            convertToChar(temperature, strOut, 2);
            strOut[2] = '.';
            convertToChar(fracTemperature, &strOut[3], 2);
            Lcd_SetCursor(&lcd, 1, 5);
            Lcd_WriteString(&lcd, strOut);
            Lcd_SetCursor(&lcd, 1, 10);
            Lcd_WriteCustomChar(&lcd, 0);
            convertToChar(humidity, strOut, 2);
            strOut[2] = '.';
            convertToChar(fracHumidity, &strOut[3], 2);
            strOut[3] = '%';
            strOut[4] = '\0';
            Lcd_SetCursor(&lcd, 2, 5);
            Lcd_WriteString(&lcd, strOut);
        } else {
            Lcd_SetCursor(&lcd, 1, 5);
            Lcd_WriteString(&lcd, "Error!");
        }

    }
}



```


## References 

