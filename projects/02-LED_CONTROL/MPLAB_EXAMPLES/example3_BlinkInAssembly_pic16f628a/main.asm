
; PIC16F628A Configuration Bit Settings
; Assembly source line config statements
;    
; Author: Ricardo Lima Caratti - Jan/2024
;    
#include <xc.inc>
    
; CONFIG
  CONFIG  FOSC = INTOSCIO       ; Oscillator Selection bits (INTOSC oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = ON             ; Watchdog Timer Enable bit (WDT enabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RA5/MCLR/VPP Pin Function Select bit (RA5/MCLR/VPP pin function is MCLR)
  CONFIG  BOREN = ON            ; Brown-out Detect Enable bit (BOD enabled)
  CONFIG  LVP = ON              ; Low-Voltage Programming Enable bit (RB4/PGM pin has PGM function, low-voltage programming enabled)
  CONFIG  CPD = OFF             ; Data EE Memory Code Protection bit (Data memory code protection off)
  CONFIG  CP = OFF              ; Flash Program Memory Code Protection bit (Code protection off)

// config statements should precede project file includes.

counter1 equ 0x20
counter2 equ 0x21
counter3 equ 0x22 
led      equ 0x23 
idx      equ 0x24      
  
PSECT resetVector, class=CODE, delta=2
resetVect:
    PAGESEL main
    goto main
PSECT code, delta=2
main:
    bsf STATUS, 5	; Select the Bank 1 - See PIC16F627A/628A/648A Data Sheet, page 20 and 21 (MEMORY ORGANIZATION)
    clrf PORTB		; Initialize PORTB by setting output data latches
    bcf STATUS, 5	; Return to Bank 0
    movlw 1
    movwf led 
loop:			; Loop without a stopping condition - here is your application code
    call LedOn		; turn the first LED on
    call DelayOneSecond
    goto loop
    
LedOn:
    rlf   led,f
    goto  TurnLedOn
    movlw 1
TurnLedOn: 
    movlw led
    movwf  PORTB
    return
    
;
; Delay function
;    
DelayOneSecond:
    movlw   255		 
    movwf   counter1     
Loop1:    
    call  DelayLoop1
    decfsz counter1, f
    goto Loop1
    return
  
DelayLoop1:
    movlw 255
    movwf counter2
 Loop2:   
    call  DelayLoop2
    decfsz counter2, f
    goto Loop2  
    return

DelayLoop2:
    movlw 2
    movwf counter3
 Loop3:   
    ; nop			; consumes an extra cycle
    ; nop			; consumes an extra cycle    
    decfsz counter3, f
    goto Loop3
    return
     
END resetVect
    

