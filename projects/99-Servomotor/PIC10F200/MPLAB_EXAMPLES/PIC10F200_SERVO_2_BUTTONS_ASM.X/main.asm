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
    movlw   0B10011111	    	 
    OPTION
    ; GPIO and registers setup
    clrf   GPIO		    ; Sets all GPIO pins as output
    movlw  0B00000011	    ; GP0 and GP1 are input and GP2 is output 
    tris   GPIO
    nop
MainLoop:		    ; Endless loop
    ; Check Buttons
    btfsc   GPIO, 3	    ; Check if GP3 is 0
    goto    CheckButton2   
    ; Move Servo
    movlw   2		    ; Patameter Duration   
    movwf   servo_duration  
    movlw   22		    ; Parameter Pulses
    call    RotateServo
    goto    MainLoopContinue
CheckButton2: 
    btfsc   GPIO, 1	    ; Check if GP1 is 0
    goto    CheckButton1   
    ; Move Servo
    movlw   3		    ; Patameter Duration   
    movwf   servo_duration  
    movlw   22		    ; Parameter Pulses
    call    RotateServo  
    goto    MainLoopContinue
CheckButton1:  
    btfsc   GPIO, 0	    ; Check if GP0 is 0
    goto    MainLoop	    ; No button was pressed - keep monitoring	       
    ; Move Servo
    movlw   1		    ; Parameter Duration
    movwf   servo_duration  
    movlw   22		    ; Parameter Pulses
    call    RotateServo
MainLoopContinue: 
   
    call    Delay600ms
    call    Delay600ms
    call    Delay600ms
    call    Delay600ms   
     
    goto    MainLoop
    
    
; *********** Rotate the servo *********
; Parameter - WREG: number of pulses    
RotateServo: 
   movwf    servo_pulses
RotateServoLoop:
    bsf	    GPIO, 2		
    movf    servo_duration, w		
    call    DelayPulse	    ; 
    bcf	    GPIO, 2
    movlw   25
    call    DelayPulse	    ;    
    decfsz  servo_pulses
    goto    RotateServoLoop
    
    retlw   0

; Delay pulse - ms
; Paremeter: WREG     
DelayPulse:                     
    movwf   counter1  
DelayPulseLoop1:    
    movlw   200  
    movwf   counter2                
DelayPulseLoop2: 
    decfsz  counter2, F         
    goto    DelayPulseLoop2        
    decfsz  counter1, F         
    goto    DelayPulseLoop1        
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



