#include <xc.h>

// Configurações do chip PIC16F887

#pragma config FOSC = INTRC_NOCLKOUT  // Oscilador interno, sem clock out
#pragma config WDTE = OFF             // Watchdog Timer desativado
#pragma config PWRTE = OFF            // Power-up Timer desativado
#pragma config MCLRE = ON             // MCLR pin habilitado, RE3 input pin desabilitado
#pragma config CP = OFF               // Program memory code protection desativado
#pragma config CPD = OFF              // Data memory code protection desativado
#pragma config BOREN = ON             // Brown-out Reset habilitado
#pragma config IESO = OFF             // Internal External Switchover bit desativado
#pragma config FCMEN = OFF            // Fail-Safe Clock Monitor desativado
#pragma config LVP = OFF              // Low Voltage Programming desabilitado

#define _XTAL_FREQ 4000000  // Define a frequência do oscilador interno como 4MHz

void main() {

    unsigned char i;

    OSCCON = 0x60; // Configura o oscilador interno para 4MHz

    TRISC = 0; // Configura PORTC como saída
    CCP1CON = 0x0C; // Modo PWM
    T2CON = 0x07; // Timer2 ON, prescaler de 16
    PR2 = 255; // Periodo do PWM

    while (1) {

        for (i = 40; i < 120; i += 20) {
            CCPR1L = i;
            __delay_ms(1000);
        }
        __delay_ms(5000);
        for (i = 40; i < 100; i += 5) {
            CCPR1L = i;
            __delay_ms(500);
        }
        __delay_ms(5000);
    }
}
