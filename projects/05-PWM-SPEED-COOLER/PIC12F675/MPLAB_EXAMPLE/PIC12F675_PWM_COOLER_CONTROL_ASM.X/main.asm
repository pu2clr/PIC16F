; UNDER CONSTRUCTION... 
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

dummy1	    equ 0x20 
dummy2	    equ 0x21 
delayParam  equ 0x22 
adcValueL   equ 0x23
adcValueH   equ 0x24
pwm	    equ	0x25   
    
PSECT resetVector, class=CODE, delta=2 
resetVect:
    PAGESEL main
    goto main
    
PSECT code, delta=2
main:

    ; Under construction... 
    
    bcf	    STATUS,5	; Selects Bank 0
    ; BANKSEL(0)
    
    clrf    GPIO	; Init GPIO  
    movlw   0x07	;   
    movwf   CMCON	; digital IO  
    
    ; BANKSEL(1)
    bsf	    STATUS,5	; Selects Bank 1  
    clrf    ANSEL	; Digital IO  
    clrw
    movwf   TRISIO	; Sets all GPIO as output
    ; BANKSEL(0)
    bcf	    STATUS,5 
    clrf    GPIO	; Turn all GPIO pins low
    nop
    nop
MainLoopBegin:		; Endless loop

    bsf	    GPIO, 5
      
    movlw   50
    call    Delay
   
    bcf	    GPIO, 5 
 
    movlw   50
    call    Delay 
    
    
MainLoopEnd:     

    
    goto MainLoopBegin
     

; ******************
; Delay function
; Deleys about  WREG * 255 us

Delay:  
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
    
    
END resetVect





