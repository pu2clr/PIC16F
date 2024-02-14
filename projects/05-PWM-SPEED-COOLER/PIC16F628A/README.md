
# PIC16F628A and DC motor example

## Content

1. [PIC16F628A and DC Motor schematic](#pic16f628a-and-dc-motor-schematic)
    * [KiCad schematic](./KiCad/)
2. [PIC16F628A PINOUT](#pic16f628a-pinout) 
3. [PIC16F628A and cooler control prototype](#pic16f628a-and-cooler-control-prototype)
4. [MPLAB X IDE project](./MPLABX_EXAMPLES/)
5. [References](#references)


## PIC16F628A and DC Motor schematic 

![PIC16F628A and DC Motor schematic](./schematic_pic16f628a_pwm.jpg)


### PIC16F628A PINOUT

![PIC16F628A PINOUT](../../../images/PIC16F628A_PINOUT.png)


### PIC16F628A source code

```cpp
#include <xc.h>

#pragma config FOSC = INTOSCCLK // Internal OSC
#pragma config WDTE = OFF       // Disable Watchdog Timer
#pragma config PWRTE = OFF      // Disable Timer  Power-up
#pragma config MCLRE = ON       // 
#pragma config BOREN = ON       // 
#pragma config LVP = OFF        // 
#pragma config CPD = OFF        // 
#pragma config CP = OFF         // 

#define _XTAL_FREQ 4000000 // Internal Clock 4MHz

void main()
{
    TRISB = 0;            // Sets PORTB - output
    CCP1CON = 0b00001100; // Sets PWM
    T2CON = 0b00000111;   // Sets Timer2 prescaler of 16
    PR2 = 255;             // Sets PWM period

 
    TMR2 = 0;   // Resets Timer2 
    TMR2ON = 1; // Sets Timer2 ON 

    while (1)
    {
        // Minimum Speed
        CCPR1L = 27;
        __delay_ms(5000);
        
        // Average Speed
        CCPR1L = 33;
        __delay_ms(5000);

        // Maximum Speed
        CCPR1L = 55;
        __delay_ms(5000);
    }
}

```

### PIC16F628A and cooler control prototype

![PIC16F628A and cooler control prototype](./images/pic16f268a_coller.jpg)


## References

* [How to Drive a DC Motor with a BJT Transistor](https://www.techzorro.com/en/blog/how-to-drive-a-dc-motor-with-a-bjt-transistor/)
* [Driving DC Motors with Microcontrollers](https://dronebotworkshop.com/dc-motor-drivers/)
* [Introduction to Bipolar Junction Transistors (BJTs) | Basic Electronics](https://youtu.be/lMmJenzKYS8?si=ZfMs-jVsEGGM33go)
* [How do PWMs work? A theoretical and practical overview](https://youtu.be/Il78FZweSFw?si=--nt46471nfmHWov)
* [Using PWM for DC Motor Control](https://blog.upverter.com/2019/11/21/using-pwm-for-dc-motor-control/)
* [What is a PWM signal?](https://www.circuitbread.com/ee-faq/what-is-a-pwm-signal)
* [Oscilloscopes 101 - How to use an o-scope! | Basic Electronics](https://youtu.be/hKMCVdzuMXQ?si=7gQO-4m5PNUtripk)

