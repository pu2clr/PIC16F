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
    
    TRISB = 0;; // Sets PORTB as output
    
    TRISAbits.TRISA0 = 0;  // TRIG pin
    TRISAbits.TRISA1 = 1;  // ECHO pin
    
    
    // TIMER1 Configuration
    // Prescaler = 1:1
    T1CONbits.T1CKPS = 0b00;
    // Select internal clock (FOSC/4)
    T1CONbits.TMR1CS = 0;

    // Checking the RGB LED
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
        
        TMR1H = 0;
        TMR1L = 0;

        PORTAbits.RA0 = 1;
        __delay_us(10);
        PORTAbits.RA0 = 0;
        // Wait for ECHO pin goes to HIGH
        while(!PORTAbits.RA1);
        T1CONbits.TMR1ON = 1;   // Enable TIMER1 module
        // Wait for ECHO pin goes to LOW
        while(PORTAbits.RA1);
        T1CONbits.TMR1ON = 0;   // Disable TIMER1 module        
      
        unsigned int duration = (unsigned int) (TMR1H << 8) | TMR1L;
        unsigned int distance = (unsigned int) ( (float) (duration / 58.8235) + 1);
        
        if ( distance <= 10) 
            set_red_light();
        else if (distance <= 30 )
            set_blue_light();
        else
            set_green_light();
    }
}
