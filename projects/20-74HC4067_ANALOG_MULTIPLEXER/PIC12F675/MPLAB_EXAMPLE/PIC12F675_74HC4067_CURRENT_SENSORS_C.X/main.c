/**
 * Current Sensor with PIC12F675 and 74HC4067 analog multiplexer 
 * Author: Ricardo Lima Caratti
 * April/2024 
 */


#include <xc.h>

#pragma config FOSC = INTRCIO   // Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = OFF      // Power-Up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = ON       // GP3/MCLR pin function select (GP3/MCLR pin function is MCLR)
#pragma config BOREN = ON       // Brown-out Detect Enable bit (BOD enabled)
#pragma config CP = OFF         // Code Protection bit (Program Memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)

#define _XTAL_FREQ      4000000 // internal clock

#define MAX_SAMPLE      6       // Number of reads    
#define MAX_SENSORS     3
#define MAX_THRESHOLD   60      // 60/1024 * 5 * 100 = 29,29 

void inline initADC() {
    TRISIO = 0b00011000;          // input setup - GP4/AN3   
    ANSEL =  0b00011000;          // AN0 as analog input
    ADCON0 = 0b10001101;          // Right justified; VDD;  11 = Channel 03 (AN3); A/D converter module is 
}

/**
 * Performs the reading 
 * 
 * @return value between 0 and 1023
 */
uint16_t readADC() {
    ADCON0bits.GO = 1; // Start conversion
    while (ADCON0bits.GO_nDONE); // Wait for conversion to finish
    return ((unsigned int) ADRESH << 8) + (unsigned int) ADRESL; // return the ADC 10 bit integer value 1024 ~= 5V, 512 ~= 2.5V, ... 0 = 0V
}

/**
 * Selects the sensor and performs the reading.
 * @param  - ensorNumber - Sensor number to be read
 * @return - Average of values from a sample 
 */
uint16_t getSensorData(uint8_t sensorNumber) {
    uint16_t sumValue = 0;

    // Selects the sensor 
    GPIO = (GPIO & 0B11111000) | sensorNumber; // Sets sensor Number to GP0, GP1 and GP2 (0 to 7)
    __delay_us(10);
    for (uint8_t i = 0; i < MAX_SAMPLE; i++ ) { 
        sumValue += readADC();
        __delay_us(10);
    }
    // Returns the average of values get from adcRead
    return sumValue / MAX_SAMPLE ;
}

/**
 * Alert Regarding Power Interruption in One of the Monitored Loads.
 * A LED (connected to GP5) will blink a number of times corresponding to the sensor 
 * number that detected the fault. That is, if the first sensor detects a failure, the 
 * LED will blink once; if the second sensor detects a failure, the LED will blink twice, 
 * and so on. 
 * @param sensorNumber -  number of sensor to be alerted. 
 */
void alert(uint8_t sensorNumber) {
    for (uint8_t led = 0; led <= sensorNumber; led++) {
        GP5 = 1;
        __delay_ms(200);
        GP5 = 0;
        __delay_ms(200);
    }
    __delay_ms(1500);
}

void main() {
    uint16_t sensorValue;
    OPTION_REG = 0B01000000;

    GPIO = 0x0; // Turns all GPIO pins low
    initADC();
    
    // Start indicator
    GP5 = 1;
    __delay_ms(2000);
    GP5 = 0;
    
    while (1) {
        // Scan all sensors
        for (uint8_t i = 0; i < MAX_SENSORS; i++) {
            sensorValue = getSensorData(i);
            if (sensorValue > MAX_THRESHOLD) {    // Consider adjusting the threshold value that defines what is clear or what is dark for your application.
                alert(i);
            }
            __delay_ms(10);
        }
    }
}