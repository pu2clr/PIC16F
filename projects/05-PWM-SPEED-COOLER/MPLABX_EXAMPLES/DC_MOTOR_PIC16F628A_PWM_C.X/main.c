/**
 * DC MOTOR controller using PWM and PIC628A
 * 
 * Author: Ricardo Lima Caratti
 * Jan 2004
 */
#include <xc.h>

#pragma config FOSC = INTOSCCLK // Oscilador interno, CLKOUT no RA6
#pragma config WDTE = OFF       // Desativa o Watchdog Timer
#pragma config PWRTE = OFF      // Desativa o Timer de Power-up
#pragma config MCLRE = ON       // Fun��o do pino MCLR � entrada digital
#pragma config BOREN = ON       // Ativa o Brown-out Reset
#pragma config LVP = OFF        // Programa��o de baixa tens�o desativada
#pragma config CPD = OFF        // Prote��o de c�digo na mem�ria de dados EE desativada
#pragma config CP = OFF         // Prote��o de c�digo na mem�ria de programa Flash desativada

#define _XTAL_FREQ 4000000 // Frequ�ncia do oscilador interno definida para 4MHz

void main()
{
    TRISB = 0;            // Sets PORTB - output
    CCP1CON = 0b00001100; // Sets PWM
    T2CON = 0b00000111;   // Sets Timer2 prescaler of 16
    PR2 = 255;             // Sets PWM period

 
    TMR2 = 0;   // Resets Timer2 
    TMR2ON = 1; // Sets Timer2 ON 

    while (1)
    {

        // Minimum Speed
        CCPR1L = 27;
        __delay_ms(5000);
        
                // Average Speed
        CCPR1L = 33;
        __delay_ms(5000);

        // Maximum Speed
        CCPR1L = 55;
        __delay_ms(5000);
    }
}

