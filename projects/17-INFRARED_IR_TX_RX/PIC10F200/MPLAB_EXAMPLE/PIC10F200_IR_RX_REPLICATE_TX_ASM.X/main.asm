; This program just repicates the signal of the IR transmitter
; A regular LED whil show the signal send by the transmitter.
;    
; IMPORTANT: If you are using the PIC10F200, to assemble this code correctly, please follow the steps below:
; 1. Go to "Project Properties" in MPLAB X.
; 2. Select "Global Options" for the pic-as assembler/compiler.
; 3. In the "Additional Options" box, enter the following parameters:
; -Wl,-pAsmCode=0h
    
#include <xc.inc>
 
 
    
; CONFIG
  CONFIG  WDTE = OFF           ; Watchdog Timer (WDT disabled)
  CONFIG  CP = OFF             ; Code Protect (Code protection off)
  CONFIG  MCLRE = OFF	         
  
; Declare your variables here  
  
PSECT AsmCode, class=CODE, delta=2

MAIN:
    ; GPIO and registers setup
    clrf   GPIO		    ; Sets all GPIO pins as output
    movlw  0B00000001	    ; Set GP0 as input and GP1 as output
    TRIS   GPIO
    
MainLoop:		    ; Endless loop
    ; While GP0 is 0
    btfsc   GPIO, 0
    goto    LEDOn 
    bcf	    GPIO, 1	    ; Turn the LED OFF
    goto    MainLoop
LEDOn:
    bsf	    GPIO, 1	    ; Turn the LED ON
    goto    MainLoop

    
END MAIN









