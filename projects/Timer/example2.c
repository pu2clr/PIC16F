#include <xc.h>

// Configuração do microcontrolador
#pragma config FOSC = INTOSCIO        // Oscilador interno
#pragma config WDTE = OFF       // Watchdog Timer desativado
#pragma config PWRTE = OFF      // Power-up Timer desativado
#pragma config MCLRE = ON       // MCLR pin function is digital input
#pragma config BOREN = OFF       // Brown-out Reset habilitado
#pragma config LVP = OFF        // Low Voltage Programming desativado
#pragma config CPD = OFF        // Data EEPROM Memory Code Protection desativado
// #pragma config WRT = OFF        // Flash Program Memory Write Enable
#pragma config CP = OFF         // Flash Program Memory Code Protection desativado

#define _XTAL_FREQ 4000000      // Frequência do oscilador externo

void main() {
    TRISB = 0x00; // Configura PORTB como saída


    while (1) {
        PORTB =  0x03; // Acende o LED
        for (int i = 0; i < 8; i++) {
            __delay_ms(500); // Espera 500 milissegundos
            PORTB = (unsigned char) (PORTB <<  1);
        }
        __delay_ms(1000); // Espera 500 milissegundos
    }
}
