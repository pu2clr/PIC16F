
#include <xc.h>

// CONFIG
#pragma config WDTE = OFF       // Watchdog Timer (WDT disabled)
#pragma config CP = OFF         // Code Protect (Code protection off)
#pragma config MCLRE = OFF      // Master Clear Enable (GP3/MCLR pin fuction is digital I/O, MCLR internally tied to VDD)

#define _XTAL_FREQ  4000000



void inline delayMS(uint8_t param) {
    for (uint8_t i = 0; i < param; i++) {
        for (uint8_t j = 0; j < 200; j++) { 

        }
    }
}

void RotateServo(uint8_t duration) {
    char i = 22;
    do {
        GP2 = 1;
        delayMS(duration);
        GP2 = 0;
        delayMS(25);
    } while (i--);
}

void main(void) {
    
    // OPTION register setup 
    // Prescaler Rate: 256
    // Prescaler assigned to the WDT
    // Increment on high-to-low transition on the T0CKI pin
    // Transition on internal instruction cycle clock, FOSC/4
    // GPPU disabled 
    // GPWU disabled
    OPTION = 0B10011111; 
    GPIO = 0;
    TRISGPIO = 0B00001011;      // GP0, GP1 and GP3 as input and GP2 as output

    
    __delay_ms(2000);
    RotateServo(3);
    __delay_ms(2000);
    RotateServo(2);
    while (1) {
        if (GP3 == 0) RotateServo(3);
        if (GP1 == 0) RotateServo(4);
        if (GP0 == 0) RotateServo(2);
        __delay_ms(3);
    }

}
