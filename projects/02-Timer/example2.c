#include <xc.h>

#pragma config FOSC = INTOSCIO  // Internal Oscillator
#pragma config WDTE = OFF       // Watchdog Timer disabled
#pragma config PWRTE = OFF      // Power-up Timer disabled
#pragma config MCLRE = ON       // MCLR pin function is digital input
#pragma config BOREN = OFF       // Brown-out Reset enabled
#pragma config LVP = OFF        // Low Voltage Programming disabled
#pragma config CPD = OFF        // Data EEPROM Memory Code Protection disabled
#pragma config CP = OFF         // Flash Program Memory Code Protection disabled

#define _XTAL_FREQ 4000000      // Internal Oscillator Frequency

void main() {
    TRISB = 0x00; // Sets PORT B as output


    while (1) {
        PORTB =  0x03; // turn the first two LEDs on
        
        do {
            __delay_ms(500);
        } while ( (PORTB = (unsigned char) (PORTB <<  1)) ); 
        __delay_ms(1000);
    }
}
