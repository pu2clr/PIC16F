; UNDER CONSTRUCTION...
; IMPORTANT: If you are using the PIC10F200, to assemble this code correctly, please follow the steps below:
; 1. Go to "Project Properties" in MPLAB X.
; 2. Select "Global Options" for the pic-as assembler/compiler.
; 3. In the "Additional Options" box, enter the following parameters:
; -Wl,-pAsmCode=0h
    
#include <xc.inc>

; CONFIG
  CONFIG  WDTE = OFF           ; Watchdog Timer (WDT disabled)
  CONFIG  CP = OFF             ; Code Protect (Code protection off)
  CONFIG  MCLRE = ON	       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)


; Macro - Send a single bit  
sendBit MACRO
    nop
 
ENDM

sendPulse9ms MACRO
    nop
ENDM
    
delay4dot5ms MACRO
    nop
ENDM

    
  
; Declare your variables here

workValue1  equ	0x10    
workValue2  equ 0x11		

 
PSECT AsmCode, class=CODE, delta=2

MAIN:
    ; GPIO and registers setup
    clrf   GPIO		    ; Sets all GPIO pins as output
    clrw
    TRIS   GPIO
    
MainLoop:		    ; Endless loop
 
    movlw   10
    movwf   workValue1
    call    CheckIR
 
    goto    MainLoop
    
    
   
CheckIR: 
    nop
    retlw   0    


sendByte: 
    nop
    retlw   0


sendNEC: 
    
    retlw   0
    
END MAIN



