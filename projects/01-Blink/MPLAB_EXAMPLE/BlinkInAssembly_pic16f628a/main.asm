
; PIC16F628A Configuration Bit Settings
; Assembly source line config statements
;    
; Author: Ricardo Lima Caratti - Jan/2024
;    
#include <xc.inc>
    
; CONFIG
  CONFIG  FOSC = INTOSCIO       ; Oscillator Selection bits (INTOSC oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer disable bit 
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RA5/MCLR/VPP Pin Function Select bit (RA5/MCLR/VPP pin function is MCLR)
  CONFIG  BOREN = ON            ; Brown-out Detect Enable bit (BOD enabled)
  CONFIG  LVP = OFF             ; Low-Voltage Programming disble
  CONFIG  CPD = OFF             ; Data EE Memory Code Protection bit (Data memory code protection off)
  CONFIG  CP = OFF              ; Flash Program Memory Code Protection bit (Code protection off)

// config statements should precede project file includes.

counter1 equ 0x20
counter2 equ 0x21
  
PSECT resetVector, class=CODE, delta=2
resetVect:
    PAGESEL main
    goto main
PSECT code, delta=2
main:
    bsf STATUS, 5	; Select the Bank 1 - See PIC16F627A/628A/648A Data Sheet, page 20 and 21 (MEMORY ORGANIZATION)
    clrf PORTB		; Initialize PORTB by setting output data latches
    clrf TRISB
    bcf STATUS, 5	; Return to Bank 0
    CLRW		; Clear W register
    movwf PORTB		; Turn all pins of the PORTB low    
loop:			    ; Loop without a stopping condition - here is your application code
    bsf PORTB, 3        ; Sets RB3 to high (turn the LED on)
    call DelayTwo
    bcf PORTB, 3        ; Sets RB3 to low (turn the LED off) 
    call DelayTwo
    goto loop


;
; Delay functions
;  
    
;  It should take about 0.00255 second.
;  One instruction cycle consists of four oscillator periods. 
;  For a oscillator of 4MHz a regular instructions takes 1us (See pic16f628a Datasheet, page 117). 
;  time = 10 cyclos * 255 * 0.000001 (1us per cyclo at 4MHz clock frequency)
;  time = 0.00255 second   
DelayOne:
    movlw   255		 
    movwf   counter1
DelayOneLoop:       ; Runs 10 cycles 255 times - You can try to improve precision by adding or removing nop instructions
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    decfsz counter1, f	; It takes two cucles - Decrements counter1. If the result is zero, then the next instruction is skipped (breaking out of the loop)
    goto DelayOneLoop	; It takes two cycles - If counter1 is not zero, then go to DelayOneLoop. 
    return

; Runs DelayOne 255 times.  It takes about 0,65 second (255 * 0.00255) 
; The actual duration of the loop depends on the DelayOne subroutine and the clock speed of the PIC microcontroller. 
; 
DelayTwo:
    movlw 255
    movwf counter2
 DelayTowLoop:
    call DelayOne
    decfsz counter2, f	; Decrements counter2. If the result is zero, then the next instruction is skipped (breaking out of the loop)
    goto DelayTowLoop	; If counter2 is not zero, then go to DelayOneLoop. 
    return
    
END resetVect
    

