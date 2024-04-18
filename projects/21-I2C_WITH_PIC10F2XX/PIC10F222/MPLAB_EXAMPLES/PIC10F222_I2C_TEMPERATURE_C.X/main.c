/*
 * UNDER CONSTRUCTION...
 * I2C protocol implementation. 
 * 
 * Created on April 15, 2024, 12:04 PM
 * Ricardo Lima Caratti
 * References: https://www.ti.com/lit/an/slva704/slva704.pdf
 */

#include <xc.h>

// Sets the SDA and SCL pins of PIC10F200
// Change this if you have another setup. 
#define SDA_PIN     GP2         // Data  pin
#define SCL_PIN     GP1         // Clock pin




void i2cSendAck() {
    SDA_PIN = 0;    // Sets SDA PIN as output
    TRIS = GPIO;
    
    SCL_PIN = 0;
    SDA_PIN = 0;

    SCL_PIN = 1;
    SCL_PIN = 0;
    
}

void i2cSendNAck() {
    SDA_PIN = 0;    // Sets SDA PIN as output
    TRIS = GPIO;
    
    
    SCL_PIN = 0;
    SDA_PIN = 1;

    SCL_PIN = 1;
    SCL_PIN = 0;
}

/**
 * @brief Gets Acknowledge (ACK)
 * @return ACK value (the current SDA value
 */
unsigned char i2cReceiveAck() {
    uint8_t ack;

    SDA_PIN = 1;    // Sets SDA PIN as input
    TRIS = GPIO;
        
    SCL_PIN = 1;
    ack = SDA_PIN;
    SCL_PIN = 0; 
    
    return ack;
}

/**
 * Starts transaction 
 */
void i2cBeginTransaction() {
    SDA_PIN = 0;                // Sets SDA and SCL pins as OUTPUT
    SCL_PIN = 0;
    TRIS = GPIO;
    
    SDA_PIN = 1;
    SCL_PIN = 1;
 
    SDA_PIN = 0;
    SCL_PIN = 0;    
    
    SDA_PIN = 1;   
}


void i2cEndTransaction() {
    SDA_PIN = 0;                // Sets SDA and SCL pins as OUTPUT
    SCL_PIN = 0;
    TRIS = GPIO;

    SDA_PIN = 0;
    SCL_PIN = 1;
    SDA_PIN = 1;
}




void i2cWriteByte(unsigned char value) { 
   uint8_t aux; 
   
   SDA_PIN = 0;         // Sets SDA PIN as output
   TRIS = GPIO;
   
   for (uint8_t i = 0; i < 8; i++) {
       aux = 0B10000000 & value;
       if ( aux ) {
          SDA_PIN = 1;
       } else {
           SDA_PIN = 0;
       }
       SCL_PIN = 1;
       SCL_PIN = 0;
       value = (uint8_t) (value << 1);          // prepare the next bit to be written 
   } 
}

unsigned char i2cReadByte() { 
    uint8_t value = 0;
    
    SDA_PIN = 1;         // Sets SDA PIN as input
    TRIS = GPIO;
       
    for (uint8_t i = 0; i < 8; i++) {
        SCL_PIN = 1;
        value = (uint8_t) (value << 1);
        if ( SDA_PIN ) value = value |  0B00000001;
        SCL_PIN = 0;
    }
    return value;
}

void i2cSendData(uint8_t deviceAddress, uint8_t value ) {
    
    i2cBeginTransaction();
    i2cWriteByte( (uint8_t) (deviceAddress << 1));
    i2cReceiveAck();
    i2cWriteByte(value);
    i2cReceiveAck();
    i2cEndTransaction();

}


void i2cSendRegister(uint8_t deviceAddress, uint8_t registerNumber, uint16_t word) {
    
    uint8_t value;
    
    i2cBeginTransaction();
    i2cWriteByte( (uint8_t) (deviceAddress << 1));
    i2cReceiveAck();
    
    i2cWriteByte( (uint8_t) (registerNumber << 1) );
    i2cReceiveAck();
    
    value = (uint8_t) (word >> 8);      // HIGH SIGNIFICANT BYTE FIRST
    i2cWriteByte(value);
    i2cReceiveAck();
    
    value = (uint8_t) (word & 0xFF);    // LOW SIGNIFICANT BYTE LAST
    i2cWriteByte(value);
    i2cReceiveAck();
    
    i2cEndTransaction();
    
    
}

uint8_t i2cRequestData(uint8_t deviceAddress) {
    
    uint8_t data;
    
    i2cBeginTransaction();
    
    i2cWriteByte( ((uint8_t) (deviceAddress << 1)) | 1 ); // Converts address and sets to read operation
    i2cReceiveAck();
    
    data = i2cReadByte();
    i2cSendAck();
    i2cSendNAck();
    
    i2cEndTransaction();
    
    return data;
}

// Under construction...
uint16_t i2cRequestRegister(uint8_t deviceAddress) {
    
    uint16_t data;
    
    i2cBeginTransaction();
    
    i2cWriteByte((uint8_t) (deviceAddress << 1));
    i2cReceiveAck();
    
    data = (uint16_t)i2cReadByte() << 8;   
    i2cSendAck();
    data = data | i2cReadByte();
    i2cSendNAck();
    
    i2cEndTransaction();
    
    return data;
}

// RDA5807 - PowerUp: 1010000010001011 = 0xA08B
void main(void) {
    
    uint8_t data;
    
    
    ADCON0 = 0;     // Analog setup disabled.
    
    // GPWU: Disable (Enable Wake-up on Pin Change bit)
    // GPPU: Enable (Enable Weak Pull-ups bit)
    // T0CS: Transition on internal instruction cycle clock, FOSC/4
    // T0SE: Enable (Timer0 Source Edge Select bit)
    // PSA.: 0 = Prescaler assigned to Timer0
    // PS<2:0>: Prescaler Rate Select bits (1:256)
    OPTION = 0B10010111;
    TRIS = 0B0000111;        

    while (1) {
        i2cSendData(0x40, 0);
        data = i2cRequestData(0x40);
        i2cSendRegister(0x11,0x02, 0xA08B); // Start the radio (power up)
        i2cRequestRegister(0x40);
    }
    
    return;
}
