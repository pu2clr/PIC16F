# Time Counter. 

This project presents the circuit that uses the PIC16F628A with LEDs that can be controlled in various ways.



## Schematic


![Schematic PIC16F286A controlling 8 LEDs](./schematic_PIC16F628A_8_Leds.jpg)

<BR>

![Basic Servo and PIC16F628A schematic](../../images/PIC16F628A_PINOUT.png)


## Prototype

![Prototype PIC16F286A controlling 8 LEDs](./protoboard_01.jpg)


## Example 1

This project uses a PIC16F628A microcontroller to count time for 1 minute (60s). The system starts with 8 LEDs lit, and every 7.5 seconds, one LED turns off. After all the LEDs have turned off, the system waits for 15 seconds and then restarts the process.



```cpp
#include <xc.h>

// Configuração do microcontrolador
#pragma config FOSC = INTOSCIO  // Oscilador interno
#pragma config WDTE = OFF       // Watchdog Timer desativado
#pragma config PWRTE = OFF      // Power-up Timer desativado
#pragma config MCLRE = ON       // MCLR pin function is digital input
#pragma config BOREN = OFF      // Brown-out Reset habilitado
#pragma config LVP = OFF        // Low Voltage Programming desativado
#pragma config CPD = OFF        // Data EEPROM Memory Code Protection desativado
#pragma config CP = OFF         // Flash Program Memory Code Protection desativado

#define _XTAL_FREQ 4000000      // Frequência do oscilador externo

void main() {
    TRISB = 0x00; // Configura PORTB como saída


    while (1) {
        PORTB =  0xFF; // Acende o LED
        for (int i = 0; i < 8; i++) {
            __delay_ms(7500); // Espera 500 milissegundos
            PORTB = (unsigned char) (PORTB <<  1);
        }
        __delay_ms(15000); // Espera 500 milissegundos
    }
}

````


## Example 2

This example uses the same previous circuit. Two LEDs will be activated at a time in half-second intervals.

```cpp
#include <xc.h>

#pragma config FOSC = INTOSCIO  // Oscilador interno
#pragma config WDTE = OFF       // Watchdog Timer desativado
#pragma config PWRTE = OFF      // Power-up Timer desativado
#pragma config MCLRE = ON       // MCLR pin function is digital input
#pragma config BOREN = OFF      // Brown-out Reset habilitado
#pragma config LVP = OFF        // Low Voltage Programming desativado
#pragma config CPD = OFF        // Data EEPROM Memory Code Protection desativado
#pragma config CP = OFF         // Flash Program Memory Code Protection desativado

#define _XTAL_FREQ 4000000      // Frequência do oscilador externo

void main() {
    TRISB = 0x00; // Configura PORTB como saída
    while (1) {
        PORTB =  0x03; // Acende o LED
        for (int i = 0; i < 8; i++) {
            __delay_ms(500); // Espera 500 milissegundos
            PORTB = (unsigned char) (PORTB <<  1);
        }
        __delay_ms(1000); // Espera 500 milissegundos
    }
}

```










