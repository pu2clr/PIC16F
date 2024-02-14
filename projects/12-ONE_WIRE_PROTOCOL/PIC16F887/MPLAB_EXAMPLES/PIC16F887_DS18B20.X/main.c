/*
 * PIC16F887 and DS18B20 (1-wire protocol) 
 *
 * Author: Ricardo Lima Caratti
 * Created on February 14, 2024
 */

#include <xc.h>
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


#define DS18B20_INTERFACE_PIN     RB1    // DS18B20 data pin interface    
#define DS18B20_INTERFACE_PIN_IO  TRISB1 // 0 is output and 1 is input
#define OUTPUT  0
#define INPUT   1


// Bitmap for Celsius degree symbol
unsigned char celsiusChar[8] = {
    0b11000, // **
    0b11000, // **  
    0b00000, //
    0b01111, //  ****
    0b01000, //  *
    0b01000, //  *
    0b01000, //  *
    0b01111 //  ****
};

/**
 * Initialize the DS18B20 device and wait for presence information. 
 * Returns 0 if the device is not present or not detected and 1 if the device is present. 
 */
unsigned char ds18b20_reset_and_presence() {

    DS18B20_INTERFACE_PIN = 0; // Sends reset pulse to the DS18B20 
    DS18B20_INTERFACE_PIN_IO = OUTPUT; // Configures DS18B20_INTERFACE_PIN pin as output
    __delay_us(480); // Waits for 48us
    DS18B20_INTERFACE_PIN_IO = INPUT; // Configures DS18B20_INTERFACE_PIN pin as input
    __delay_us(90); // Waits for 100us and than reads response in DS18B20_INTERFACE_PIN
    if (!DS18B20_INTERFACE_PIN) {
        __delay_us(390); //  
        return 1; // DS18B20 was detected
    }
    return 0; // DS18B20 was not detected
}


void ds18b20_write_byte(uint8_t value) {

    for (uint8_t i = 0; i < 8; i++) {
        uint8_t bitValue = (uint8_t) (value >> i);
        
        DS18B20_INTERFACE_PIN = 0;              
        DS18B20_INTERFACE_PIN_IO = OUTPUT;
        __delay_us(2); // Waits for 2us
        DS18B20_INTERFACE_PIN = (__bit) bitValue;
        __delay_us(70); // Waits 70us

        DS18B20_INTERFACE_PIN_IO = INPUT;
        __delay_us(2);
    }
}


/**
 * Reads a byte from DS18B20
 * @return the read byte
 */
uint8_t ds18b20_read_byte(void) {
    
    uint8_t byteValue = 0;
    uint8_t bitValue;

    for (uint8_t i = 0; i < 8; i++) { 
        DS18B20_INTERFACE_PIN = 0;
        DS18B20_INTERFACE_PIN_IO = OUTPUT; 
        __delay_us(2);
        DS18B20_INTERFACE_PIN_IO = INPUT; 
        __delay_us(6); 
        bitValue = DS18B20_INTERFACE_PIN; 
        __delay_us(90);             
        byteValue |= bitValue << i;
    }
    return byteValue;
}

unsigned char ds18b20_read(uint16_t *raw_temp_value) {
    if (!ds18b20_reset_and_presence()) // send start pulse
        return 0; // return 0 if error

    ds18b20_write_byte(0xCC); // send skip ROM command
    ds18b20_write_byte(0x44); // send start conversion command

    while (ds18b20_read_byte() == 0); // wait for conversion complete

    if (!ds18b20_reset_and_presence()) // send start pulse
        return 0; // return 0 if error

    ds18b20_write_byte(0xCC); // send skip ROM command
    ds18b20_write_byte(0xBE); // send read command

    // read temperature LSB byte and store it on raw_temp_value LSB byte
    *raw_temp_value = ds18b20_read_byte();
    // read temperature MSB byte and store it on raw_temp_value MSB byte
    *raw_temp_value |= (uint16_t) (ds18b20_read_byte() << 8);

    return 1; // OK --> return 1
}

/*
void convertToChar(uint16_t value, char *strValue, uint8_t len) {
    char d;
    for (int i = (len - 1); i >= 0; i--) {
        d = value % 10;
        value = value / 10;
        strValue[i] = d + 48;
    }
    strValue[len] = '\0';
}
*/ 

void main() {
    unsigned char i;
    char strTempValue[10];
    uint16_t ds18b20Temp;

    ANSELH = 0;

    // Define the LCD pin configuration for PIC16F887
    TRISC = 0; // You need to set this register as output
    Lcd_PinConfig lcd = {
        .port = &PORTC, // Assuming you're using PORTC for LCD on PIC16F887
        .rs_pin = 2, // RC2 for RS
        .en_pin = 3, // RC3 for EN
        .d4_pin = 4, // RC4 for D4
        .d5_pin = 5, // RC5 for D5
        .d6_pin = 6, // RC6 for D6
        .d7_pin = 7 // RC7 for D7
    };

    // Initialize the LCD
    Lcd_Init(&lcd);

    // Loading the custom character
    Lcd_CreateCustomChar(&lcd, 0, celsiusChar);

    Lcd_Clear(&lcd);

    // Display message
    Lcd_SetCursor(&lcd, 1, 1);
    Lcd_WriteString(&lcd, "PIC16F887 1-wire");
    Lcd_SetCursor(&lcd, 2, 1);
    Lcd_WriteString(&lcd, "with DS18B20");
    __delay_ms(5000);
    Lcd_Clear(&lcd);


    while (1) {
         if (ds18b20_read(&ds18b20Temp)) {
            if (ds18b20Temp & 0x8000) // check if the temperature is above 0
            {
                strTempValue[0] = '-';
                ds18b20Temp = (~ds18b20Temp) + 1;
            } else strTempValue[0] = '+';
        }
        strTempValue[1] = ((ds18b20Temp >> 4) / 10) % 10 + '0'; // put tens digit
        strTempValue[2] = (ds18b20Temp >> 4) % 10 + '0'; // put ones digit
        strTempValue[3] = '\0';

        Lcd_SetCursor(&lcd, 1, 1);
        Lcd_WriteString(&lcd, "Temp: ");
        Lcd_SetCursor(&lcd, 1, 7);
        Lcd_WriteString(&lcd, strTempValue);
        Lcd_SetCursor(&lcd, 1, 11);
        Lcd_WriteCustomChar(&lcd, 0);

        __delay_ms(2000);
    }
}
