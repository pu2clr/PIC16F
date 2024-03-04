; UNDER CONSTRUCTION...
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
  CONFIG  MCLRE = ON	       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)


; Declare your variables here

servo_pulses	equ	0x10
servo_duration	equ	0x11	
counter1	equ	0x12
counter2	equ	0x13
	
 
PSECT AsmCode, class=CODE, delta=2

MAIN:
    ; OPTION register setup 
    ; Prescaler Rate: 256
    ; Prescaler assigned to the WDT
    ; Increment on high-to-low transition on the T0CKI pin
    ; Transition on internal instruction cycle clock, FOSC/4
    ; GPPU disbled 
    ; GPWU disabled
    movlw   0B10011111	    ; 
    OPTION
    ; GPIO and registers setup
    clrf   GPIO		    ; Sets all GPIO pins as output
    movlw  0B00000011	    ; GP0 and GP1 are input and GP2 is output 
    TRIS   GPIO
    nop
MainLoop:		    ; Endless loop

    ; Move Servo
    movlw   6		    ; duration (1 * 2ms)
    movwf   servo_duration  ; duration parameter 
    call    RotateServo
    
    call    Delay600ms
    call    Delay600ms
    call    Delay600ms
    call    Delay600ms
    
    ; Move Servo
    movlw   12		    ; duration ( 12 * 2ms = 24ms)
    movwf   servo_duration  ; duration parameter
    call    RotateServo
    
    call    Delay600ms
    call    Delay600ms
    call    Delay600ms
    call    Delay600ms   
   
    
    goto    MainLoop
    
    
; *********** Rotate the servo *********
; Parameter - WREG: number of pulses    
RotateServo: 
   movlw    20 
   movwf    servo_pulses
RotateServoLoop:
    bsf	    GPIO, 2		
    movf    servo_duration, w		
    call    DelayNx1ms	    ; servo_duration x 1ms
    bcf	    GPIO, 2
    movlw   20
    call    DelayNx1ms	    ; it takes about 20ms (20 x 1ms)    
    decfsz  servo_pulses
    goto    RotateServoLoop
    
    retlw   0

    
; ***********************    
; It takes about wreg * 1ms
; Parameter: wreg   
DelayNx1ms:    
    movwf   counter1
DelayNx1ms01:
    movlw   100
    movwf   counter2
DelayNx1ms02:		    ; this loop takes about 100us
    goto $+1		    ; 2us
    goto $+1		    ; 2us
    goto $+1		    ; 2us		
    nop			    ; 1us
    decfsz  counter2, f	    ; 1us (last 2us) 
    goto    DelayNx1ms02    ; 2us
    decfsz  counter1, f
    goto    DelayNx1ms01
    
    retlw   0    
       
 
; ***********************    
; It takes about 650ms 
; 255 x 255 x 10us   
Delay600ms:  
    movlw   255
    movwf   counter1
Delay600ms01:
    movlw   255
    movwf   counter2
Delay600ms02:		    ; 255 x 10us = 2.550us = 2,55ms
    goto $+1		    ; 2us
    goto $+1		    ; 2us
    goto $+1		    ; 2us		
    nop			    ; 1us
    decfsz  counter2, f	    ; 1us (last 2us) 
    goto    Delay600ms02    ; 2us
    decfsz  counter1, f
    goto    Delay600ms01
    
    retlw   0      
    
END MAIN



