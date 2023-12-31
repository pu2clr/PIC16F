/**
 * @file pic16flcd.c
 * @author Ricardo LIma Caratti (pu2clr@gmail.com)
 * @brief This library is a creation resulting from my learning journey about PIC microcontrollers. It is designed to control a 16x2 LCD
 * @version 1.0
 * @date 2023-12-30
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include "pic16flcd.h"
#include <stdbool.h>

#pragma config FOSC = INTOSCIO  // Internal oscillator.
#pragma config WDTE = OFF       // Watchdog Timer disabled 
#pragma config PWRTE = OFF      // Power-up Timer disable
#pragma config MCLRE = ON       // MCLR pin function is digital input
#pragma config BOREN = OFF      // Brown-out Reset enabled
#pragma config LVP = OFF        // Low Voltage Programming disabled
#pragma config CPD = OFF        // Data EEPROM Memory Code Protection disabled
#pragma config CP = OFF         // Flash Program Memory Code Protection disabled

#define _XTAL_FREQ 4000000      // internal clock

/**
 * @brief Set or clear a specific bit within a port register of a microcontroller. 
 * 
 * @param port point to port
 * @param pin  pin 
 * @param value value to set to the pin
 */
static void SetBit(volatile unsigned char *port, unsigned char pin, bool value) {
    if (value) {
        *port |= (1 << pin);
    } else {
        *port &= ~(1 << pin);
    }
}

/**
 * @brief  sets the 'Enable' (EN) pin high. 
 * @details It does this by calling the SetBit function (or a similar bit manipulation function) and passing the 'Enable' pin along with a true value, which sets this pin to a high state.
 * @details It assumes that the data or command has already been placed on the data lines before it is called.
 * @param config a pointer to a structure that holds the configuration of the LCD pins (like RS, EN, D4 to D7).
 */
static void PulseEnable(Lcd_PinConfig *config) {
    SetBit(config->port, config->en_pin, true);
    __delay_ms(2);
    SetBit(config->port, config->en_pin, false);
}

/**
 * @brief send commands to the LCD. 
 * @details These commands are used to control various aspects of the LCD's behavior, such as clearing the display, setting the cursor position, controlling display and cursor visibility, etc. 
 * @details The function is tailored for LCDs operating in 4-bit mode. 
 * 
 * @param config  a pointer to a structure that holds the configuration of the LCD pins (like RS, EN, D4 to D7).
 * @param cmd command byte to be sent to the LCD.
 */
void Lcd_Command(Lcd_PinConfig *config, unsigned char cmd) {
    // Send upper nibble
    SetBit(config->port, config->d4_pin, (cmd >> 4) & 0x01);
    SetBit(config->port, config->d5_pin, (cmd >> 5) & 0x01);
    SetBit(config->port, config->d6_pin, (cmd >> 6) & 0x01);
    SetBit(config->port, config->d7_pin, (cmd >> 7) & 0x01);

    SetBit(config->port, config->rs_pin, false); // Command mode
    PulseEnable(config);

    // Send lower nibble
    SetBit(config->port, config->d4_pin, cmd & 0x01);
    SetBit(config->port, config->d5_pin, (cmd >> 1) & 0x01);
    SetBit(config->port, config->d6_pin, (cmd >> 2) & 0x01);
    SetBit(config->port, config->d7_pin, (cmd >> 3) & 0x01);

    PulseEnable(config);
}

/**
 * @brief Sends a character to be displayed on the LCD from current cursor position 
 * 
 * @param config a pointer to a structure that holds the configuration of the LCD pins (like RS, EN, D4 to D7).
 * @param data character to be printed on LCD
 */

void Lcd_WriteChar(Lcd_PinConfig *config, unsigned char data) {
    // Send upper nibble
    SetBit(config->port, config->d4_pin, (data >> 4) & 0x01);
    SetBit(config->port, config->d5_pin, (data >> 5) & 0x01);
    SetBit(config->port, config->d6_pin, (data >> 6) & 0x01);
    SetBit(config->port, config->d7_pin, (data >> 7) & 0x01);

    SetBit(config->port, config->rs_pin, true); // Data mode
    PulseEnable(config);

    // Send lower nibble
    SetBit(config->port, config->d4_pin, data & 0x01);
    SetBit(config->port, config->d5_pin, (data >> 1) & 0x01);
    SetBit(config->port, config->d6_pin, (data >> 2) & 0x01);
    SetBit(config->port, config->d7_pin, (data >> 3) & 0x01);

    PulseEnable(config);
}

/**
 * @brief Writes an String (char array)from current cursor position 
 * 
 * @param config a pointer to a structure that holds the configuration of the LCD pins (like RS, EN, D4 to D7).
 * @param str String to be shown on LCD
 */
void Lcd_WriteString(Lcd_PinConfig *config, char *str) {
    while(*str != '\0') {  // Loop through the string until the null terminator
        Lcd_WriteChar(config, (unsigned char)(*str)); // Send each character to the LCD
        str++;  // Move to the next character in the string
    }
}

/**
 * @brief Configure the I/O for LCD interface
 * @param config a pointer to a structure that holds the configuration of the LCD pins (like RS, EN, D4 to D7).
 */
void Lcd_Init(Lcd_PinConfig *config) {
    // Configure the I/O for LCD interface
    // Make sure to configure the TRIS register for output in your main program

    // Initialize LCD to 4-bit mode
    __delay_ms(15); // Wait for more than 15 ms after VCC rises to 4.5V
    Lcd_Command(config, 0x03);
    __delay_ms(5);  // Wait for more than 4.1 ms
    Lcd_Command(config, 0x03);
    __delay_us(100); // Wait for more than 100 microsecond (us)
    Lcd_Command(config, 0x03); // These commands are for initializing in 8-bit mode
    Lcd_Command(config, 0x02); // Set to 4-bit mode

    Lcd_Command(config, 0x28); // Function Set: 4-bit, 2 Line, 5x7 Dots
    Lcd_Command(config, 0x0C); // Display on, Cursor off, Blink off
    Lcd_Command(config, 0x06); // Entry mode set
    Lcd_Clear(config);         // Clear display
}

/**
 * @brief clear the display of the LCD and reset the cursor position to the beginning (usually the top-left corner).
 * 
 * @param config a pointer to a structure that holds the configuration of the LCD pins (like RS, EN, D4 to D7).
 */
void Lcd_Clear(Lcd_PinConfig *config) {
    Lcd_Command(config, 0x01); // Clear display command
    __delay_ms(2);             // Wait for the command to process
}


/**
 * @brief Sets the cursor position
 * 
 * @param config a pointer to a structure that holds the configuration of the LCD pins (like RS, EN, D4 to D7).
 * @param row the line position
 * @param column the column position
 */
void Lcd_SetCursor(Lcd_PinConfig *config, unsigned char row, unsigned char column) {
    unsigned char address;
    
    // Calcula o endereço baseado na linha e coluna
    switch(row) {
        case 1:
            address = 0x80; // Endereço inicial da 1ª linha
            break;
        case 2:
            address = 0xC0; // Endereço inicial da 2ª linha
            break;
        default:
            address = 0x80; // Default to first row if out of bounds
    }

    // Ajusta para a coluna correta
    address += (column - 1);

    // Envia o comando para definir o endereço do cursor
    Lcd_Command(config, address);
}

