; Fever Indicator with PIC12F675 with LM35 or TMP36
; Author: Ricardo Lima Caratti
; Jan/2024
    
#include <xc.inc>

; CONFIG
  CONFIG  FOSC = INTRCIO        ; Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-Up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; GP3/MCLR pin function select (GP3/MCLR pin function is MCLR)
  CONFIG  BOREN = ON            ; Brown-out Detect Enable bit (BOD enabled)
  CONFIG  CP = OFF              ; Code Protection bit (Program Memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled) 
  
; declare your variables here
var1 equ 0x20       ; General Purpose Registers(check the memory organization of your PIC device datasheet)
var2 equ 0x21       ;
    
PSECT resetVector, class=CODE, delta=2
resetVect:
    PAGESEL main
    goto main
PSECT code, delta=2
main:
    ; Set Analog and Digital pins (GPIO)
    bcf STATUS, 5	    ; Select Bank 0
    clrf GPIO		    ;Init GPIO
    movlw 0B00000001	    ; GP0 = DIGITAL 
    movwf CMCON		    ; digital IO
    bsf STATUS, 5 ; Select Bank 1
    bsf TRISIO, 1	    ; Sets GP1 as input 
   
    ; TO BE CONTINUE....

    ;

loop:			    ; Endless loop
    ;
    ; The temperature reading  process
    ;
    goto loop
     
    ;
    ; Your subroutines
    ;  

END resetVect


