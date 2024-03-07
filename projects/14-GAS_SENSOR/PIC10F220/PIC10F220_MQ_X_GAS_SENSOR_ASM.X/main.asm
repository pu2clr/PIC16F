; UNDER CONSTRUCTION... 
; My PIC Journey  - MQ-2 Gas sensor and PIC10F220
; 
; ATTENTION: This experiment is solely intended to demonstrate the interfacing of an MQ series gas sensor 
; with PIC microcontrollers. The gas concentration values and thresholds used in the example programs have 
; been arbitrarily set to illustrate high, medium, or low gas concentration levels. However, it is crucial 
; to emphasize that these values may not accurately reflect the real concentrations that pose a health risk. 
; Therefore, if you plan to use the examples provided, it is strongly recommended to consult the gas sensor's Datasheet. 
; This is essential to ascertain the exact values that define dangerous, tolerable, or low gas concentrations.  
; Author: Ricardo Lima Caratti
; Feb/2022   
; Servo controll with PIC10F200
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

; Declare your variables here

counter1	equ	0x10
counter2	equ	0x11
	
	 
PSECT AsmCode, class=CODE, delta=2

MAIN:
    ; GP1 is digital I/O
    ; GP0 is analog input
    ; ADC channel is GP0/AN0
    ; GO/DONE enabled
    movlw   0B01000011
    movwf   ADCON0
    ; GP0 is input, GP1, GP2 and GP3 are output
    movlw   0B00000001
    TRIS    GPIO
MainLoop:		    ; Endless loop
    bsf	    GPIO, 2
    call    DELAY_600ms
    bcf	    GPIO,   2
    call    DELAY_600ms
MainLoopContinue: 
     
   goto    MainLoop
    
    
; ***********************    
; It takes about 600ms 
DELAY_600ms:
  
    movlw   255
    movwf   counter1
DELAY_LOOP_01:
    movlw   255
    movwf   counter2
DELAY_LOOP_02: 
    goto $+1
    goto $+1
    goto $+1
    goto $+1
    decfsz  counter2, f
    goto    DELAY_LOOP_02
    decfsz  counter1, f
    goto    DELAY_LOOP_01
    
    retlw   0    
        
    
END MAIN







