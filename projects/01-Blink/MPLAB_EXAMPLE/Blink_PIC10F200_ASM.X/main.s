; BLINK LEDS with PIC10F200
; My PIC Journey
; Author: Ricardo Lima Caratti
; Jan/2024
;
; IMPORTANT: To assemble this code correctly, please follow the steps below:
; 1. Go to "Project Properties" in MPLAB X.
; 2. Select "Global Options" for the pic-as assembler/compiler.
; 3. In the "Additional Options" box, enter the following parameters:
; -Wl,-pBlinkCode=0h
;
; Please check the BlinkCode reference in the "PSECT" directive below.
;
; You will find good tips about the PIC10F200 here:
; https://www.circuitbread.com/tutorials/christmas-lights-special-microcontroller-basics-pic10f200

 
    
#include <xc.inc>

; CONFIG
  CONFIG  WDTE = OFF           ; Watchdog Timer (WDT disabled)
  CONFIG  CP = OFF             ; Code Protect (Code protection off)
  CONFIG  MCLRE = ON	       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)

  
; Declare your variables here

dummy1 equ 0x10
dummy2 equ 0x11
dummy3 equ 0x12 
 
PSECT BlinkCode, class=CODE, delta=2

MAIN:
    clrf   GPIO		    ; Sets all GPIO pins as output
    TRIS   GPIO
    
MainLoop:		    ; Endless loop
    call    Delay
    bsf	    GPIO,0	    ; Turn the LED on	
    call    Delay
    bcf	    GPIO,0	    ; Turn the LED off	
    goto    MainLoop
     
; ******************
; Delay function
;
; For an oscillator of 4MHz a regular instructions takes 1us (See pic16f628a Datasheet, page 117).      
; So, at 4MHz, this Delay subroutine takes about: (5 cycles) * 255 * 255 * delayParam * 0.000001 (second)  
; It is about 1s (0.975 s)  - One second  if delayParam is 3
Delay:  
    movlw   3
    movwf   dummy3
    movlw   255
    movwf   dummy1      ; 255 times
    movwf   dummy2      ; 255 times (255 * 255)
			; 255 * 255 * delayParam loaded before calling Delay    
DelayLoop:    
    nop                 ; One cycle
    nop                 ; One cycle
    decfsz  dummy1, f   ; One cycle* (dummy1 = dumm1 - 1) => if dummy1 is 0, after decfsz, it will be 255
    goto    DelayLoop      ; Two cycles
    decfsz  dummy2, f   ; dummy2 = dumm2 - 1; if dummy2 = 0, after decfsz, it will be 255
    goto    DelayLoop
    decfsz  dummy3,f	; Runs 3 times (255 * 255)		 
    goto    DelayLoop
    retlw   0
    
END MAIN



