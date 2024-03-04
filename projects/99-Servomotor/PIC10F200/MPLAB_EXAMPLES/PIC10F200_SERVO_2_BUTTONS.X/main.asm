; UNDER CONSTRUCTION...
;    
; IMPORTANT: If you are using the PIC10F200, to assemble this code correctly, please follow the steps below:
; 1. Go to "Project Properties" in MPLAB X.
; 2. Select "Global Options" for the pic-as assembler/compiler.
; 3. In the "Additional Options" box, enter the following parameters:
; -Wl,-pYourCode=0h
    
#include <xc.inc>

    
; CONFIG
  CONFIG  WDTE = OFF           ; Watchdog Timer (WDT disabled)
  CONFIG  CP = OFF             ; Code Protect (Code protection off)
  CONFIG  MCLRE = ON	       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)


; Declare your variables here

servo_pulses	equ	0x10
counter1	equ	0x11
counter2	equ	0x12
	
 
PSECT YourCode, class=CODE, delta=2

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

    movlw   3
    call    RotateServo
    call    Delay600ms
    call    Delay600ms
    movlw   60
    call    RotateServo
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
    movlw   3		
    call    DelayNx10us	    ; it takes about 30us
    bcf	    GPIO, 2
    movlw   7
    call    DelayNx10us	    ; It takes about 70us
    decfsz  servo_pulses
    goto    RotateServoLoop
    retlw   0

; Delay us
; Takes (WREG * 10)us    
; Examples: if WREG=1 => 10us; WREG=7 => 70us; WREG=48 => 480us; and so on      
 DelayNx10us:
    movwf  counter1
    goto $ + 1		; 2 cycles +
    goto $ + 1		; 2 cycles +
    goto $ + 1		; 2 cycles +
    goto $ + 1		; 2 cycles = 8 cycles +
    decfsz counter1, f	; 1 cycle + 
    goto $ - 5		; 2 cycle = 11 cycles **** Fix it later
    retlw   0    
    
; ***********************    
; It takes about 600ms 
Delay600ms:
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



