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

// Calculate the distance in cm based on the time in us.
double calculateDistance(unsigned int  timeEcho) {
    return ( ( timeEcho * 0.000340 ) / 2) * 100;
}


void main() {
    
    TRISB = 0b00100000; // Sets PORTB as output
    // Sets PORTB
    // RB0, RB1 and RB2 are output to control the RGB LED
    // RB4 is the ECHO (input) signal of the ultrassom sensor
    // RB5 is output (trigger)
    // Same: 
    TRISB4 = 0; // TRIG_PIN output
    TRISB5 = 1; // ECHO_PIN input
    
    

    // Checking the RGB LED
    /*
    for (int i = 0; i < 6; i++) {
        set_red_light();
        __delay_ms(500);
        set_green_light();
        __delay_ms(500);
        set_blue_light();
        __delay_ms(500);
        turn_led_off();
        __delay_ms(500);
    } */
   
    while (1) {
        // Sends a pulse to the RB4
        RB4 = 1;
        __delay_us(10); // 
        RB4 = 0;
        while(!RB5);
        TMR1 = 0; // Start the Timer1
        while(RB5);
        unsigned int duration = TMR1;
        int distance = (int) calculateDistance(600);
        if ( distance <= 1) 
            set_red_light();
        else if (distance <= 30 )
            set_blue_light();
        else
            set_green_light();
    }
}
