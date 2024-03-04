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
    movlw   2		    
    movwf   servo_duration  
    call    MANIPULATE_SERVO
    
    call    Delay600ms
    call    Delay600ms
    call    Delay600ms
    call    Delay600ms
    
    ; Move Servo
    movlw   3		    
    movwf   servo_duration  
    call    MANIPULATE_SERVO
    
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

    
; **********
    
MANIPULATE_SERVO:          ;Manipulate servo subroutine
    MOVLW 20               ;Copy 20 to the servo_steps register
    MOVWF servo_pulses      ;to repeat the servo move condition 20 times
SERVO_MOVE:                ;Here servo move condition starts
    BSF GPIO, 2  ;Set the GP2 pin to apply voltage to the servo
    MOVF servo_duration, W     ;Load initial value for the delay
    CALL DELAY             ;(2 to open the lock, 3 to close it)
    BCF GPIO, 2  ;Reset GP2 pin to remove voltage from the servo
    MOVLW 25               ;Load initial value for the delay
    CALL DELAY             ;(normal delay of about 20 ms)
    DECFSZ servo_pulses, F  ;Decrease the servo steps counter, check if it is 0
    GOTO SERVO_MOVE        ;If not, keep moving servo
    RETLW 0       

    
DELAY:                     ;Start DELAY subroutine here    
    MOVWF counter1                ;Copy the W value to the register i
    MOVWF counter2                ;Copy the W value to the register j
DELAY_LOOP:                ;Start delay loop
    DECFSZ counter1, F            ;Decrement i and check if it is not zero
    GOTO DELAY_LOOP        ;If not, then go to the DELAY_LOOP label
    DECFSZ counter2, F            ;Decrement j and check if it is not zero
    GOTO DELAY_LOOP        ;If not, then go to the DELAY_LOOP label
    RETLW 0        
    
END MAIN



