
# PIC16F887 and DC Motor Example


## Content

1. [Circuit and Code Description for PIC16F877](#circuit-and-code-description-for-pic16f877)
2. [PIC16F887 schematic](#pic16f887-schematic)
    * [KiCad schematic](./KiCad/)
3. [PIC16F887 PINOUT](#pic16f887-pinout)
4. [PIC16F887 source code](#pic16f887-source-code)
5. [PIC16F887, cooler, and potentiometer with adc reader prototype](#pic16f887-cooler-and-potentiometer-with-adc-reader-prototype)
6. [PIC16F887 example with a four wires Coller](#pic16f887-example-with-a-four-wires-coller)
    * [Application in Thermal Management](#application-in-thermal-management)
    * [Safety and Power Considerations](#safety-and-power-considerations)
    * [Cooler and temperature control application ](#cooler-and-temperature-control-application)
7. [MPLAB X IDE](./MPLABX_EXAMPLES/)
8. [References](#references)



## Circuit and Code Description for PIC16F877

- **DC Motor Control**: Similar to the PIC16F628A setup, a transistor is used for motor control.  A flyback diode for protection is recomendeed but is is not used here.
- **Potentiometer for Speed Control**: The potentiometer is connected to one of the ADC-capable pins of the PIC16F877 (e.g., AN0). The other two terminals of the potentiometer are connected to VDD and GND.
- **PWM Signal Generation**: The PWM signal is generated by the PIC16F877 to control the motor speed.


## PIC16F887 schematic 

![PIC16F887 schematic](./schematic_pic16f887_pwm_adc.jpg)


## PIC16F887 PINOUT

![PIC16F887 PINOUT](../../../images/PIC16F887_PINOUT.png)


### PIC16F887 source code

#### Code Description:
- **PWM Setup**: The CCP module is configured for PWM operation. The PWM signal's duty cycle controls the motor speed.
- **ADC Setup**: The ADC module of the PIC16F877 is configured to read the voltage at the potentiometer's wiper (connected to an ADC-capable pin).
- **Reading Potentiometer**: The ADC reads the potentiometer's position and converts it into a digital value.
- **Motor Speed Control**: Based on the ADC reading, the PWM duty cycle is adjusted, changing the motor speed.


```cpp
#include <xc.h>


// Configuration Bits
#pragma config FOSC = INTRC_NOCLKOUT  // Internal Oscillator, no clock out
#pragma config WDTE = OFF             // Watchdog Timer disabled
#pragma config PWRTE = OFF            // Power-up Timer disabled
#pragma config MCLRE = ON             // MCLR pin function is digital input
#pragma config BOREN = ON             // Brown-out Reset enabled
#pragma config LVP = OFF              // Low Voltage Programming disabled
#pragma config CPD = OFF              // Data EEPROM Memory Code Protection disabled
#pragma config CP = OFF               // Flash Program Memory Code Protection disabled

#define _XTAL_FREQ 4000000  // 4 MHz Crystal Frequency

void initPWM() {
    OSCCON = 0x60;
    TRISC = 0;                   // Set port to output   
    T2CON = 0x07;
    PR2 = 0xFF;                  // Set PWM period
    CCP1CON = 0x0C;              // Set PWM mode and duty cycle to 0
    CCPR1L = 0x00;
    T2CON = 0x04;                // Timer2 ON, Prescaler set to 1
}

void initADC() {
    ANSEL = 0x01;                // RA0/AN0 is analog input
    ADCON0 = 0x01;               // Enable ADC, channel 0
    ADCON1 = 0x80;               // Right justified, Fosc/32
}

unsigned int readADC() {
    ADCON0bits.GO = 1;           // Start conversion
    while (ADCON0bits.GO_nDONE); // Wait for conversion to finish
    return ((ADRESH << 8) + ADRESL); // Combine result into a single word
}

void main() {   
    initPWM();
    initADC();

    CCPR1L = 31;
    __delay_ms(5000);
    
    while(1) {
        unsigned int adcResult = readADC();
        CCPR1L = adcResult >> 2;  // Scale ADC result to fit PWM duty cycle register
        __delay_ms(10);           // Small delay for stability
    }
}


```

### PIC16F887, cooler, and potentiometer with adc reader prototype

![PIC16F887, cooler, and potentiometer with adc reader prototype](./images/pic16f887_cooler_potentiometer_adc.jpg)



## PIC16F887 example with a four wires Coller.

A four-wire cooler (or fan) typically used in computer systems offers more sophisticated control over the fan speed compared to two and three-wire coolers. Here's a detailed explanation of the function of each wire:


![PIC16F887 example with a four wires Coller](./images/pic16f887_4_wire_cooler_potentiometer_adc.jpg)


1. **Red Wire - Power (VCC)**
   - This wire supplies the positive voltage to the fan. The voltage level is typically 5V or 12V in computer fans, but it can vary depending on the fan's specifications.
   - It provides the necessary power for the fan motor to operate.

2. **Black Wire - Ground (GND)**
   - This is the ground wire and is connected to the negative side of the power supply.
   - It completes the electrical circuit for the fan motor.

3. **Yellow Wire - Tachometer Signal**
   - This wire outputs a tachometer signal that can be used to measure the fan's rotational speed (RPM - Revolutions Per Minute).
   - The signal is typically a pulse train, where the number of pulses per minute corresponds to the fan's RPM. Usually, two pulses per revolution are standard, but this can vary.
   - By measuring the frequency of these pulses or counting the number of pulses over a set period, the fan's speed can be determined.

4. **Blue or White Wire - PWM Control Signal**
   - This wire is used to control the speed of the fan via Pulse Width Modulation (PWM).
   - By varying the duty cycle of the PWM signal sent to this wire, you can control the speed of the fan without changing the supply voltage.
   - A higher duty cycle means higher fan speed, and vice versa. For instance, a 100% duty cycle runs the fan at full speed, while a 50% duty cycle cuts the speed in half.
   - This allows for precise control of the fan speed, which can be used for thermal management, noise reduction, or power saving.

### Application in Thermal Management
In computer systems or other electronic applications, these fans are often used for cooling purposes. The four-wire configuration allows the system to dynamically adjust the fan speed based on thermal requirements, which can be more energy-efficient and quieter compared to running the fan at full speed all the time.

The PWM control also enables the system to respond quickly to temperature changes, increasing the fan speed when necessary (e.g., when the CPU is under heavy load) and slowing it down when the demand for cooling decreases.

### Safety and Power Considerations
When working with four-wire coolers, it's important to ensure that the power requirements of the fan match your power supply's capabilities. Overloading the power supply or misconnecting the wires can lead to damage to the fan or other components in the system.


### Cooler and temperature control application 

This type of cooler is versatile and can be utilized in numerous applications. The schematic and prototype presented below demonstrate a method for controlling the cooler's speed in response to environmental temperature changes. As the temperature increases, the pulse width correspondingly increases, thereby adjusting the cooler's speed accordingly.


### Schematic four wires cooler and PIC16F887 setup

![Schematic four wires cooler and PIC16F887 setup](./schematic_pic16f887_4_wires_cooler.jpg)


### Prototype four wires cooler and PIC16F887 setup 

![Prototype four wires cooler and PIC16F887 setup](./images/example_with_pic16f887_4_wires_cooler_lm35.jpg)


### 4-wires cooler and PIC16F887 source code

```cpp
#include <xc.h>
#include <stdio.h>
#include "pic16flcd.h"

// Configuration Bits
#pragma config FOSC = INTRC_NOCLKOUT  // Internal Oscillator, no clock out
#pragma config WDTE = OFF             // Watchdog Timer disabled
#pragma config PWRTE = OFF            // Power-up Timer disabled
#pragma config MCLRE = ON             // MCLR pin function is digital input
#pragma config BOREN = ON             // Brown-out Reset enabled
#pragma config LVP = OFF              // Low Voltage Programming disabled
#pragma config CPD = OFF              // Data EEPROM Memory Code Protection disabled
#pragma config CP = OFF               // Flash Program Memory Code Protection disabled

#define _XTAL_FREQ 4000000  // 4 MHz Crystal Frequency

void initPWM() {
    OSCCON = 0x60;
    TRISC = 0; // Set port to output   
    T2CON = 0x07;
    PR2 = 0xFF; // Set PWM period
    CCP1CON = 0x0C; // Set PWM mode and duty cycle to 0
    CCPR1L = 0x00;
    T2CON = 0x04; // Timer2 ON, Prescaler set to 1
}

void initADC() {
    ANSEL = 0x01; // RA0/AN0 is analog input
    ADCON0 = 0x01; // Enable ADC, channel 0
    ADCON1 = 0x80; // Right justified, Fosc/32
}

unsigned int readADC() {
    ADCON0bits.GO = 1; // Start conversion
    while (ADCON0bits.GO_nDONE); // Wait for conversion to finish
    return (unsigned int) ((ADRESH << 8) + ADRESL); // Combine result into a single word
}

double readTemperature() {
    unsigned int adcValue = readADC();
    double voltage = (float) ((float) adcValue / 1024.0) * 5.0; // Convert ADC value to voltage
    return(float) voltage / (float) 0.01; // Convert voltage to temperature in Celsius.   
}

void main() {
    initPWM();
    initADC();

    Lcd_PinConfig lcd = {
        .port = &PORTD, // Assuming you're using PORTD for LCD on PIC16F887
        .rs_pin = 2, // RD2 for RS
        .en_pin = 3, // RD3 for EN
        .d4_pin = 4, // RD4 for D4
        .d5_pin = 5, // RD5 for D5
        .d6_pin = 6, // RD6 for D6
        .d7_pin = 7 // RD7 for D7
    };

    // Initialize the LCD
    TRISD = 0;
    Lcd_Init(&lcd);
    Lcd_Clear(&lcd);

    // Display message
    Lcd_SetCursor(&lcd, 1, 1);
    Lcd_WriteString(&lcd, "Cooler & LM35");
    Lcd_SetCursor(&lcd, 2, 1);
    Lcd_WriteString(&lcd, "Temp:");


    while (1) {
        char strTemp[6];
        double temperature;
        double sum = 0;
        
        // Calculate the 
        for (unsigned char i =0; i < 10; i++ ) {
            sum +=  readTemperature();
            __delay_ms(100);
        }
        temperature = sum / 10.0;

        sprintf(strTemp, "%4u", (int) temperature);
        Lcd_SetCursor(&lcd, 2, 7);
        Lcd_WriteString(&lcd, strTemp );

        if (temperature > 37.0)
            CCPR1L = 200;
        else if (temperature > 30.0)
            CCPR1L = 50;
        else if (temperature > 26.0)
            CCPR1L = 30;
        else if (temperature > 23.0)
            CCPR1L = 15;
        else 
            CCPR1L = 0;
        __delay_ms(2000);
    }
}

```

### The same application has now incorporated a tachometer counter (RPM)


```cpp
#include <xc.h>
#include <stdio.h>
#include "../../pic16flcd.h"

// Configuration Bits
#pragma config FOSC = INTRC_NOCLKOUT  // Internal Oscillator, no clock out
#pragma config WDTE = OFF             // Watchdog Timer disabled
#pragma config PWRTE = OFF            // Power-up Timer disabled
#pragma config MCLRE = ON             // MCLR pin function is digital input
#pragma config BOREN = ON             // Brown-out Reset enabled
#pragma config LVP = OFF              // Low Voltage Programming disabled
#pragma config CPD = OFF              // Data EEPROM Memory Code Protection disabled
#pragma config CP = OFF               // Flash Program Memory Code Protection disabled

#define _XTAL_FREQ 4000000  // 4 MHz Crystal Frequency

#define TACH_PIN PORTBbits.RB0 // Tachometer signal connected to RB0

// Bitmap for Celsius degree symbol
unsigned char celsiusChar[8] = {
    0b11000, // **
    0b11000, // **  
    0b00000, //
    0b01111, //  ****
    0b01000, //  *
    0b01000, //  *
    0b01000, //  *
    0b01111  //  ****
};

void initPWM() {
    OSCCON = 0x60;
    TRISC = 0; // Set port to output   
    T2CON = 0x07;
    PR2 = 0xFF; // Set PWM period
    CCP1CON = 0x0C; // Set PWM mode and duty cycle to 0
    CCPR1L = 0x00;
    T2CON = 0x04; // Timer2 ON, Prescaler set to 1
}


/**
 * RPM reader setup
 */
void initRPM() {

    TRISBbits.TRISB0 = 1; // Set RB0 as input
    ANSELH = 0x00; // Disable analog inputs on PORTB

    OPTION_REGbits.T0CS = 0; // Timer0 Clock Source: Internal instruction cycle clock (CLKO)
    OPTION_REGbits.PSA = 0; // Prescaler is assigned to the Timer0 module
    OPTION_REGbits.PS = 0b111; // Prescaler 1:256
    TMR0 = 0; // Reset Timer0
}


void initADC() {
    ANSEL = 0x01; // RA0/AN0 is analog input
    ADCON0 = 0x01; // Enable ADC, channel 0
    ADCON1 = 0x80; // Right justified, Fosc/32
}

unsigned int readADC() {
    ADCON0bits.GO = 1; // Start conversion
    while (ADCON0bits.GO_nDONE); // Wait for conversion to finish
    return (unsigned int) ((ADRESH << 8) + ADRESL); // Combine result into a single word
}

double readTemperature() {
    unsigned int adcValue = readADC();
    double voltage = (float) ((float) adcValue / 1024.0) * 5.0; // Convert ADC value to voltage
    return(float) voltage / (float) 0.01; // Convert voltage to temperature in Celsius.   
}

unsigned int countPulses() {
    unsigned int pulseCount = 0;
    unsigned char lastState = TACH_PIN;
    unsigned char currentState;

    TMR0 = 0; // Reset Timer0
    INTCONbits.TMR0IF = 0; // Clear Timer0 overflow flag

    while (!INTCONbits.TMR0IF) { // Wait for Timer0 to overflow
        currentState = TACH_PIN;

        if (currentState != lastState && currentState == 1) { // Detect rising edge
            pulseCount++;
        }
        lastState = currentState;
    }

    return pulseCount;
}

void main() {
    initPWM();
    initADC();
    initRPM();

    Lcd_PinConfig lcd = {
        .port = &PORTD, // Assuming you're using PORTD for LCD on PIC16F887
        .rs_pin = 2, // RD2 for RS
        .en_pin = 3, // RD3 for EN
        .d4_pin = 4, // RD4 for D4
        .d5_pin = 5, // RD5 for D5
        .d6_pin = 6, // RD6 for D6
        .d7_pin = 7 // RD7 for D7
    };

    // Initialize the LCD
    TRISD = 0;
    Lcd_Init(&lcd);
    Lcd_Clear(&lcd);

    // Loading the custom character
    Lcd_CreateCustomChar(&lcd, 0, celsiusChar);
    // Display message
    Lcd_SetCursor(&lcd, 1, 1);
    Lcd_WriteString(&lcd, "Cooler & LM35");
    Lcd_SetCursor(&lcd, 2, 1);
    Lcd_SetCursor(&lcd, 2, 6);
    Lcd_WriteString(&lcd, "RPM:");


    while (1) {
        char strTemp[6];
        char strRPM[6];
        double temperature;
        double sum = 0;
        
        unsigned int pulses = countPulses();
        
        unsigned int fanRPM = (unsigned int) ((pulses / 2) * (60 / (256.0 / _XTAL_FREQ * 256)/10));
        
        sprintf(strRPM, "%4u", fanRPM);
        Lcd_SetCursor(&lcd, 2, 10);
        Lcd_WriteString(&lcd, strRPM );
        
        
        // Calculate the 
        for (unsigned char i =0; i < 10; i++ ) {
            sum +=  readTemperature();
            __delay_ms(100);
        }
        temperature = sum / 10.0;

        sprintf(strTemp, "%2u", (int) temperature);
        Lcd_SetCursor(&lcd, 2, 1);
        Lcd_WriteString(&lcd, strTemp );
        Lcd_SetCursor(&lcd, 2, 3);
        Lcd_WriteCustomChar(&lcd, 0);

        if (temperature > 37.0)
            CCPR1L = 200;
        else if (temperature > 30.0)
            CCPR1L = 50;
        else if (temperature > 26.0)
            CCPR1L = 30;
        else if (temperature > 23.0)
            CCPR1L = 15;
        else 
            CCPR1L = 0;
        __delay_ms(2000);
    }
}


```

## References

* [How to Drive a DC Motor with a BJT Transistor](https://www.techzorro.com/en/blog/how-to-drive-a-dc-motor-with-a-bjt-transistor/)
* [Driving DC Motors with Microcontrollers](https://dronebotworkshop.com/dc-motor-drivers/)
* [Introduction to Bipolar Junction Transistors (BJTs) | Basic Electronics](https://youtu.be/lMmJenzKYS8?si=ZfMs-jVsEGGM33go)
* [How do PWMs work? A theoretical and practical overview](https://youtu.be/Il78FZweSFw?si=--nt46471nfmHWov)
* [Using PWM for DC Motor Control](https://blog.upverter.com/2019/11/21/using-pwm-for-dc-motor-control/)
* [What is a PWM signal?](https://www.circuitbread.com/ee-faq/what-is-a-pwm-signal)
* [Oscilloscopes 101 - How to use an o-scope! | Basic Electronics](https://youtu.be/hKMCVdzuMXQ?si=7gQO-4m5PNUtripk)