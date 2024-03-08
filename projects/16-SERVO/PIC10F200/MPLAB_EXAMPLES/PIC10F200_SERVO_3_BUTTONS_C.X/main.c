/**
 * UNDER CONSTRUCTION...
 *  
 * @param param
 */


#include <xc.h>

// CONFIG
#pragma config WDTE = OFF       // Watchdog Timer (WDT disabled)
#pragma config CP = OFF         // Code Protect (Code protection off)
#pragma config MCLRE = OFF      // Master Clear Enable (GP3/MCLR pin fuction is digital I/O, MCLR internally tied to VDD)


// it takes about param x 255 us
void inline delayMS(uint8_t param) {
    for (uint8_t i = 0; i < param; i++) {
        for (uint8_t j = 0; j < 100; j++) { 
            asm("nop");
        }
    }
}


void RotateServo(uint8_t duration) {
    char i = 22;
    do {
        GP2 = 1;
        delayMS(duration);
        GP2 = 0;
        delayMS(22);
    } while (i--);
}

void main(void) {
    

    OPTION = 0B10010000; 
    TRIS = 0B00001011;      // GP0, GP1 and GP3 as input and GP2 as output

    RotateServo(3);
    delayMS(255);
    delayMS(255);
    delayMS(255);
    delayMS(255);
    RotateServo(2);
    
    while (1) {
        if (GP3 == 0) 
            RotateServo(3);
        else if (GP1 == 0) 
            RotateServo(4);
        else if (GP0 == 0) 
            RotateServo(2);
        
        delayMS(40);
    }

}
