;
; UNDER CONSTRUCTION...
;
    
#include <xc.inc>
    
; CONFIG
  CONFIG  IOSCFS = 4MHZ         ; Internal Oscillator Frequency Select bit (4 MHz)
  CONFIG  MCPU = OFF            ; Master Clear Pull-up Enable bit (Pull-up disabled)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled)
  CONFIG  CP = OFF              ; Code protection bit (Code protection off)
  CONFIG  MCLRE = ON            ; GP3/MCLR Pin Function Select bit (GP3/MCLR pin function is MCLR)

  
; Declare your variables here

 
PSECT BlinkCode, class=CODE, delta=2

MAIN:
    nop
MainLoop:		    ; Endless loop
    nop
    goto    MainLoop
     

    
END MAIN






  


