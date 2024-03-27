; UNDER CONSTRUCTION...
; Assembly source 
; Author: Ricardo Lima Caratti - Jan/2024

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

ind_I		equ 0x20
ind_J		equ 0x21
delayParam	equ 0x22 
  

PSECT resetVec, class=CODE, delta=2 
ORG 0x0000	    
resetVec:
    PAGESEL main
    goto main
;
; INTERRUPT IMPLEMENTATION 
; THIS FUNCTION WILL BE CALLED EVERY TMR0 Overflow
; pic-as Additiontal Options: -Wl,-PresetVec=0x0,-PisrVec=0x04    
PSECT isrVec, class=CODE, delta=2
ORG 0x0004     
isrVec:  
    PAGESEL interrupt
    goto interrupt
  
interrupt: 
   
    bcf	    STATUS, 5
    
    bcf	    INTCON, 7	; Disables GIE
    
    ; check if the interrupt was trigged by Timer0	
    btfss   INTCON, 1		; INTCON - INTF: RB0/INT External Interrupt Flag bit
    goto    INT_FINISH
    btfss   PORTB, 3		; Toggle LED (ON/OFF)
    goto    INT_SWITCH_ON
    goto    INT_SWITCH_OFF
INT_SWITCH_ON:    
    bsf	    PORTB, 3
    goto    INT_CONTINUE
INT_SWITCH_OFF:    
    bcf	    PORTB, 3
INT_CONTINUE:    
    movlw   1
    call    Delay
    bcf	    INTCON, 1  
INT_FINISH:
    bsf	    INTCON, 7		; Enables GIE
    
    retfie   
    
main:

    ; Bank 1
    bsf	    STATUS, 5	    ; Selects Bank 1  
    movlw   0B00000001	    ; RB1 as input and RB3 as output
    movwf   TRISB 	    ; Sets all GPIO as output    

    movlw   0B01000000	    ; INTEDG: Interrupt Edge Select bit
    movwf   OPTION_REG	      

    ; Bank 0
    bcf	    STATUS, 5 
    
    clrf    PORTB	    ; Turn all GPIO pins low
    
    ; ---- if you are using debounce capacitor ---
    movlw   1		; Wait for the debounce capacitor becomes stable 
    call    Delay
    ; ----  
    
    ; INTCON setup
    ; bit 7 (GIE) = 1 => Enables all unmasked interrupts
    ; bit 4 (INTE) =  1 => RB0/INT External Interrupt Flag bit
    movlw   0B10010000
    movwf   INTCON
    
    ; Debug - Blink LED indicating that the system is alive
    ; bsf   PORTB, 3
    ; movlw 6
    ; call  Delay
    ; bcf   PORTB, 3    
    
    
loop:			; Loop without a stopping condition - here is your application code
    sleep
    goto loop


; ******************
; Delay function
;
; For an oscillator of 4MHz a regular instructions takes 1us (See pic16f628a Datasheet, page 117).      
; So, at 4MHz, this Delay subroutine takes about: (5 cycles) * 255 * 255 * 3 * 0.000001 (second)  
; It is about 1s (0.975 s)    
Delay:  
    movwf   delayParam    
    movlw   100
    movwf   ind_I
    movwf   ind_J
DelayLoop:    
    nop
    nop
    decfsz  ind_I, f		
    goto    DelayLoop
    decfsz  ind_J, f	
    goto    DelayLoop
    decfsz  delayParam, f		 
    goto    DelayLoop
    return 
    
END resetVec
    