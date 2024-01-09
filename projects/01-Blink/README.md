# BLINK with PIC16F628A

A minimalist project to blink an LED using the PIC16F628A.


LEDs, or Light Emitting Diodes, are efficient light sources that work by passing an electrical current through a semiconductor material. Key features include:

1. **Energy Efficiency**: LEDs consume significantly less power compared to traditional incandescent bulbs.
2. **Longevity**: They have a much longer lifespan, often lasting tens of thousands of hours.
3. **Compact Size**: LEDs can be very small and are easily integrated into various designs.
4. **Low Heat Output**: Unlike incandescent bulbs, LEDs produce minimal heat.
5. **Durability**: They are more resistant to shock and vibrations.

Applications:
- **General Lighting**: Used in homes, offices, and outdoor settings.
- **Displays and Signage**: In TVs, computer monitors, digital signs, and billboards.
- **Indicator Lights**: On electronic devices, machinery, and vehicles.
- **Medical Devices**: For specialized lighting in medical equipment.
- **Automotive Lighting**: In headlights, brake lights, and interior lighting.
- **Smart Lighting Systems**: Integrated with IoT for smart home and city applications.


This folder contains a basic example demonstrating how to blink a LED using a PIC16F628A microcontroller. It's a minimalistic application designed to provide a foundation for developing a wide range of more complex projects. This simple yet instructive example can be a starting point for various applications, offering insights into basic microcontroller programming and hardware interaction.



## Schematic

![Schematic PIC16F286A blink](./schematic_blink_pic16f28a.jpg)


<BR>

![PIC16F628A pinout](../../images/PIC16F628A_PINOUT.png)


## Prototype


![Prototype PIC16F286A blink](./pic16f628a_blink.jpg)



## Example


```cpp
#include <xc.h>

// 
#pragma config FOSC = INTOSCIO  // Internal oscillator.
#pragma config WDTE = OFF       // Watchdog Timer disabled 
#pragma config PWRTE = OFF      // Power-up Timer disable
#pragma config MCLRE = ON       // MCLR pin function is digital input
#pragma config BOREN = OFF      // Brown-out Reset enabled
#pragma config LVP = OFF        // Low Voltage Programming disabled
#pragma config CPD = OFF        // Data EEPROM Memory Code Protection disabled
#pragma config CP = OFF         // Flash Program Memory Code Protection disabled

#define _XTAL_FREQ 4000000      // internal clock

void main() {
    TRISB = 0x00; // 
    PORTB =  0x0; // turn all PORTB pins low

    while (1) {
        PORTB = 0x01;
        __delay_ms(1000); 
        PORTB = 0x0;
        __delay_ms(1000); 
    }
}

```



