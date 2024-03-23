; UNDER CONSTRUCTION... 
; Author: Ricardo Lima Caratti
; Jan/2024
    

PROCESSOR 12F675
    __CONFIG  _WDT_OFF & _PWRTE_ON & _BOREN_OFF

include "P12F675.inc"



idxI	    equ 0x20		; counter 1
idxJ	    equ 0x21		; counter 2
delayParam  equ 0x22 
adcValueL   equ 0x23		; 8 bits less significant value of the adc
adcValueH   equ 0x24		; 8 bits most significant value of the adc
pwm	    equ	0x25   
   	    
reset_vec ORG 0x0000	    
    goto main


int_srv ORG 0x0004     
    goto interrupt
  
    
main: 
    ; Bank 1
    bsf	    STATUS,5	    ; Selects Bank 1  
    movlw   b'00010001'	    ; AN0 as analog 
    movwf   ANSEL	    ; Sets GP0 as analog and Clock / 8    
    clrw
    movwf   TRISIO	    ; Sets all GPIO as output
    ; OPTION_REG setup
    ; bit 5 = 0 -> Internal instruction cycle clock;
    ; bit 3 =  0 -> Prescaler is assigned to the TIMER0 module
    ; bits 0,1,2 = 101 -> TMR0 prescaler = 64 
    movlw   b'01000101'	     
    movwf   OPTION_REG	    
    ; Bank 0
    bcf	    STATUS,5 
    clrf    GPIO	; Turn all GPIO pins low
    movlw   0x07	;   
    movwf   CMCON	; digital IO  
    movlw   b'10000001'	; Right justified; VDD;  01 = Channel 00 (AN0); A/D converter module is 
    movwf   ADCON0	; Enable ADC   
    
    ; INTCON setup
    ; bit 7 (GIE) = 1 => Enables all unmasked interrupts
    ; bit 5 (T0IE) =  1 => Enables the TMR0 interrupt
    movlw   b'11100000'
    iorwf   INTCON
    
    movlw   0x80
    movwf   pwm
    movwf   TMR0
MainLoopBegin:		; Endless loop
    call    AdcRead
    
    ; Divide 10 bits integer value  by 4 and stores the resul in pwm
    rrf	    adcValueL
    rrf	    adcValueL
    movf    adcValueL, w
    andlw   b'00111111'
    movwf   adcValueL
    swapf   adcValueH
    rlf	    adcValueH	
    rlf	    adcValueH	     
    movf    adcValueH, w
    andlw   b'11000000'
    iorwf   adcValueL, w    
    movwf   pwm		    ;  adcValueL has now the 10 adc bit value divided by 4.      
    
  MainLoopEnd:     
    goto MainLoopBegin
     

;
; Read the analog value from GP1
AdcRead: 
      
  
    bcf	  STATUS, 5		; Select bank 0 to deal with ADCON0 register
    bsf	  ADCON0, 1		; Start convertion  (set bit 1 to high)

WaitConvertionFinish:		; do while the bit 1 of ADCON0 is 1 
    btfsc  ADCON0, 1		; Bit Test, Skip if Clear - If bit 1 in ADCON0 is '1', the next instruction is executed.
    goto   WaitConvertionFinish 

    movwf adcValueH   
    movf  ADRESH, w		; BANK 0
    
    bsf	  STATUS, 5		; Select BANK 1 to access ADRESL register
    movf  ADRESL, w		
    movwf adcValueL		; 

    return    
    
; ******************
; Delay function
; Deleys about  WREG * 255us

Delay:  
    movwf   delayParam    
    movlw   0xFF
    movwf   idxI	; 255 times
    movwf   idxJ	; 255 times (255 * 255)
			; 255 * 255 * delayParam loaded before calling Delay    
DelayLoop:    
    nop                 ; One cycle
    nop                 ; One cycle
    decfsz idxI, f	; One cycle* (idxI = dumm1 - 1) => if idxI is 0, after decfsz, it will be 255
    goto DelayLoop      ; Two cycles
    decfsz idxJ, f	; idxJ = dumm2 - 1; if idxJ = 0, after decfsz, it will be 255
    goto DelayLoop
    decfsz delayParam,f ; Runs 3 times (255 * 255)		 
    goto DelayLoop
    
    return 

interrupt: 
    bcf	    STATUS, 5
    ; check if the interrupt was trigged by Timer0	
    btfss   INTCON, 2	; INTCON - T0IF: TMR0 Overflow Interrupt Flag 
    goto    PWM_FINISH
    btfss   GPIO, 5	; 
    goto    PWM_LOW 
    goto    PWM_HIGH
PWM_LOW: 
    bcf	    GPIO, 5
    movlw   0XFF
    movwf   idxI
    movf    pwm, w
    subwf   idxI, w
    movwf   TMR0
    goto    PWM_FINISH
PWM_HIGH: 
    movf    pwm, w
    subwf   TMR0 
    bsf	    GPIO, 5
PWM_FINISH:
    bcf	    INTCON, 2
    ; bsf	    INTCON, 7
    ; bsf	    INTCON, 5
    
    retfie   

    END 







