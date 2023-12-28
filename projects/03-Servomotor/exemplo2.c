#include <xc.h>

// Configurações do chip
#pragma config FOSC = INTOSCIO  // Oscilador interno, função de porta em RA6 e RA7
#pragma config WDTE = OFF       // Desativa o Watchdog Timer
#pragma config PWRTE = OFF      // Desativa o Timer de Power-up
#pragma config MCLRE = ON       // Função do pino MCLR é entrada digital
#pragma config BOREN = ON       // Ativa o Brown-out Reset
#pragma config LVP = OFF        // Programação de baixa tensão desativada
#pragma config CPD = OFF        // Proteção de código na memória de dados EE desativada
#pragma config WRT = OFF        // Proteção de escrita na memória de programa Flash desativada
#pragma config CP = OFF         // Proteção de código na memória de programa Flash desativada

#define _XTAL_FREQ 4000000  // Frequência do oscilador interno definida para 4MHz

void main() {
    TRISB = 0;             // Configura PORTB como saída
    CCP1CON = 0b00001100;  // Configuração do modo PWM
    T2CON = 0b00000111;    // Ativa o Timer2 com prescaler de 16
    PR2 = 13;              // Período do PWM

    // Inicia o Timer2
    TMR2 = 0;              // Reseta o contador do Timer2
    TMR2ON = 1;            // Liga o Timer2

    while (1) {
        CCPR1L = 3;       // Valor do PWM para posicionar o servo (ajuste conforme necessário)
        __delay_ms(1000);  // Espera 1 segundo
        CCPR1L = 6;       // Outro valor do PWM para mover o servo
        __delay_ms(1000);  // Espera 1 segundo
    }
}
