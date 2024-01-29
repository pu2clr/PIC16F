/*
 * UNDER CONSTRUCTION
 * This experiment uses the PIC10F200 and the HC-S04 ultrasonic distance sensor. 
 * It utilizes one LEDs to indicate, a distance  * of less than 10 cm. 
 * Author: Ricardo Lima Caratti
 * Jan/2024
 */

// CONFIG
#pragma config WDTE = OFF       // Watchdog Timer (WDT disabled)
#pragma config CP = OFF         // Code Protect (Code protection off)
#pragma config MCLRE = OFF      // Master Clear Enable (GP3/MCLR pin fuction is digital I/O, MCLR internally tied to VDD)

#define _XTAL_FREQ  4000000

#include <xc.h>

void main(void) {
    TRIS = 0B00000100; // GP0 -> LED/output; GP1 -> Trigger/output; and GP2 = Echo/input      

    while (1) {
        // Send 10uS signal to the Trigger pin
        GP1 = 1;
        __delay_us(10);
        GP1 = 0;

        // Wait for echo
        do {
        } while (!GP2);
        TMR0 = 0; // It will increment every cycle (each cycle takes 1us at 4MHz).
        do {
        } while (GP2);

        // TRM0 has the number of cycles. Check here how many cycles to process echo.
        if (TMR0 > 118) // 118 us is about 4 cm    
            GP0 = 1;
        else
            GP0 = 0;
        __delay_ms(100);
    }
}
