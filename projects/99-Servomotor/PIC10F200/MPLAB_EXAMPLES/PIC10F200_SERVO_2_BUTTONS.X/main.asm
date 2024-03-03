; UNDER CONSTRUCTION...
;    
; IMPORTANT: If you are using the PIC10F200, to assemble this code correctly, please follow the steps below:
; 1. Go to "Project Properties" in MPLAB X.
; 2. Select "Global Options" for the pic-as assembler/compiler.
; 3. In the "Additional Options" box, enter the following parameters:
; -Wl,-pBlinkCode=0h
    
#include <xc.inc>

; CONFIG
  CONFIG  WDTE = OFF           ; Watchdog Timer (WDT disabled)
  CONFIG  CP = OFF             ; Code Protect (Code protection off)
  CONFIG  MCLRE = ON	       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)

  
; Declare your variables here

 
PSECT BlinkCode, class=CODE, delta=2

MAIN:
    ; GPIO and registers setup
    clrf   GPIO		    ; Sets all GPIO pins as output
    movlw  0B00000011	    ; GP0 and GP1 are input  
    TRIS   GPIO
    
MainLoop:		    ; Endless loop
    call    CheckButtons
    
    goto    MainLoop
    
    
CheckButtons:
    btfsc   GPIO, 0 
    retlw   0
    btfsc   GPIO, 0 
    retlw   1
    
    retlw   2
    
    
RotateServo: 
    
    retlw   0

    
    
END MAIN



