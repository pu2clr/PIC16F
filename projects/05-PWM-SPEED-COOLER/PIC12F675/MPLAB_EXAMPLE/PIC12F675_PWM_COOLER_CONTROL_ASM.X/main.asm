; UNDER CONSTRUCTION... 
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

idxI	    equ 0x20		; counter 1
idxJ	    equ 0x21		; counter 2
delayParam  equ 0x22 
adcValueL   equ 0x23		; 8 bits less significant value of the adc
adcValueH   equ 0x24		; 8 bits most significant value of the adc
pwm	    equ	0x25   
   	    
PSECT resetVector, class=CODE, delta=2 
resetVect:
    PAGESEL main
    goto main


;
; INTERRUPT - FUNCTION SETUP  
; THIS FUNCTION WILL BE CALLED EVERY TMR0 Overflow
; pic-as Additiontal Options: -Wl,-pisrVec=4h    
PSECT isrVector, class=CODE, delta=2
; ORG 0x04     
isrVector:  
    PAGESEL interrupt
    goto interrupt
  
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
    movlw   255
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
    bsf	    INTCON, 7
    bsf	    INTCON, 5
    
    retfie    
    
    
PSECT code, delta=2
main: 
    ; Bank 1
    bsf	    STATUS,5	    ; Selects Bank 1  
    movlw   0b00010001	    ; AN0 as analog 
    movwf   ANSEL	    ; Sets GP0 as analog and Clock / 8    
    clrw
    movwf   TRISIO	    ; Sets all GPIO as output
    ; OPTION_REG setup
    ; bit 5 = 0 -> Internal instruction cycle clock;
    ; bit 3 =  0 -> Prescaler is assigned to the TIMER0 module
    ; bits 0,1,2 = 101 -> TMR0 prescaler = 64 
    movlw   0B01000101	     
    movwf   OPTION_REG	    
    ; Bank 0
    bcf	    STATUS,5 
    clrf    GPIO	; Turn all GPIO pins low
    movlw   0x07	;   
    movwf   CMCON	; digital IO  
    movlw   0B10000001	; Right justified; VDD;  01 = Channel 00 (AN0); A/D converter module is 
    movwf   ADCON0	; Enable ADC   
    
    ; INTCON setup
    ; bit 7 (GIE) = 1 => Enables all unmasked interrupts
    ; bit 5 (T0IE) =  1 => Enables the TMR0 interrupt
    movlw   0B10100000
    movwf   INTCON
    
    movlw   100
    movwf   pwm
MainLoopBegin:		; Endless loop
    call    AdcRead
    
    ; Divide 10 bits integer value  by 4 and stores the resul in pwm
    rrf	    adcValueL
    rrf	    adcValueL
    movf    adcValueL, w
    andlw   0B00111111
    movwf   adcValueL
    swapf   adcValueH
    rlf	    adcValueH	
    rlf	    adcValueH	     
    movf    adcValueH, w
    andlw   0B11000000
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
    movlw   255
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
    
    
END resetVect





