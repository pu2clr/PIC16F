/*
 * File:   main.c
 * Author: rcaratti
 *
 * Created on April 15, 2024, 12:04 PM
 */

#include <xc.h>


#define SDA_PIN     GP2
#define SCL_PIN     GP1


void i2cSetSdaLow() {
    SDA_PIN = 0;        
    TRIS = GPIO;
}

void i2cSetSdaHigh() {
    SDA_PIN = 1;
    TRIS = GPIO;
}

void i2cSetSclLow() {
    SCL_PIN = 0;
    TRIS = GPIO;
} 

void i2cSetSclHigh() {
    SCL_PIN = 1;
    TRIS = GPIO;
}

void i2cBegin() {
    i2cSetSclHigh();
    i2cSetSdaLow();
}

void i2cStop() {
    i2cSetSdaLow(); 
    i2cSetSclHigh();
    i2cSetSdaHigh();
}

void i2cSendAKC() {
    i2cSetSdaLow();
    i2cSetSclHigh();
    i2cSetSclLow();
    i2cSetSdaHigh();
}

void i2cSendNAKC() {
    i2cSetSdaHigh(); 
    i2cSetSclHigh();
    i2cSetSclLow();
}


void writeByte(unsigned char value) { 
   uint8_t aux; 
   for (uint8_t i = 0; i < 8; i++) {
       aux = 0B10000000 & value;
       if ( aux ) {
          i2cSetSdaHigh();          // writes 1
       } else {
          i2cSetSdaLow();           // write  0
       }
       i2cSetSclHigh();
       value = (uint8_t) (value << 1);          // prepare the next bit to be written 
   } 
   // To be continue
}

unsigned char readByte() { 
    uint8_t value = 0;
    for (uint8_t i = 0; i < 8; i++) {
        value = (uint8_t) (value << 1);
        i2cSetSclLow();
        i2cSetSclHigh();
        if ( SDA_PIN == 0) value = value & 0B11111110;
    }
    i2cSetSclLow();
    return value;
}


void main(void) {
    i2cBegin();
    i2cStop();
    writeByte(0x0F);
    readByte();
    return;
}
