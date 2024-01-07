#include <xc.h>

#pragma config FOSC = INTOSCIO  // Internal Oscillator
#pragma config WDTE = OFF       // Watchdog Timer disabled
#pragma config PWRTE = OFF      // Power-up Timer disabled
#pragma config MCLRE = ON       // MCLR pin function is digital input
#pragma config BOREN = OFF       // Brown-out Reset enabled
#pragma config LVP = OFF        // Low Voltage Programming disabled
#pragma config CPD = OFF        // Data EEPROM Memory Code Protection disabled
#pragma config CP = OFF         // Flash Program Memory Code Protection disabled

#define _XTAL_FREQ 4000000      

void main() {
    TRISB = 0x00; // Configura PORTB como saída
    while (1) {
        PORTB =  0xFF; // Turn all LEDs on
        // Try: while ( (PORTB = (unsigned char) (PORTB <<  1)) ) {__delay_ms(7500);}
        // Istead the for statment below        
        for (int i = 0; i < 8; i++) {
            __delay_ms(7500); 
            PORTB = (unsigned char) (PORTB <<  1);
        }
        __delay_ms(15000); 
    }
}
