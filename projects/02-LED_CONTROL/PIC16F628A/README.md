# Controlling more than one LED with PIC

This project presents the circuit that uses the PIC16F628A with LEDs that can be controlled in various ways.


## Content

1. [PIC16F286A and 8 LEDs Schematic](#pic16f286a-and-8-leds-schematic)
2. [KiCad Schematic](./KiCad/)
3. [PIC16F628A PINOUT](#pic16f286a-pinout)
4. [PIC16F286A with 8 LEDs Prototype](#pic16f286a-with-8-leds-prototype)
5. [C Example 1](#c-example-1)
6. [C Example 2](#c-example-2)
7. [MPLAB X IDE Projects](./MPLAB_EXAMPLES/)
8. [References](#references)


## PIC16F286A and 8 LEDs Schematic


![Schematic PIC16F286A controlling 8 LEDs](./schematic_PIC16F628A_8_Leds.jpg)


## PIC16F286A PINOUT


![Basic Servo and PIC16F628A schematic](../../../images/PIC16F628A_PINOUT.png)


## PIC16F286A with 8 LEDs Prototype

![Prototype PIC16F286A controlling 8 LEDs](./protoboard_01.jpg)


## C Example 1

This project uses a PIC16F628A microcontroller to count time for 1 minute (60s). The system starts with 8 LEDs lit, and every 7.5 seconds, one LED turns off. After all the LEDs have turned off, the system waits for 15 seconds and then restarts the process.



```cpp
#include <xc.h>

#pragma config FOSC = INTOSCIO  // Internal Oscillator
#pragma config WDTE = OFF       // Watchdog Timer disabled
#pragma config PWRTE = OFF      // Power-up Timer disabled
#pragma config MCLRE = ON       // MCLR pin function is digital input
#pragma config BOREN = OFF       // Brown-out Reset enabled
#pragma config LVP = OFF        // Low Voltage Programming disabled
#pragma config CPD = OFF        // Data EEPROM Memory Code Protection disabled
#pragma config CP = OFF         // Flash Program Memory Code Protection disabled

#define _XTAL_FREQ 4000000      // Internal Oscillator Frequency

void main() {
    TRISB = 0x00; // Sets PORTB as output

    while (1) {
        PORTB =  0xFF; // Turn all LEDs on
        // Sequentially turns off each LED at intervals of 7.5 seconds.
        do { 
            __delay_ms(7500);
        } while ( (PORTB = (unsigned char) (PORTB <<  1)) ); 
        __delay_ms(15000); 
    }
}

````


## C Example 2

This example uses the same previous circuit. Two LEDs will be activated at a time in half-second intervals.

```cpp
#include <xc.h>

#pragma config FOSC = INTOSCIO  // Internal Oscillator
#pragma config WDTE = OFF       // Watchdog Timer disabled
#pragma config PWRTE = OFF      // Power-up Timer disabled
#pragma config MCLRE = ON       // MCLR pin function is digital input
#pragma config BOREN = OFF       // Brown-out Reset enabled
#pragma config LVP = OFF        // Low Voltage Programming disabled
#pragma config CPD = OFF        // Data EEPROM Memory Code Protection disabled
#pragma config CP = OFF         // Flash Program Memory Code Protection disabled

#define _XTAL_FREQ 4000000      // Internal Oscillator Frequency

void main() {
    TRISB = 0x00; // Sets PORT B as output

    while (1) {
        PORTB =  0x03; // turn the first two LEDs on
        do {
            __delay_ms(500);
        } while ( (PORTB = (unsigned char) (PORTB <<  1)) ); 
        __delay_ms(1000);
    }
}

```

## References

1. [PIC16F87XA Data Sheet](https://ww1.microchip.com/downloads/en/devicedoc/39582b.pdf)
2. [PIC16F87XA Data Sheet](https://ww1.microchip.com/downloads/en/devicedoc/39582b.pdf)
3. [PIC16F627A/628A/648A Data Sheet](https://ww1.microchip.com/downloads/en/DeviceDoc/40044G.pdf)
4. [LED - Light-emitting diode](https://en.wikipedia.org/wiki/Light-emitting_diode)



