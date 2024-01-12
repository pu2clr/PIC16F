
; PIC16F628A Configuration Bit Settings
; Assembly source line config statements
;    
; Author: Ricardo Lima Caratti - Jan/2024
;    
#include <xc.inc>
    
; CONFIG
  CONFIG  FOSC = INTOSCIO       ; Oscillator Selection bits (INTOSC oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer disable bit (WDT enabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RA5/MCLR/VPP Pin Function Select bit (RA5/MCLR/VPP pin function is MCLR)
  CONFIG  BOREN = ON            ; Brown-out Detect Enable bit (BOD enabled)
  CONFIG  LVP = OFF             ; Low-Voltage Programming disable bit (This application needs the RB4)

// config statements should precede project file includes.

counter1 equ 0x20
counter2 equ 0x21
led      equ 0x22    
  
PSECT resetVector, class=CODE, delta=2, split=1, group=0
resetVect:
    PAGESEL main
    goto main
PSECT code, delta=2
main:
    bsf	    STATUS, 5	; Select the Bank 1 - See PIC16F627A/628A/648A Data Sheet, page 20 and 21 (MEMORY ORGANIZATION)
    clrf    PORTB	; Initialize PORTB 
    clrf    TRISB	; 
    bcf	    STATUS, 5	; Return to Bank 0
    movlw   0
    movwf   led
    movwf   PORTB     
loop:			; endelss loop
    rlf     led, w	; Rotate Left f through Carry
    movwf   led
    movwf   PORTB 
    call    DelayTwo
    nop
    goto loop
    
;
; Delay functions
;  
    
;  It takes about 0.0005105 seconds at 4MHz clock speed    
DelayOne:
    movlw   255		 
    movwf   counter1
DelayOneLoop:       ; Runs 8 instructions 255 times 
    nop
    nop
    nop
    nop
    nop
    nop
    decfsz counter1, f	; Decrements counter1. If the result is zero, then the next instruction is skipped (breaking out of the loop)
    goto DelayOneLoop	; If counter1 is not zero, then go to DelayOneLoop. 
    return

; Runs DelayOne 255 times.  It takes about 1 second (I guess).
; The actual duration of the loop depends on the DelayOne subroutine and the clock speed of the PIC microcontroller. 
; At 4MHz clock it is about 5,000,000 cycles  (a bit more than 1s)  
DelayTwo:
    movlw 255
    movwf counter2
 DelayTowLoop:
    call DelayOne
    decfsz counter2, f	; Decrements counter2. If the result is zero, then the next instruction is skipped (breaking out of the loop)
    goto DelayTowLoop	; If counter2 is not zero, then go to DelayOneLoop. 
    return
     
END resetVect
    

