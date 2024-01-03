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

#define _XTAL_FREQ 4000000 // Set this to your clock frequency

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
 * @brief Sends a character to be displayed on the LCD
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
 * @brief a pointer to a structure that holds the configuration of the LCD pins (like RS, EN, D4 to D7).
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


void Lcd_Init(Lcd_PinConfig *config) {

    // Configure the I/O for LCD interface
    // Make sure to configure the TRIS register for output in your main program

    // Initialize LCD to 4-bit mode
    __delay_ms(15); // Wait for more than 15 ms after VCC rises to 4.5V
    Lcd_Command(config, 0x03);
    __delay_ms(5);  // Wait for more than 4.1 ms
    Lcd_Command(config, 0x03);
    __delay_us(100); // Wait for more than 100 �s
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
    
    // Convert the line to the address offset
    switch(row) {
        case 1:
            address = 0x80; // 1� line
            break;
        case 2:
            address = 0xC0; // 2� line
            break;
        default:
            address = 0x80; // Default to first row if out of bounds
    }

    // Adjust to the real position considering the column value
    address += (column - 1);

    // Send the command to set the cursor position (address)
    Lcd_Command(config, address);
}


/**
 * @brief Defines a custom char 
 * @details The HD44780 has limited space in its CGRAM for storing custom characters. 
 * @details Typically, up to 8 custom characters can be stored, which means the 'location' can range from 0 to 7. 
 * @details Each location ('location') corresponds to a specific address in the CGRAM.
 * @param config    a pointer to a structure that holds the configuration of the LCD pins (like RS, EN, D4 to D7).
 * @param location  point /index  to the custom Character Generator RAM of the HD44780 (0 - 7)
 * @param charmap   array  
 */
void Lcd_CreateCustomChar(Lcd_PinConfig *config, unsigned char location, unsigned char *charmap) {
    unsigned char i;
    if(location < 8) {
        // Set CGRAM address for character location
        Lcd_Command(config, 0x40 + (location * 8));
        for(i = 0; i < 8; i++) {
            Lcd_WriteChar(config, charmap[i]); // Write each row of the character
        }
    }
}


/**
 * @brief Displays a custom character 
 * @details You must defines the custom characters before call this function  
 * @param config    a pointer to a structure that holds the configuration of the LCD pins (like RS, EN, D4 to D7).
 * @param location  point /index  to the custom Character (the custom character you want to show)
 */
void Lcd_WriteCustomChar(Lcd_PinConfig *config, unsigned char location) {
    Lcd_WriteChar(config, location); // location should be from 0 to 7
}


