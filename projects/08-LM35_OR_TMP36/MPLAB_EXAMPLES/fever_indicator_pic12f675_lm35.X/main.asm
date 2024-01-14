; Fever Indicator with PIC12F675 with LM35 or TMP36
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
temp	equ 0x20       ; General Purpose Registers(check the memory organization of your PIC device datasheet)
temp1	equ 0x21
dummy1	equ 0x22 
dummy2	equ 0x23 
dummy3	equ 0x24 	
    
PSECT resetVector, class=CODE, delta=2
resetVect:
    PAGESEL main
    goto main
PSECT code, delta=2
main:
    ; Analog and Digital pins setup
    
    ;bcf	    STATUS, 5	    ; Selects Bank 0
    ;clrf    GPIO	    ; Init GPIO	
    ;bcf	    CMCON, 0	    ; Sets GP0 as output 
    ;bsf	    STATUS, 5	    ; Selects Bank 1
    
    ;bsf	    TRISIO, 1	    ; Sets GP1 as input 
    ;bsf	    ANSEL, 1	    ; Sets GP1 as analog
    ;movlw   0x01	    ;
    ;movwf   ADCON0 	    ; Enable ADC
   
    ; TO BE CONTINUE....

    ;

loop:			    ; Endless loop
    ;
    ; The temperature reading  process
    ;
    ; call AdcRead	    ; read the temperature value
    
    ; Assuming the constant is 500 (0x01F4)
    movlw   LOW(37)	    ; Lower part of the constant
    subwf   temp, W	    ; Subtract from lower part of the result
    movlw   HIGH(37)	    ; Higher part of the constant
    subwf   temp+1, W	    ; Subtract from higher part of the result with borrow
    ; Delay parameters
    call Delay
    
    goto loop
     
    ;
    ; Your subroutines
    ;  

;
; Read the analog value from GP1
AdcRead: 
    
    bsf	    ADCON0, 1		; Start convertion  (set bit 1 to high)

WaitConvertionFinish:		; do while the bit 1 of ADCON0 is 1 
    btfsc  ADCON0, 1		; Bit Test, Skip if Clear - If bit 1 in ADCON0 is '1', the next instruction is executed.
    goto   WaitConvertionFinish
    movlw  ADRESL
    movwf  temp
    movlw  ADRESH
    movwf  temp+1
    return			; ADRESH << 8 + ADRESL is the combined result of reading   
    

; At 4MHz it takes: (5) * 255 * 255 * 3 * 0.000001.
; It is about 1s (0.975) s    
Delay:  
    movlw   255
    movwf   dummy1
    movwf   dummy2
    movlw   3
    movwf   dummy3
DelayLoop:    
    nop
    nop
    decfsz dummy1, f		; dummy1 = dumm1 - 1; if dummy1 = 0 then dummy1 = 255
    goto DelayLoop
    decfsz dummy2, f		; dummy2 = dumm2 - 1; if dummy2 = 0 then dummy2 = 255
    goto DelayLoop
    decfsz dummy3, f		 
    goto DelayLoop
    return 
    
END resetVect


