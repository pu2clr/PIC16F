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
    
    bcf	    STATUS, 5	    ; Selects Bank 0
    clrf    GPIO	    ; Init GPIO	
    bcf	    CMCON, 0	    ; Sets GP0 as output 
    bsf	    STATUS, 5	    ; Selects Bank 1
    
    bsf	    TRISIO, 1	    ; Sets GP1 as input 
    bsf	    ANSEL, 1	    ; Sets GP1 as analog
    movlw   0x01	    ;
    movwf   ADCON0 	    ; Enable ADC

MainLoopBegin:		    ; Endless loop
    call AdcRead	    ; read the temperature value
    ; Considering temperatures of 37 degrees Celsius or higher as fever.
    movlw 37
    subwf temp,w
    btfsc STATUS, 2	    ; Z (Zero Bit)
    goto  AlmostFever 
    btfsc STATUS, 2	    ; Z (Zero Bit) 
    goto  Fever
    
    
AlmostFever:		    ; Temperature is 37
    ; Turn the Yellow LED ON
    
    goto MainLoopEnd
    
Fever:			    ; Temperature is greater than 37
    ; Turn the Red LED ON
    goto MainLoopEnd

Normal: 
    ; Turn the Gree LED ON
    
MainLoopEnd:     
    
    ; Delay parameters
    call Delay
    
    goto MainLoopBegin
     
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
    
    ; Not finished: Need to divide the value by 10
    
    return

    

; ******************
; Delay function
;
; For an oscillator of 4MHz a regular instructions takes 1us (See pic16f628a Datasheet, page 117).      
; So, at 4MHz, this Delay subroutine takes about: (5 cycles) * 255 * 255 * 3 * 0.000001 (second)  
; It is about 1s (0.975 s)  - One second  
Delay:  
    movlw   255
    movwf   dummy1      ; 255 times
    movwf   dummy2      ; 255 times (255 * 255)
    movlw   3			
    movwf   dummy3      ; 3 times  ( 255 * 255 * 3) 
DelayLoop:    
    nop                 ; One cycle
    nop                 ; One cycle
    decfsz dummy1, f    ; One cycle* (dummy1 = dumm1 - 1) => if dummy1 is 0, after decfsz, it will be 255
    goto DelayLoop      ; Two cycles
    decfsz dummy2, f    ; dummy2 = dumm2 - 1; if dummy2 = 0, after decfsz, it will be 255
    goto DelayLoop
    decfsz dummy3, f    ; Runs 3 times (255 * 255)		 
    goto DelayLoop
    
    return 
    
END resetVect


