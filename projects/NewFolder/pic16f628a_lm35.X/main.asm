; PIC16F628A Configuration Bit Settings
; Assembly source line config statements
;    
; Author: Ricardo Lima Caratti - Jan/2024
;    
#include <xc.inc>
    
; CONFIG
  CONFIG  FOSC = INTOSCIO       ; Internal oscilator
  CONFIG  WDTE = OFF            ; Watchdog Timer Disable bit 
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RA5/MCLR/VPP Pin Function Select bit (RA5/MCLR/VPP pin function is MCLR)
  CONFIG  BOREN = ON            ; Brown-out Detect Enable bit (BOD enabled)
  CONFIG  LVP = OFF             ; Low-Voltage Programming Disable bit (RB4/PGM 
  CONFIG  CPD = OFF             ; Data EE Memory Code Protection bit (Data memory code protection off)
  CONFIG  CP = OFF     

  ; declare your variables here
var1 equ 0x20       ; Memory position (check the memory organization of your PIC device datasheet)
var2 equ 0x21       ;
    
PSECT resetVector, class=CODE, delta=2
resetVect:
    PAGESEL main
    goto main
PSECT code, delta=2
main:
    bsf	    STATUS, 5	; Select the Bank 1 - See PIC16F627A/628A/648A Data Sheet, page 20 and 21 (MEMORY ORGANIZATION)
    clrf    PORTB	; Initialize PORTB 
    clrf    TRISB
    movlw   0x1F        ; Turn on ADC, select RA0 as input
    movwf   TRISA	; Set RA<4:0> as inputs
    movwf   ANSELA  
    bcf	    STATUS, 5	; Return to Bank 0  

    ; example of using var 
    movlw 10
    movwf var1
    movlw 250
    movlw var2
    ;

loop:			    ; Endless loop
    ;
    ; Your application
    ;
    goto loop
     
    ;
    ; Your subroutines
    ;  

END resetVect

