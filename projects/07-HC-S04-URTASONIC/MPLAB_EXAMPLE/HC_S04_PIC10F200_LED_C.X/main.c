/*
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

    // TIMER0 AND PRESCALER SETUP
    // TOCS = 0 => INTERNAL INSTRUCTION CYCLE; 
    // PSA = 0 => TIMER0; and
    // PRESCALER (PS2,PS1 AND PS0 => 1:128)
    OPTION = 0B11010110;     
    //GPIO SETUP
    // GP0 -> LED/output; 
    // GP1 -> Trigger/output; and 
    // GP2 = Echo/input 
    TRIS = 0B00000100;           

    while (1) {
        // Using the trigger pin to sen Send 10uS signal 
        GP1 = 1;
        __delay_us(10);
        GP1 = 0;

        // Wait for echo
        do {
        } while (!GP2);
        TMR0 = 0; // It will increment every 128 cycles (at 4MHz one cycle is 1us).
        do {
        } while (GP2);
    
        // TRM0 * 128 represents the number of cycles. Therefore, a value of 1 
        // equates to 128 cycles. Based on this, 128 cycles correspond to 2 cm. 
        // However, calibration may be necessary for accurate measurements.
        // See: https://www.circuitbread.com/tutorials/obstacle-avoidance-robot-part-14-microcontroller-basics-pic10f200
        if (TMR0 < 2 ) //  
            GP0 = 1;
        else
            GP0 = 0;
        __delay_ms(100);

    }
}
