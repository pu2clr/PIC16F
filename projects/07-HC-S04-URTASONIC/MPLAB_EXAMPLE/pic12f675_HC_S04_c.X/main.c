#include <xc.h>

// 
#pragma config FOSC = INTRCIO   // Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = OFF      // Power-Up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = ON       // GP3/MCLR pin function select (GP3/MCLR pin function is MCLR)
#pragma config BOREN = ON       // Brown-out Detect Enable bit (BOD enabled)
#pragma config CP = OFF         // Code Protection bit (Program Memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)

#define _XTAL_FREQ 4000000      // internal clock


/**
 * Turns All LEDS Off 
 */
void inline AllOff() {
    GPIObits.GP0 =  0;
    GPIObits.GP1 =  0;
    GPIObits.GP2 =  0;
}

/**
 * Turns Green LED On
 */
void inline GreenOn() {
    // AllOff();
    GP0 = 1;
}

/**
 * Turns Yellow LED On
 */
void inline YellowOn() {
    AllOff();
    GPIObits.GP1 =  1;
}

/**
 * Turns Red LED On
 */
void RedOn() {
    AllOff();
    GPIObits.GP2 =  1;
}

void main() {

    OSCCALbits.CAL = 0b111111; // 4Mhz
    TRISIObits.TRISIO5 = 0;    // Trigger
    TRISIObits.TRISIO4 = 1;    // Echo
    TRISIObits.TRISIO1 = 0;    // Output

    ANSELbits.ANS = 0b0000;

    T1CONbits.T1CKPS = 0b00; // 1:1 Prescale Value
    T1CONbits.TMR1CS = 0;    // Internal clock (Fosc/4) = 1Mz
    
    
    GreenOn(); 
    GPIO = 0xFF;
    __delay_ms(5000);

    while (1) {
        
        // Reset TMR1
        TMR1H = 0;
        TMR1L = 0;

        // Send 10uS signal to the Trigger pin
        GPIObits.GP5 = 1;
        __delay_us(10);
        GPIObits.GP5 = 0;

        // Wait for sensor response
        while (!GPIObits.GP4);
        T1CONbits.TMR1ON = 1;
        while (GPIObits.GP4);
        T1CONbits.TMR1ON = 0;

        
        unsigned int duration = (unsigned int) (TMR1H << 8) | TMR1L;

        if ( duration <= 588)  // 588 is the time for 10 cm ->  if 10 cm * 3 / 0,034 > 588
            RedOn();
        else if (duration <= 1764 ) // 1764 is the time for 30 cm -> if 30 cm * 3 / 0,034 <= 1764 
            YellowOn();
        else
            GreenOn();

    }
}

