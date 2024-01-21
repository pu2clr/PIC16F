; UNDER CONSTRUCTION... 
; Divider Example
;    
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
temp	equ 0x20
;	    0x21 reserved for temp	
count	equ 0x22
divider equ 0x23
paramL  equ 0x24
paramH  equ 0x25  
    
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
    
    movlw 0b00000000
    movwf paramL
    movlw 0b00000010
    movwf paramH	; param value = 512
    movlw 10
    movwf divider
    call  Divide
    nop			; Breakpoint - Check the temp value here
    goto MainLoopBegin
     

; *****************
; 8-bit operation    
; Divide paramL divider   
; 
; return temp  (0x20)
Divide8:    
    
    return;    

; *****************
; 16-bit operation    
; Divide a 16 bits value (paramL and paramH) by divider   
; 
; return temp (temp and temp+1 / 0x20 and 0x21)      
Divider16:
    
    return 

    
END resetVect



