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
  CONFIG  MCLRE = OFF	       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)

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
    movlw  0B0001011	    ; GP0, GP1 and GP3 are input and GP2 is output 
    tris   GPIO
    nop
MainLoop:		    ; Endless loop
    ; Check Buttons
    btfss   GPIO, 3	    ; Check if GP3 is 0
    goto    CheckButton2   
    ; Move Servo
    movlw   2		    ; Patameter Duration   
    movwf   servo_duration  
    movlw   22		    ; Parameter Pulses
    call    RotateServo
    goto    MainLoopContinue
CheckButton2: 
    btfss   GPIO, 1	    ; Check if GP1 is 0
    goto    CheckButton1   
    ; Move Servo
    movlw   3		    ; Patameter Duration   
    movwf   servo_duration  
    movlw   22		    ; Parameter Pulses
    call    RotateServo  
    goto    MainLoopContinue
CheckButton1:  
    btfss   GPIO, 0	    ; Check if GP0 is 0
    goto    MainLoop	    ; No button was pressed - keep monitoring	       
    ; Move Servo
    movlw   4		    ; Parameter Duration
    movwf   servo_duration  
    movlw   22		    ; Parameter Pulses
    call    RotateServo
MainLoopContinue: 
   
    movlw   10
    call    DelayMS	    ; Try mitigate debounce via delay
     
    goto    MainLoop
    
    
; *********** Rotate the servo *********
; Parameter - WREG: number of pulses    
RotateServo: 
   movwf    servo_pulses
RotateServoLoop:
    bsf	    GPIO, 2		
    movf    servo_duration, w		
    call    DelayMS	    ; 
    bcf	    GPIO, 2
    movlw   25
    call    DelayMS	    ;    
    decfsz  servo_pulses
    goto    RotateServoLoop
    
    retlw   0

; Delay pulse - ms
; Paremeter: WREG     
DelayMS:                     
    movwf   counter1  
DelayMSLoop1:    
    movlw   200  
    movwf   counter2                
DelayMSLoop2: 
    decfsz  counter2, F         
    goto    DelayMSLoop2        
    decfsz  counter1, F         
    goto    DelayMSLoop1        
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



