; UNDER CONSTRUCTION... 
; Author: Ricardo Lima Caratti
; Jan/2024
    
#include <xc.inc>
 
; CONFIG
  CONFIG  FOSC = INTRCIO        ; Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-Up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF           ; GP3/MCLR pin function select (GP3/MCLR pin function is digital I/O, MCLR internally tied to VDD)
  CONFIG  BOREN = OFF           ; Brown-out Detect Enable bit (BOD disabled)
  CONFIG  CP = OFF              ; Code Protection bit (Program Memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)

; declare your variables here

dummy1	    equ 0x20 
dummy2	    equ 0x21 
delayParam  equ 0x22 
adcValueL   equ 0x23
adcValueH   equ 0x24
pwm	    equ	0x25   
    
PSECT resetVector, class=CODE, delta=2 
resetVect:
    PAGESEL main
    goto main
    
PSECT code, delta=2
main:
    ; Interrupt, Analog and Digital pins setup
    
    ; BANK 1
    bsf	    STATUS, 5		; Selects Bank 1  
    movlw   0B00000001		
    movwf   TRISIO		    ;   AN0 - input
    movlw   0b00010001		; AN0 as analog 
    movwf   ANSEL	 	    ; Sets GP0 as analog and Clock / 8
    movlw   0B00000101		; TMR0 prescaler = 64 
    movwf   OPTION_REG
    
    ; BANK 0
    movlw   0B10100100		; GIE and T0IE enable
    ; movwf   INTCON		; INTCON address in BANK 0	
    bcf	    STATUS, 5		; Selects Bank 0
    clrf    GPIO		; Init GPIO	
    clrf    CMCON		; COMPARATOR Register Setup
    movlw   0B10000001 		; Right justified; VDD;  01 = Channel 00 (AN0); A/D converter module is 
    movwf   ADCON0		; Enable ADC
    clrf    TMR0
       
MainLoopBegin:		    ; Endless loop
    call    AdcRead	    ; reads ADC value and returns in adcValueL and adcValueH
    ; divides 16 bits (actually 10 integer) by 4  
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

    movwf adcValueH   
    movf  ADRESH, w		; BANK 0
    
    bsf	  STATUS, 5		; Select BANK 1 to access ADRESL register
    movf  ADRESL, w		
    movwf adcValueL		; 

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
    
;
; INTERRUPT - FUNCTION SETUP  
; THIS FUNCTION WILL BE CALLED EVERY TMR0 Overflow
; pic-as Additiontal Options: -Wl,-pisrVec=4h    
PSECT isrVec, class=CODE, delta=2
ORG 0x04     
isrVec:  
    PAGESEL main
    goto interrupt_process
    
interrupt_process:    
    bcf	    STATUS, 5
    ; check if the interrupt was trigged by Timer0	
    btfsc   INTCON, 2	; INTCON - T0IF: TMR0 Overflow Interrupt Flag 
    goto    PWM_FINISH
    btfss   GPIO, 5	; 
    goto    PWM_LOW 
    goto    PWM_HIGH
PWM_LOW: 
    bcf	    GPIO, 5
    movlw   255
    movwf   dummy1
    movf    pwm, w
    subwf   dummy1, w
    movwf   TMR0
    goto    PWM_FINISH
PWM_HIGH: 
    movf    pwm,w
    subwf   TMR0 
    bsf	    GPIO, 5
    bcf	    INTCON, 2
PWM_FINISH:
    
    retfie
    
    
END resetVect





