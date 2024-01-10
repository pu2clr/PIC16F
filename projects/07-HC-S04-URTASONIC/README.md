# PIC16F628A and HC-S04 Ultrasonic Sensor

The HC-SR04 Ultrasonic Sensor is a popular sensor used for measuring distance with high accuracy and stable readings. It operates by emitting an ultrasonic sound pulse and then measuring the time it takes for the echo to return. Features include:

- Range: Typically 2cm to 400cm.
- Accuracy: Can detect objects with precision, often around 3mm.
- Operating Voltage: Generally 5V.
- Interface: Consists of four pins - VCC, Trig (trigger), Echo, and GND.

Applications:
- Robotics for obstacle avoidance.
- Distance measurement in industrial environments.
- Proximity and level sensing applications.
- Parking sensors in vehicles.
- Projects requiring non-contact distance measurement.

The HC-SR04 is valued for its ease of use, affordability, and integration with microcontrollers like Arduino and PIC.



## Distance measurement example 

This application below utilizes the HC-SR04 sensor to measure the distance of an object and adjusts the color of an RGB LED based on the object's proximity. When an object is less than 10 cm away, the LED turns red, signaling close proximity. For distances between 10 and 30 cm, the LED changes to blue, indicating a medium range. At distances greater than 30 cm, the LED turns green, denoting a more distant object. This setup allows for an intuitive and visual representation of object distance.


## Schematic 

![PIC16F628A and HC-S04 Ultrasonic Sensor schematic](./schematic_pic16f628a_hc_s04_rgb_led.jpg)


## PIC16F628 program 

```cpp
#include <xc.h>

// Chip settings
#pragma config FOSC = INTOSCCLK // Internal oscillator, CLKOUT on RA6
#pragma config WDTE = OFF       // Disables Watchdog Timer
#pragma config PWRTE = OFF      // Disables Power-up Timer
#pragma config MCLRE = ON       // MCLR pin function is digital input
#pragma config BOREN = ON       // Enables Brown-out Reset
#pragma config LVP = OFF        // Low voltage programming disabled
#pragma config CPD = OFF        // Data EE memory code protection disabled
#pragma config CP = OFF         // Flash program memory code protection disabled

#define _XTAL_FREQ 4000000 // Internal oscillator frequency set to 4MHz


void inline set_red_light() {
    PORTB = 0b00000001;
}

void inline set_green_light() {
    PORTB = 0b00000010;
}

void inline set_blue_light() {
    PORTB = 0b00000100;

}

void inline turn_led_off() {
    PORTB = 0b00000000;
}

void main() {
    
    // Turns off the comparator and converts its pins in digital I/O. 
    CMCONbits.CM = 0x07; 

    // Sets the PORT A and B    
    TRISB = 0;; // Sets PORTB as output (RGB LED Control)
    TRISA0 = 0;  // TRIG pin  (HC-S04 TRIGGER output)
    TRISA1 = 1;  // ECHO pin  (HC-S04 ECHO input)
     

    // Checking the RGB LED - Playing with RGB LED before starting the real application.
    for (int i = 0; i < 6; i++) {
        set_red_light();
        __delay_ms(200);
        set_green_light();
        __delay_ms(200);
        set_blue_light();
        __delay_ms(200);
        turn_led_off();
        __delay_ms(200);
    } 
    while (1) {
        TMR1H = 0;  // sets the high byte of the Timer1 counter to 0
        TMR1L = 0;  // sets the low byte of the Timer1 counter to 0
        RA0 = 1;
        __delay_us(10);
        RA0 = 0;
        while(!RA1); // Wait for ECHO/RA1 pin becomes HIGH
        TMR1ON = 1;  // Turns TIMER1 on
        while(RA1);  // Wait for ECHO/RA1 pin becomes LOW
        TMR1ON = 0;  // Turns TIMER1 off        
        unsigned int duration = (unsigned int) (TMR1H << 8) | TMR1L;
        unsigned int distance = duration *0.034/2;
        if ( distance <= 10) 
            set_red_light();
        else if (distance <= 30 )
            set_blue_light();
        else
            set_green_light();
    }
}

```

## prototype

![PIC16F628A and HC-S04 Ultrasonic Sensor prototype](./prototype_pic16f628a_hc_s04_rgb_led.jpg)



## PIC16F876A with LCD and HC-S04 Ultrasonic sensor

### PIC16F876A with HC-S04 and LCD 16x2 schematic 

![PIC16F876A with LCD and HC-S04 Ultrasonic sensor](./schematic_pic16f876a_hc_s04_lcd16x2.jpg)



### PIC16F876A with HC-S04 and LCD 16x2 prototype

![PIC16F876A with HC-S04 and LCD 16x2 prototype 1](./prototype_pic16f876a_hc_s04_lcd.jpg)


![PIC16F876A with HC-S04 and LCD 16x2 prototype 2](./prototype_pic16f876a_hc_s04_lcd2.jpg)


## References

* [Ultrasonic Sensor HC-SR04 With PIC Microcontroller](https://www.trionprojects.org/2020/03/ultrasonic-sensor-hc-sr04-with-pic.html)
* [Ultrasonic Sensor HC-SR04 Code for PIC18F4550](https://www.electronicwings.com/pic/ultrasonic-module-hc-sr04-interfacing-with-pic18f4550)
* [Distance Measurement Using HC-SR04 Via NodeMCU](https://www.instructables.com/Distance-Measurement-Using-HC-SR04-Via-NodeMCU/)
