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
