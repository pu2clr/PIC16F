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

adcValueL   equ 0x20		; 8 bits less significant value of the adc
adcValueH   equ 0x21		; 8 bits most significant value of the adc
delayParam  equ	0x22  
ind_I	    equ	0x23
ind_J	    equ 0x24	    
   	    
PSECT resetVec, class=CODE, delta=2 
ORG 0x0000	    
resetVec:
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
    btfss   INTCON, 1		; INTCON - INTF: GP2/INT External Interrupt Flag bit
    goto    INT_FINISH
    btfss   GPIO, 5		; Toggle LED (ON/OFF)
    goto    INT_SWITCH_ON
    goto    INT_SWITCH_OFF
INT_SWITCH_ON:    
    bsf	    GPIO,5
    goto    INT_CONTINUE
INT_SWITCH_OFF:    
    bcf	    GPIO,5
INT_CONTINUE:    
    movlw   1
    call    Delay
    bcf	    INTCON, 1  
INT_FINISH:
    bsf	    INTCON, 7		; Enables GIE
    
    retfie    
      
; PSECT code, delta=2
main: 

    
    ; Bank 1
    bsf	    STATUS,5	    ; Selects Bank 1  
    movlw   0B00000100	    ; GP1 as input and GP1, GP2, GP4 and GP5 as digital output
    movwf   TRISIO	    ; Sets all GPIO as output    
    clrf    ANSEL	    ; Disable Analog setup   

    ; OPTION_REG setup
    ; bit 5 = 0 -> Internal instruction cycle clock;
    movlw   0B01000000	
    movwf   OPTION_REG	    
    ; Bank 0
    bcf	    STATUS,5 
   
    clrf    GPIO	; Turn all GPIO pins low
    
    ; ---- if you are using debounce capacitor ---
    movlw   1		; Wait for the debounce capacitor becomes stable 
    call    Delay
    ; ----
    
    ; INTCON setup / enable interrupt 
    ; bit 7 (GIE) = 1 => Enables all unmasked interrupts / Global Interrupt Enable bit
    ; bit 4 (INTE) =  1 => GP2/INT External Interrupt Flag bit
    movlw   0B10010000
    movwf   INTCON   

    ; Debug - Blink LED to indicate that the system is alive
    ; bsf	    GPIO, 5	; LED ON
    ; movlw   6
    ; call    Delay
    ; bcf	    GPIO, 5	; LED OFF
	
MainLoopBegin:		; Endless loop
    sleep      
    goto    MainLoopBegin
     

; ******************
; Delay function
;

Delay:  
    movwf   delayParam
    movlw   100
    movwf   ind_I	; 100 times
    movwf   ind_J	; 100 times 
			; 100 * 100 * delayParam    
DelayLoop:    
    nop                 ; One cycle
    nop                 ; One cycle
    decfsz ind_I, f	; One cycle * (ind_I = ind_I - 1) => if ind_I is 0, after decfsz, it will be 255
    goto DelayLoop      ; Two cycles
    decfsz ind_J, f	; ind_J = ind_J - 1; if ind_J = 0, after decfsz, it will be 255
    goto DelayLoop
    decfsz delayParam,f ; Runs WREG/delayParam * (100 * 100)		 
    goto DelayLoop
    
    return     
    
    
END resetVec

