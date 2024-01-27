; BLINK  LED with PIC10F200
; My PIC Journey   
; Author: Ricardo Lima Caratti
; Jan/2024
    
#include <xc.inc>

; CONFIG
  CONFIG  WDTE = OFF           ; Watchdog Timer (WDT disabled)
  CONFIG  CP = OFF             ; Code Protect (Code protection off)
  CONFIG  MCLRE = ON	       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)

  
; declare your variables here

    
PSECT resetVector, class=CODE, delta=2
  
resetVect:
    PAGESEL main
    goto main
PSECT code, delta=2
main:
    movlw 0B00001000 
    TRIS GPIO		    ; GPIO as output  
    movlw 0B11011111	    ; OPTION Register setup
    OPTION	
MainLoopBegin:		    ; Endless loop
    nop
    nop
    nop
    call    Delay
    bsf	    GPIO,0	
    call    Delay
    bcf	    GPIO,0	
    goto    MainLoopBegin
     
; ******************
; Delay function
;
; For an oscillator of 4MHz a regular instructions takes 1us (See pic16f628a Datasheet, page 117).      
; So, at 4MHz, this Delay subroutine takes about: (5 cycles) * 255 * 255 * delayParam * 0.000001 (second)  
; It is about 1s (0.975 s)  - One second  if delayParam is 3
Delay:  
    nop
    nop
    retlw 0
    
END resetVect



