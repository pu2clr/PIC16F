; Multiply    
; My PIC Journey   
; Adaptation: Ricardo Lima Caratti
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
resultL	    equ 0x20
resultH	    equ 0x21  
count	    equ 0x22	    
    
PSECT resetVector, class=CODE, delta=2
resetVect:
    PAGESEL main
    goto main
PSECT code, delta=2
main:
    ; pic12f675 setup example 
    bsf	    STATUS,5	; Selects Bank 1  
    clrf    ANSEL	; Digital IO  
    clrw
    movwf   TRISIO	; Sets all GPIO as output   
    bcf	    STATUS,5	; Selects Bank 0
    clrf    GPIO	; Init GPIO  
   
MainLoopBegin:		; Endless loop
   
    clrf  resultL
    movlw 20
    movwf resultL
    movlw 3
    call Multiply8X8
    nop
    goto MainLoopBegin
     

Multiply8X8:
    clrf count
    clrf resultL
    clrf resultH
Multiply8X8Loop:
    addwf resultL,f


    goto Multiply8X8Loop    
    
END resetVect






