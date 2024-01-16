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
paramL	equ 0x20       ; 
paramH	equ 0x21
dummy1	equ 0x22 
dummy2	equ 0x23 
dummy3	equ 0x24 
count   equ 0x25
temp	equ 0x26
divider equ 0x27	
    
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
    bcf	    STATUS, 5
    
;  See PIC Assembler Tips: http://picprojects.org.uk/projects/pictips.htm 
    
MainLoopBegin:		    ; Endless loop
    call AdcRead	    ; read the temperature value
    ; Checks if the temperature is lower, equal to, or higher than 37. Considering that 37 degrees Celsius is the threshold or transition value for fever.
    movlw 37		    ; Temperature constant ( Fever indicator )
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
    bsf GPIO,0
    goto MainLoopEnd

Normal: 
    ; Turn the LED off
    bsf GPIO,0   
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
    ; ADRESL and ADRESH have the voltage (10 mv per degree Celsius) 
    
    
    
    movf  ADRESL,w	; Low byte of the voltage value got from ADC  GP1	
    movwf paramL     
    movf  ADRESH,w	; High byte of the voltage value got from ADC GP1
    movwf paramH
     
    call DivideTempBy10	    ; returns the converted votage to temperature 
    return


    
; *****************
; Divide by 10  the voltage value got from ADV GP1   
;   
DivideTempBy10:     
; Inicializações
    clrf temp
    clrf count    

    movlw 10
    movwf divider

DivideLoop:    
    incf  count,f
    subwf paramL, f
    btfsc STATUS, 0
    goto DivideLoop
    movlw 1		; if voltage is greater than 255 mv, so the value of the high byte is 1
    subwf paramH	; 
    btfss STATUS, 0  
    goto  DivideFinish
    movlw 26
    addwf count
DivideFinish:
    decf count,f
    movf count,w
    movwf temp
    return;

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


