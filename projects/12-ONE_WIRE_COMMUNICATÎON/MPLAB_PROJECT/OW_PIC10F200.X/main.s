; One Wire implementation
    
; My PIC Journey
; Author: Ricardo Lima Caratti
; Jan/2024
;
; IMPORTANT: To assemble this code correctly, please follow the steps below:
; 1. Go to "Project Properties" in MPLAB X.
; 2. Select "Global Options" for the pic-as assembler/compiler.
; 3. In the "Additional Options" box, enter the following parameters:
; -Wl,-pAsmCode=0h
;
; Please check the AsmCode reference in the "PSECT" directive below.
;
; You will find good tips about the PIC10F200 here:
; https://www.circuitbread.com/tutorials/christmas-lights-special-microcontroller-basics-pic10f200

 
DELAY_10us MACRO
    goto $ + 1
    goto $ + 1
    goto $ + 1
    goto $ + 1
    goto $ + 1  
ENDM

DELAY_100us MACRO
    movlw  10
    movwf  dummy1
    nop
    goto $ + 1	    ; 2 cycles
    goto $ + 1	    ; 2 cycles
    goto $ + 1	    ; 2 cycles
    goto $ + 1	    ; 2 cycles
    goto $ + 1      ; 2 cycles
    decfsz dummy1, f
    goto $ - 6
 ENDM    
    
    
    
#include <xc.inc>

; CONFIG
  CONFIG  WDTE = OFF           ; Watchdog Timer (WDT disabled)
  CONFIG  CP = OFF             ; Code Protect (Code protection off)
  CONFIG  MCLRE = ON	       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)

  
; Declare your variables here

dummy1 equ 0x10
 
PSECT AsmCode, class=CODE, delta=2

MAIN:
    
    movlw  0B11010110	    ;   
    option
    movlw   0B00000100
    tris    GPIO

MainLoop:  
    nop
    nop
    nop
    goto    MainLoop    
    
    
    
OW_START: 
    
    retlw   0

    
OW_WRITE_BIT:
    
    retlw   0

OW_WRITE_BYTE: 
    
    retlw   0
    
OW_READ_BIT: 
    
    retlw   0

OW_READ_BYTE:
    
    retlw   0
    
; It takes 200 us    
Delay_200us: 
    movlw  20
    movwf  dummy1
LoopDelay200us: 
    DELAY_10us    
    decfsz dummy1, f
    goto LoopDelay200us
    retlw   0
    
END MAIN    
