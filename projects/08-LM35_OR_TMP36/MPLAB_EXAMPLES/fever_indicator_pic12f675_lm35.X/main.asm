; UNDER CONSTRUCTION...
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
paramL	    equ 0x20       ; 
paramH	    equ 0x21
dummy1	    equ 0x22 
dummy2	    equ 0x23 
delayParam  equ 0x24 
count	    equ 0x25
temp	    equ 0x26
divider	    equ 0x27
    
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
    
    clrf    TRISIO	    
    bsf	    TRISIO, 1	    ; Sets GP1 as input 
    bsf	    ANSEL, 1	    ; Sets GP1 as analog
    movlw   0xC1	    ; 0B11000001 
    movwf   ADCON0 	    ; Enable ADC
    bcf	    STATUS, 5
    
;  See PIC Assembler Tips: http://picprojects.org.uk/projects/pictips.htm 
    
MainLoopBegin:		    ; Endless loop
    goto AlmostFever
    call AdcRead	    ; read the temperature value
    ; Checks if the temperature is lower, equal to, or higher than 37. Considering that 37 degrees Celsius is the threshold or transition value for fever.
    movlw 77		    ; Temperature constant ( Fever indicator )
    subwf temp,w	    ; subtract W from the temp 
    btfsc STATUS, 2	    ; if Z flag  = 0; temp == wreg ?  
    goto  AlmostFever	    ; temp = wreg
    btfss STATUS, 0	    ; if C flag = 1; temp < wreg?   
    goto  Normal	    ; temp < wreg
    btfsc STATUS, 0         ; if C flag = 0 
    goto  Fever		    ; temp >= wreg  (iqual was tested before, so just > is available here)
    goto MainLoopEnd
    
AlmostFever:		    ; Temperature is 37
    ; BlinkLED
    call Delay
    bsf GPIO,0
    call Delay
    bcf GPIO,0        
    goto MainLoopEnd
Fever:			    ; Temperature is greater than 37
    ; Turn the  LED ON
    bcf GPIO,0
    goto MainLoopEnd

Normal: 
    ; Turn the LED off
    bsf GPIO,0  
    goto MainLoopEnd
    
ReadError: 
    ; BlinkLED faster
    movlw 1
    movwf delayParam
    call Delay
    bsf GPIO,0
    call Delay
    bcf GPIO,0        
  
MainLoopEnd:     
  
    
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
    
    ; ADRESL and ADRESH have the voltage (10 mv per degree Celsius) 
    bsf	  STATUS, 5
    movf  ADRESL,w	; Low byte of the voltage value got from ADC  GP1	
    movwf paramL   
    bcf	  STATUS, 5
    movf  ADRESH,w	; High byte of the voltage value got from ADC GP1
    movwf paramH
    ; Convert to temperature/volts:  ADRESL * 500 / 1024  (ADRESH is not cxonsidered here) 
    ; So, if the result is 77, the temperature is 37 (77 * 500 / 1024)
EndABC:   
    movf paramL, w
    movwf temp			    ; If temp >= 77 the temperature is 37 degree Celsius
    return
   
    
; ******************
; Delay function
;
; For an oscillator of 4MHz a regular instructions takes 1us (See pic16f628a Datasheet, page 117).      
; So, at 4MHz, this Delay subroutine takes about: (5 cycles) * 255 * 255 * delayParam * 0.000001 (second)  
; It is about 1s (0.975 s)  - One second  if delayParam is 3
Delay:  
    movlw   3
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


