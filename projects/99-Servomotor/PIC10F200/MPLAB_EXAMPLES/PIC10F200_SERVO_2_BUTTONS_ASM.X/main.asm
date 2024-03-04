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
    
MainLoop:		    ; Endless loop

    ; Move Servo
    movlw   6		    ; duration (1 * 2ms)
    movwf   servo_duration  ; duration parameter 
    movlw   20		    ; pulses parameter
    call    RotateServo
    
    movlw   255		     
    call    DelayNx2ms	    ; it takes about  500ms (255 * 200 * 10us)
    movlw   255	
    call    DelayNx2ms	    ; it takes about  500ms (255 * 200 * 10us)
    
    ; Move Servo
    movlw   3		    ; duration ( 12 * 2ms = 24ms)
    movwf   servo_duration  ; duration parameter
    movlw   20		    ; pulses parameter
    call    RotateServo
    
   
    movlw   255		     
    call    DelayNx2ms	    ; it takes about  500ms (255 * 200 * 10us)
    movlw   255	
    call    DelayNx2ms	    ; it takes about  500ms (255 * 200 * 10us)
    movlw   255		     
    call    DelayNx2ms	    ; it takes about  500ms (255 * 200 * 10us)
    movlw   255	
    call    DelayNx2ms	    ; it takes about  500ms (255 * 200 * 10us)    
    
    goto    MainLoop
    
    
; *********** Rotate the servo *********
; Parameter - WREG: number of pulses    
RotateServo: 
   movwf    servo_pulses
RotateServoLoop:
    bsf	    GPIO, 2		
    movf    servo_duration, w		
    call    DelayNx2ms	    ; it takes about 2ms (1 x 2ms)
    bcf	    GPIO, 2
    movlw   8
    call    DelayNx2ms	    ; it takes about 18ms (9 x 2ms)    
    decfsz  servo_pulses
    goto    RotateServoLoop
    retlw   0

    
; ***********************    
; It takes about wreg * 2ms
; Parameter: wreg   
DelayNx2ms:    
    movwf   counter1
DelayNx2ms01:
    movlw   200
    movwf   counter2
DelayNx2ms02: 
    goto $+1
    goto $+1
    goto $+1
    goto $+1
    decfsz  counter2, f
    goto    DelayNx2ms02
    decfsz  counter1, f
    goto    DelayNx2ms01
    
    retlw   0    
       
    
END MAIN



