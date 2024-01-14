
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

; Variables 
dummy1   equ 0x20
dummy2	 equ 0x21
dummy3   equ 0x22 
led      equ 0x23    
  
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
    call    Delay
    nop			; Must be removed - Just for debugging purpose 
    goto loop

; ******************
; Delay function
;
; For a oscillator of 4MHz a regular instructions takes 1us (See pic16f628a Datasheet, page 117).      
; So, at 4MHz, this Delay subroutine takes about: (5 cycles) * 255 * 255 * 3 * 0.000001 (second)  
; It is about 1s (0.975 s)  - One second  
Delay:  
    movlw   255
    movwf   dummy1		; 255
    movwf   dummy2		; 255 times
    movlw   3			
    movwf   dummy3		; 3 times
DelayLoop:    
    nop				; One cycle
    nop				; One cycle
    decfsz dummy1, f		; One cycle* (dummy1 = dumm1 - 1) => if dummy1 is 0, after decfsz, it will be 255
    goto DelayLoop		; Two cycles
    decfsz dummy2, f		; dummy2 = dumm2 - 1; if dummy2 = 0, after decfsz, it will be 255
    goto DelayLoop
    decfsz dummy3, f		; Runs 3 times (255 * 255)		 
    goto DelayLoop
    return 
    
    
END resetVect
    

