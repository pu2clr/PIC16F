; BLINK three LEDS in sequency with PIC12F675
; My PIC Journey   
; Author: Ricardo Lima Caratti
; Jan/2024
    
#include <xc.inc>

; CONFIG
  CONFIG  FOSC = INTRCIO        ; Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-Up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; GP3/MCLR pin function select (GP3/MCLR pin function is MCLR)
  CONFIG  BOREN = ON            ; Brown-out Detect Enable bit (BOD enabled)
  CONFIG  CP = OFF              ; Code Protection bit (Program Memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled) 
  
; declare your variables here
dummy1	    equ 0x22 
dummy2	    equ 0x23 
delayParam  equ 0x24 
ledNumber   equ 0x25  
    
PSECT resetVec, class=CODE, delta=2
resetVec:
    PAGESEL main
    goto main
PSECT code, delta=2
main:
    ; INITIALIZING GPIO - See page 19 of the PIC12F675 Data Sheet
    bcf STATUS,5	        ; Selects Bank 0
    clrf GPIO		        ; Init GPIO  
    clrf CMCON		        ; COMPARATOR Register setup
    bsf STATUS,5	        ; Selects Bank 1  
    clrf ANSEL		        ; Digital IO  
    clrw
    movwf   TRISIO	        ; Sets all GPIO as output   
    bcf	    STATUS,5	    ; Selects the Bank 0		
    clrf    ledNumber	    ; ledNumber = 0
MainLoopBegin:		        ; Endless loop
    movf    ledNumber,w	    ; All LEDs off at first time
    movwf   GPIO	    
    call    Delay
    bsf	    STATUS, 0	    ; Sets 1 to carry flag	
    rlf	    ledNumber	    ; Sets ledNumber to turn the next LED on    
    btfss   ledNumber,3	    ; Check if the end of LED cycle 
    goto    MainLoopBegin
    ; Restart the LED sequency
    clrf ledNumber	        ;  
    bsf  ledNumber,0	    ; ledNumber = 1 (first LED again) 
    goto MainLoopBegin
     
; ******************
; Delay function
;
; For an oscillator of 4MHz a regular instructions takes 1us (See pic16f628a Datasheet, page 117).      
; So, at 4MHz, this Delay subroutine takes about: (5 cycles) * 255 * 255 * delayParam * 0.000001 (second)  
; It is about 1s (0.975 s)  - One second  if delayParam is 3
Delay:  
    movlw   3
    movwf   delayParam
    movlw   255
    movwf   dummy1      ; 255 times
    movwf   dummy2      ; 255 times (255 * 255)
			; 255 * 255 * delayParam loaded before calling Delay    
DelayLoop:    
    nop                 ; One cycle
    nop                 ; One cycle
    decfsz dummy1, f    ; One cycle* (dummy1 = dumm1 - 1) => if dummy1 is 0, after decfsz, it will be 255
    goto DelayLoop      ; Two cycles
    decfsz dummy2, f    ; dummy2 = dumm2 - 1; if dummy2 = 0, after decfsz, it will be 255
    goto DelayLoop
    decfsz delayParam,f ; Runs 3 times (255 * 255)		 
    goto DelayLoop
    
    return 
    
END resetVec
