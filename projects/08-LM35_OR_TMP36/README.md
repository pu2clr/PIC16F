# Termometer with LM35 or TMP36 sensor and PIC12F and PIC16F with ADC support

In this folder, you will find some projects with the PIC12F and PIC16F series for processing analog signals, particularly for reading voltage outputs produced by temperature sensors like the LM35 or TMP36

## Fever indicator with the small PIC12F675

The PIC12F675 is a compact and versatile 8-bit microcontroller from Microchip Technology, belonging to the popular PIC12F series. It's known for its small size and low power consumption, making it ideal for space-constrained and power-sensitive applications. The PIC12F675 features 1 KB of flash memory, 64 bytes of EEPROM, and 128 bytes of RAM, along with an onboard 10-bit Analog-to-Digital Converter (ADC), which is quite impressive for its size.



## Simplifying Complex Calculations in Temperature Sensing with PIC12F675 projects

Some projects utilize either an LM35 or TMP36 temperature sensor to determine if a body's temperature is below, equal to, or above 37 degrees Celsius. The approach is streamlined to improve efficiency: there's no conversion of the sensor's analog signal to a Celsius temperature reading, as the actual temperature value isn't displayed.

The key lies in understanding the digital equivalent of 37 degrees Celsius in the sensor's readings. For instance, an analog reading of 77, when converted to digital through the Analog-to-Digital Converter (ADC), corresponds precisely to 37 degrees Celsius. This can be calculated as follows:

Let's see: **ADC Value * 5 / 1024 * 100 = Temperature in Degrees Celsius**.

Thus: **77 * 5 / 1024 * 100 = 37.59°C**

Therefore, the process involves simply reading the analog value and comparing it with 77. This method significantly conserves memory and processing power, optimizing the project's overall efficiency.


## C code to demostrate that approach 

The following C code is designed for compilation and execution on the PIC12F675 microcontroller.

```cpp
#include <xc.h>

// 
#pragma config FOSC = INTRCIO   // Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = OFF      // Power-Up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = ON       // GP3/MCLR pin function select (GP3/MCLR pin function is MCLR)
#pragma config BOREN = ON       // Brown-out Detect Enable bit (BOD enabled)
#pragma config CP = OFF         // Code Protection bit (Program Memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)

#define _XTAL_FREQ 4000000      // internal clock


void initADC() {
    TRISIO = 0b00000010;
    ANSEL =  0b00000010;          // AN1 is analog input
    ADCON0 = 0b10000101;          // Right justified; VDD;  01 = Channel 01 (AN1); A/D converter module is operating
}

unsigned int readADC() {
    ADCON0bits.GO = 1;           // Start conversion
    while (ADCON0bits.GO_nDONE); // Wait for conversion to finish
    return ADRESL; // 
}

void main() {
    TRISIO = 0x00;  // Sets All GPIO as output 
    GPIO =  0x0;    // Turns all GPIO pins low
    
    initADC();
    
    while (1) {
        unsigned int value = readADC();
        // To optimize accuracy, it might be necessary to perform calibration in order to 
        // determine a more precise value. the ADC vales 77 is near to 37 degree Celsius in my experiment
        if ( value >= 77)   
            GP0 = 1;        // Turn GP0 HIGH (LED ON))
        else
            GP0 = 0;        // Turn GP0 LOW (LED OFF)
        __delay_ms(1000); 
    }
}

```



## References


