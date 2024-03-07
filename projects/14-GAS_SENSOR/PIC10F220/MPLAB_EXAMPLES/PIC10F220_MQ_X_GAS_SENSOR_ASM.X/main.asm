; My PIC Journey  - MQ-2 Gas sensor and PIC10F220
; 
; This application displays three possible situations to represent the gas level: a lit red LED means danger, 
; a blinking green and red LED at the same time means caution or alert, and a lit green LED means safe.    
; 
; ATTENTION: This experiment is solely intended to demonstrate the interfacing of an MQ series gas sensor 
; with PIC microcontrollers. The gas concentration values and thresholds used in the example programs have 
; been arbitrarily set to illustrate high, medium, or low gas concentration levels. However, it is crucial 
; to emphasize that these values may not accurately reflect the real concentrations that pose a health risk. 
; Therefore, if you plan to use the examples provided, it is strongly recommended to consult the gas sensor's Datasheet. 
; This is essential to ascertain the exact values that define dangerous, tolerable, or low gas concentrations.  
; Author: Ricardo Lima Caratti
; Feb/2022  
; IMPORTANT: If you are using the PIC10F220, to assemble this code correctly, please follow the steps below:
; 1. Go to "Project Properties" in MPLAB X.
; 2. Select "Global Options" for the pic-as assembler/compiler.
; 3. In the "Additional Options" box, enter the following parameters:
; -Wl,-pAsmCode=0h
    
#include <xc.inc>
  
; CONFIG
  CONFIG  IOSCFS = 4MHZ         ; Internal Oscillator Frequency Select bit (4 MHz)
  CONFIG  MCPU = OFF            ; Master Clear Pull-up Enable bit (Pull-up disabled)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled)
  CONFIG  CP = OFF              ; Code protection bit (Code protection off)
  CONFIG  MCLRE = ON            ; GP3/MCLR Pin Function Select bit (GP3/MCLR pin function is MCLR)

; Declare your variables here

counter1	equ	0x10
counter2	equ	0x11
adcValue	equ	0x12	
	
	 
PSECT AsmCode, class=CODE, delta=2

MAIN:
    ; ADCON0 register setup 
    ; bit 7 - ANS1: 0 = GP1/AN1 configured as digital I/O
    ; bit 6 - ANS0: 1 = GP0/AN0 configured as an analog input
    ; bit 5 - Unimplemented
    ; bit 4 - Unimplemented
    ; bit 3:2 - CHS<1:0>: ADC Channel Select bits - 00 = Channel00(GP0/AN0)
    ; bit 1 - 1 = ADC conversion in progress. Setting this bit starts an ADC conversion cycle.
    ; bit 0 - 1 = ADC module is operating
    movlw   0B01000011
    movwf   ADCON0	; See DS41270E-page 30 datasheet 
    
    ; OPTION register setup 
    ; Prescaler Rate: 256
    ; Prescaler assigned to the WDT
    ; Increment on high-to-low transition on the T0CKI pin
    ; Transition on internal instruction cycle clock, FOSC/4
    ; GPPU disbled 
    ; GPWU disabled
    movlw   0B10011111	    	 
    OPTION		; See DS40001239F-page 16 datasheet 
    
    ; GP0 is input, GP1, GP2 are output
    movlw   0B00000001
    TRIS    GPIO
MainLoop:		    ; Endless loop
    call    AdcRead
    movlw   210		    ; If > 210, Dangerous
    subwf   adcValue, w
    btfss   STATUS, 0
    goto    CheckAttention
Dangerous:
    bsf	    GPIO, 2
    bcf	    GPIO, 1
    goto    MainLoopContinue
CheckAttention: 
    movlw   127		    ; If > 127 and < 210, Attention
    subwf   adcValue, w
    btfss   STATUS, 0
    goto    Safe
    call    BlinkAttention  ; Blink green and red LEDs at the same time  
    goto    MainLoop
Safe: 
    bsf	    GPIO, 1
    bcf	    GPIO, 2
MainLoopContinue: 
   movlw    255 
   call	    DelayMS  
   goto	    MainLoop
    
 
   
; ******** ADC Read ************
; Read the analog value from GP0
; Return the value in adcValue   
AdcRead: 
    bsf	  ADCON0, 1		; Start convertion  (set bit 1 to high)
WaitConvertionFinish:		; do while the bit 1 of ADCON0 is 1 
    btfsc  ADCON0, 1		; Bit Test, Skip if Clear - If bit 1 in ADCON0 is '1', the next instruction is executed.
    goto   WaitConvertionFinish 
    
    movf  ADRES, w		
    movwf adcValue		; 
    retlw 0
    
; ******* BLINK ATTENTION
;     
BlinkAttention: 
    bsf	    GPIO, 1
    bsf	    GPIO, 2
    movlw   100
    call    DelayMS
    bcf	    GPIO, 1
    bcf	    GPIO, 2    
    movlw   100
    call    DelayMS  
    retlw   0
   
    
; ***********************    
; It takes about WREG * 255us
DelayMS:
    movwf   counter1
DelayMS_01:
    movlw   255
    movwf   counter2
DelayMS_02: 
    goto $+1
    goto $+1
    goto $+1
    goto $+1
    decfsz  counter2, f
    goto    DelayMS_02
    decfsz  counter1, f
    goto    DelayMS_01
    
    retlw   0    
        
    
END MAIN







