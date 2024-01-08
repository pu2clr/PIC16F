# PIC16F628A RGB LED (Anode and Cathode setup)


## RGB LED Common Anode

### Schematic (A)


![Common Anode schematic](./schematic_pic16f628a_rgb_led_common_anode.jpg)


### Source Code (Common Anode) 

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

void main() {
    TRISB = 0; // Sets PORTB as output
    unsigned char dutyCycle;
    
    PORTB = 0xFF; // Turn all LEDs off.
    __delay_ms(5000);
    while(1) {
        for(dutyCycle = 0; dutyCycle < 255; dutyCycle++) {
            RB0 = (dutyCycle < 128)? 1:0;
            RB1 = (dutyCycle < 64 || (dutyCycle > 192))? 1:0;
            RB2 = (dutyCycle > 128)? 1:0;
            __delay_ms(50); 
        }
    }
} 
```

### Prototype (Common Anode) 

![Prototype - Common Anode](./prototype_pic16f628a_rgb_led_common_anode.jpg)



## RGB LED Common Cathode 


### Schematic (K)

![Common Cayhode schematic](./schematic_pic16f628a_rgb_led_common_cathode.jpg)


### Source Code (Common Cathode) 

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

#define _XTAL_FREQ 4000000 // 4 MHz

void main() {
    TRISB = 0; // Sets PORTB as output
    unsigned char dutyCycle;
    
    PORTB = 0x00; // Turn all LEDs off.
    __delay_ms(5000);
    while(1) {
        for(dutyCycle = 0; dutyCycle < 255; dutyCycle++) {
            RB0 = (dutyCycle < 128)? 0:1;
            RB1 = (dutyCycle < 64 || (dutyCycle > 192))? 0:1;
            RB2 = (dutyCycle > 128)? 0:1;
            __delay_ms(50); 
        }
    }
}

```

### Prototype (Common Cathode) 

![Prototype Common Cathode](./prototype_pic16f628a_rgb_led_common_cathode.jpg)



## References

* [How do RGB LEDs work](https://randomnerdtutorials.com/electronics-basics-how-do-rgb-leds-work/)
* [LED RGB -ALTERANDO CORES POR MEIO DA APROXIMAÇÃO DE OBJETOS – C/ PIC 16F628A (REF295)](http://picsource.com.br/archives/11199)
* [PIC16F628 4 RGB LED PWM Controller](https://www.next.gr/circuits/PIC16F628-4-RGB-LED-PWM-Controller-l52521.html)
* [Lighting up RGB LED Strip with a PIC Microcontroller](https://blog.kubovy.eu/2019/03/30/lighting-up-rgb-led-strip-with-a-pic-microcontroller/)
