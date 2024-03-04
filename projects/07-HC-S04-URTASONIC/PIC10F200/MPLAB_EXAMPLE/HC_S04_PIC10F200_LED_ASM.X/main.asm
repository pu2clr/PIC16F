; HC-S04 with PIC10F200
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

    
#include <xc.inc>

; CONFIG
  CONFIG  WDTE = OFF           ; Watchdog Timer (WDT disabled)
  CONFIG  CP = OFF             ; Code Protect (Code protection off)
  CONFIG  MCLRE = ON	       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)
  
; Declare your variables here

dummy1 equ 0x10
 
PSECT AsmCode, class=CODE, delta=2

MAIN:
    
    ; TIMER0 AND PRESCALER SETUP
    ; TOCS = 0 => INTERNAL INSTRUCTION CYCLE; 
    ; PSA = 0 => TIMER0; and
    ; PRESCALER (PS2,PS1 AND PS0 => 1:128)
    movlw  0B11010110	    ;   
    option
    ; GPIO SETUP
    ; GP0 -> LED/output; 
    ; GP1 -> Trigger/output; and 
    ; GP2 = Echo/input 
    movlw   0B00000100
    tris    GPIO
MainLoop:		    ; Endless loop
    bsf	    GPIO,1	    ; Send 10us signal via GP1
    call    Delay10us
    bcf	    GPIO,1
    
    movlw   2
    ; Wait for echo
    btfss   GPIO, 2
    goto $-1		    ; back to previous instruction  if GP2 is not high
    clrf    TMR0 
    btfsc   GPIO, 2
    goto $-1		    ; back to previous instruction  if GP2 is high
    
    subwf   TMR0, w
    btfss   STATUS, 0	    ; If grater than 1
    goto    VeryClose 
    bcf	    GPIO,0	    ; Turn the LED off
    goto    MainLoopEnd
VeryClose:   
    bsf	    GPIO,0	    ; Turn the LED on    
MainLoopEnd:
    call    Delay2ms;
    
    goto    MainLoop
     
; ******************
; Delay function

; At 4 MHz, one instruction takes 1?s
; So, this soubroutine should take about 10?s 
; This time is used by the HC-S04 ultrasonic sensor 
; to determine the distance. 	
Delay10us:
    nop		;  2 cycles (CALL) + 6 cycles (NOP)
    nop
    nop
    nop
    nop
    nop	    
    retlw 0	; + 2 cycles (retlw) => 10 cycles =~ 10us at 4MHz frequency clock    

; It takes about 2ms
Delay2ms: 
    movlw  200
    movwf  dummy1
LoopDelay2ms: 
    call Delay10us    
    decfsz dummy1, f
    goto LoopDelay2ms
    retlw   0
    
END MAIN



