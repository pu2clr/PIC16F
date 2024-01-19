; Fever Indicator with PIC12F675 with LM35 or TMP36
;
; This projects utilizes either an LM35 or TMP36 temperature sensor to determine if a body's temperature is below, 
; equal to, or above 37 degrees Celsius. The approach is streamlined to improve efficiency: there's no conversion 
; of the sensor's analog signal to a Celsius temperature reading, as the actual temperature value isn't displayed.
; The key lies in understanding the digital equivalent of 37 degrees Celsius in the sensor's readings. 
; For instance, an analog reading of 77, when converted to digital through the Analog-to-Digital Converter (ADC), 
; corresponds to 37 degrees Celsius. This can be calculated as follows:
; 
; Let's see: ADC Value * 5 / 1024 * 100 = Temperature in Degrees Celsius.
; 
; Thus: 77 * 5 / 1024 * 100 = 37.59°C
;    
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
dummy1	    equ 0x20 
dummy2	    equ 0x21 
delayParam  equ 0x22 
count	    equ 0x23
temp	    equ 0x24
divider	    equ 0x25
    
PSECT resetVector, class=CODE, delta=2
resetVect:
    PAGESEL main
    goto main
PSECT code, delta=2
main:
    ; Analog and Digital pins setup
    bcf	    STATUS, 5		; Selects Bank 0
    clrf    GPIO		; Init GPIO	
    bcf	    CMCON, 0		; Sets GP0 as output 
    movlw   0b10000101 		; Right justified; VDD;  01 = Channel 01 (AN1); A/D converter module is 
    movwf   ADCON0		; Enable ADC   
    bsf	    STATUS, 5		; Selects Bank 1
    
    movlw   0b00000010		
    movwf   TRISIO		; AN1 - input
    movlw   0b00000010		; AN1 as analog 
    movwf   ANSEL	 	; Sets GP1 as analog and Clock / 8
    bcf	    STATUS, 5		; Selects bank 0
    
;  See PIC Assembler Tips: http://picprojects.org.uk/projects/pictips.htm 
    
MainLoopBegin:		    ; Endless loop
    call AdcRead	    ; read the temperature value
    ; Checks if the temperature is lower, equal to, or higher than 37. Considering that 37 degrees Celsius is the threshold or transition value for fever.
    movlw 77		    ; 77 is the equivalent ADC value to 37 degree Celsius  
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
    bcf GPIO,0  
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
    bcf	  STATUS, 5		; Select bank 0 to deal with ADCON0 register
    bsf	  ADCON0, 1		; Start convertion  (set bit 1 to high)

WaitConvertionFinish:		; do while the bit 1 of ADCON0 is 1 
    btfsc  ADCON0, 1		; Bit Test, Skip if Clear - If bit 1 in ADCON0 is '1', the next instruction is executed.
    goto   WaitConvertionFinish 
    
    bsf	  STATUS, 5		; Select bank1 to deal with ADRESL register
    movf  ADRESL, w		
    movwf temp			; If temp => 77 the temperature is about 37 degree Celsius
    bcf	  STATUS, 5		; Select to bank 0
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


