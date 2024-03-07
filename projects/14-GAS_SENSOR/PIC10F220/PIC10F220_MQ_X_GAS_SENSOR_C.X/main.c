// CONFIG
// CONFIG
#pragma config IOSCFS = 4MHZ    // Internal Oscillator Frequency Select bit (4 MHz)
#pragma config MCPU = OFF       // Master Clear Pull-up Enable bit (Pull-up disabled)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config CP = OFF         // Code protection bit (Code protection off)
#pragma config MCLRE = OFF      // GP3/MCLR Pin Function Select bit (GP3/MCLR pin function is digital I/O, MCLR internally tied to VDD)

#define _XTAL_FREQ  4000000

#include <xc.h>


void main(void) {

    // TIMER0 AND PRESCALER SETUP
    // TOCS = 0 => INTERNAL INSTRUCTION CYCLE; 
    // PSA = 0 => TIMER0; and
    // PRESCALER (PS2,PS1 AND PS0 => 1:128)
    // OPTION = 0B11010110;     
    TRIS = 0B00000000;           

    while (1) {
           GP2 = 1;
           __delay_ms(500);
           GP2 = 0;
           __delay_ms(1000);
          
    }
}
