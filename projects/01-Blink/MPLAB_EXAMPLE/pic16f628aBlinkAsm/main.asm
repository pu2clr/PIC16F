
; PIC16F628A Configuration Bit Settings

; Assembly source line config statements

#include <xc.inc>
    
; CONFIG
  CONFIG  FOSC = INTOSCIO       ; Oscillator Selection bits (INTOSC oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = ON             ; Watchdog Timer Enable bit (WDT enabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RA5/MCLR/VPP Pin Function Select bit (RA5/MCLR/VPP pin function is MCLR)
  CONFIG  BOREN = ON            ; Brown-out Detect Enable bit (BOD enabled)
  CONFIG  LVP = ON              ; Low-Voltage Programming Enable bit (RB4/PGM pin has PGM function, low-voltage programming enabled)
  CONFIG  CPD = OFF             ; Data EE Memory Code Protection bit (Data memory code protection off)
  CONFIG  CP = OFF              ; Flash Program Memory Code Protection bit (Code protection off)

// config statements should precede project file includes.

  
PSECT resetVector, class=CODE, delta=2
resetVect:
    PAGESEL main
    goto main
PSECT code, delta=2
main: 
    clrf PORTB	    ; Initialize PORTB by setting output data latches
    movlw 0x07	    ; Turn comparators and 
    movwf CMCON	    ; Enable pins for I/O functions 
loop:		    ; Loop without a stopping condition - here is your application code
    bcf PORTB, 0
    bsf PORTB, 0
    goto loop
END resetVect
    

