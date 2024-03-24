; UNDER  IMPROVEMENTS...
; I couldn't find clear documentation on how to configure the interrupt service using "pic-as". 
; Therefore, I tried some configurations so that the occurrence of a desired interrupt would 
; divert the program flow to address 4h. This was possible by adding special parameters as shown below.
; Go to properties and set pic-as Additiontal Options: -Wl,-PresetVec=0x0,-PisrVec=0x04   
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

auxValue    equ 0x20		; counter 1
adcValueL   equ 0x21		; 8 bits less significant value of the adc
adcValueH   equ 0x22		; 8 bits most significant value of the adc
pwm	    equ	0x23   
   	    
PSECT resetVec, class=CODE, delta=2 
ORG 0x0000	    
resetVect:
    PAGESEL main
    goto main
;
; INTERRUPT IMPLEMENTATION 
; THIS FUNCTION WILL BE CALLED EVERY TMR0 Overflow
; pic-as Additiontal Options: -Wl,-PresetVec=0x0,-PisrVec=0x04    
PSECT isrVec, class=CODE, delta=2
ORG 0x0004     
isrVec:  
    PAGESEL interrupt
    goto interrupt
  
interrupt: 
   
    bcf	    STATUS, 5
    
    bcf	    INTCON, 7	; Disables GIE
    
    ; check if the interrupt was trigged by Timer0	
    btfss   INTCON, 2	; INTCON - T0IF: TMR0 Overflow Interrupt Flag 
    goto    PWM_FINISH
    btfss   GPIO, 5	; 
    goto    PWM_LOW 
    goto    PWM_HIGH
PWM_LOW: 
    movlw   255
    movwf   auxValue
    movf    pwm, w
    subwf   auxValue, w
    movwf   TMR0
    bsf	    GPIO, 5	    ; GP5 = 1
    ; bcf	    GPIO,2	    ; For Debugging 
    goto    PWM_T0IF_CLR
PWM_HIGH: 
    movf    pwm, w
    movwf   TMR0 
    bcf	    GPIO, 5	    ; GP5 = 0
    ; bsf	    GPIO,2	    ; For Debugging    
PWM_T0IF_CLR:
    bcf	    INTCON, 2  
PWM_FINISH:
    bsf	    INTCON, 7		    ; Enables GIE
   
    retfie    
    
    
; PSECT code, delta=2
main: 
    ; Bank 1
    bsf	    STATUS,5	    ; Selects Bank 1  
    movlw   0B00010001	    ; AN0 as analog 
    movwf   ANSEL	    ; Sets GP0 as analog and Clock / 8    
    movlw   0B00000001	    ; GP0 as input and GP1, GP2, GP4 and GP5 as digital output
    movwf   TRISIO	    ; Sets all GPIO as output
    ; OPTION_REG setup
    ; bit 5 = 0 -> Internal instruction cycle clock;
    ; bit 3 =  0 -> Prescaler is assigned to the TIMER0 module
    ; bits 0,1,2 = 101 -> TMR0 prescaler = 64 
    movlw   0B00000101	
    ; movlw   0B01000001	    ; For debugging
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
    movlw   0B11100000
    iorwf   INTCON
    
    movlw   128
    movwf   pwm
    movwf   TMR0
    
    ; bcf	    GPIO,2	; For Debugging 
    
MainLoopBegin:		; Endless loop
    call    AdcRead
    
    ; Divide 10 bits integer adc value  by 4 and stores the resul in pwm
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

    movwf   pwm		    ;  pwm has now the 10 bits integer adc value divided by 4.      
      
    goto    MainLoopBegin
     

;
; Read the analog value from GP0 (PIN 7 OF THE PIC12F675)
AdcRead: 
      
    ; For debugging
    ; movlw   LOW(800)
    ; movwf   adcValueL
    ; movlw   HIGH(800)
    ; movwf   adcValueH
    ; return 
    
    bcf	  STATUS, 5		; Select bank 0 to deal with ADCON0 register
    bsf	  ADCON0, 1		; Start convertion  (set bit 1 to high)

WaitConvertionFinish:		; do while the bit 1 of ADCON0 is 1 
    btfsc  ADCON0, 1		; Bit Test, Skip if Clear - If bit 1 in ADCON0 is '1', the next instruction is executed.
    goto   WaitConvertionFinish 

    movf  ADRESH, w		; BANK 0
    movwf adcValueH   
    
    bsf	  STATUS, 5		; Select BANK 1 to access ADRESL register
    movf  ADRESL, w		
    movwf adcValueL		; 

    bcf	  STATUS, 5		; Select bank 0 
    
    return    
        
    
END resetVect





