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


#define DS18B20_PIN      RB1    // DS18B20 data pin interface    
#define DS18B20_PIN_Dir  TRISB1 // 0 is output and 1 is input


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



// DS18B20 - Init dialog 

__bit ds18b20_start() {
    DS18B20_PIN = 0; // send reset pulse to the DS18B20 sensor
    DS18B20_PIN_Dir = 0; // configure DS18B20_PIN pin as output
    __delay_us(500); // wait 500 us

    DS18B20_PIN_Dir = 1; // configure DS18B20_PIN pin as input
    __delay_us(100); // wait 100 us to read the DS18B20 sensor response

    if (!DS18B20_PIN) {
        __delay_us(400); // wait 400 us
        return 1; // DS18B20 sensor is present
    }

    return 0; // connection error
}

void ds18b20_write_bit(uint8_t value) {
    DS18B20_PIN = 0;
    DS18B20_PIN_Dir = 0; // configure DS18B20_PIN pin as output
    __delay_us(2); // wait 2 us

    DS18B20_PIN = (__bit) value;
    __delay_us(80); // wait 80 us

    DS18B20_PIN_Dir = 1; // configure DS18B20_PIN pin as input
    __delay_us(2); // wait 2 us
}

void ds18b20_write_byte(uint8_t value) {
    for (uint8_t i = 0; i < 8; i++)
        ds18b20_write_bit(value >> i);
}

__bit ds18b20_read_bit(void) {
    static __bit value;

    DS18B20_PIN = 0;
    DS18B20_PIN_Dir = 0; // configure DS18B20_PIN pin as output
    __delay_us(2);

    DS18B20_PIN_Dir = 1; // configure DS18B20_PIN pin as input
    __delay_us(5); // wait 5 us

    value = DS18B20_PIN; // read and store DS18B20 state
    __delay_us(100); // wait 100 us

    return value;
}

uint8_t ds18b20_read_byte(void) {
    uint8_t value = 0;

    for (uint8_t i = 0; i < 8; i++)
        value |= ds18b20_read_bit() << i;

    return value;
}

__bit ds18b20_read(uint16_t *raw_temp_value) {
    if (!ds18b20_start()) // send start pulse
        return 0; // return 0 if error

    ds18b20_write_byte(0xCC); // send skip ROM command
    ds18b20_write_byte(0x44); // send start conversion command

    while (ds18b20_read_byte() == 0); // wait for conversion complete

    if (!ds18b20_start()) // send start pulse
        return 0; // return 0 if error

    ds18b20_write_byte(0xCC); // send skip ROM command
    ds18b20_write_byte(0xBE); // send read command

    // read temperature LSB byte and store it on raw_temp_value LSB byte
    *raw_temp_value = ds18b20_read_byte();
    // read temperature MSB byte and store it on raw_temp_value MSB byte
    *raw_temp_value |= (uint16_t) (ds18b20_read_byte() << 8);

    return 1; // OK --> return 1
}

void convertToChar(uint16_t value, char *strValue, uint8_t len) {
    char d;
    for (int i = (len - 1); i >= 0; i--) {
        d = value % 10;
        value = value / 10;
        strValue[i] = d + 48;
    }
    strValue[len] = '\0';
}

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
        uint16_t temAux;

        if (ds18b20_read(&ds18b20Temp)) {
            if (ds18b20Temp & 0x8000) // check if the temperature is above 0
            {
                strTempValue[0] = '-'; 
                ds18b20Temp = (~ds18b20Temp) + 1; 
            } else strTempValue[0] = '+';  
        }
        strTempValue[1] = ( (ds18b20Temp >> 4) / 10 ) % 10 + '0';  // put tens digit
        strTempValue[2] =   (ds18b20Temp >> 4)        % 10 + '0';  // put ones digit
        strTempValue[3] = '\0';
        
        Lcd_SetCursor(&lcd, 1, 1);
        Lcd_WriteString(&lcd, "Temp: ");
        Lcd_SetCursor(&lcd, 1, 7);
        Lcd_WriteString(&lcd,strTempValue);
        Lcd_SetCursor(&lcd, 1, 11);
        Lcd_WriteCustomChar(&lcd, 0);

        __delay_ms(5000);
    }
}
