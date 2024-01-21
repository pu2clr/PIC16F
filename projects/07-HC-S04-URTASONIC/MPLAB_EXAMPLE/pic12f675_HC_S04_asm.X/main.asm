; UNDER Construction... 
; My PIC Journey   
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
durationL   equ 0x23  
durationH   equ 0x24  
   
PSECT resetVector, class=CODE, delta=2
resetVect:
    PAGESEL main
    goto main
PSECT code, delta=2
main:
    ; Analog and Digital pins setup
    bcf	    STATUS, 5		; Selects Bank 0
    clrf    GPIO		; Init GPIO
    clrf    CMCON		; COMPARATOR Register setup
    movlw   0b10001101 	; Right justified; VDD;  01 = Channel 3 (AN3); A/D converter module is 
    movwf   ADCON0		; Enable ADC   
    bsf	    STATUS, 5		; Selects Bank 1
    movlw   0b00010000		; GP4 as input
    movwf   TRISIO		 
    clrf    ANSEL	 	; Digital
    bcf	    STATUS, 5		; Selects bank 0
MainLoopBegin:			; Endless loop
    ; Under construction
    call ReadHCS04		; 
    movlw 77			; Process distance based on duration (durationL and durationH)
    subwf durationL,w		; subtract W from the durationL 
    btfsc STATUS, 2		; if Z flag  = 0; durationL == wreg ?  
    goto  Close			; durationL = wreg
    btfss STATUS, 0		; if C flag = 1; durationL < wreg?   
    goto  Distant		; durationL < wreg
    btfsc STATUS, 0		; if C flag = 0 
    goto  ReallyClose		; durationL >= wreg  (iqual was tested before, so just > is available here)
    goto MainLoopEnd
    
Close:				; Between 10 and 30 cm
    call YellowOn
    goto MainLoopEnd
ReallyClose:			; Less than 10 cm
    call RedOn
    goto MainLoopEnd
Distant:			; 30 cm or more
    call GreenOn
    goto MainLoopEnd
  
MainLoopEnd:    
    call Delay10us
    call Delay10us
    call Delay10us
    
    goto MainLoopBegin

; ******************************      
; Turn Green LED On
GreenOn:
    call AllOff
    movlw 1	  ; 0B00000001  
    movwf GPIO
    return

; ******************************    
; Turn Yellow LED ON    
YellowOn: 
    call AllOff
    movlw 2	   ; 0B00000010
    movwf GPIO
    return  
    
; ******************************    
RedOn: 
    call AllOff
    movlw 4	   ; 0B00000100
    movwf GPIO
    return        

; ******************************
; Turn all LEDs off
AllOff: 
    clrw 
    movwf GPIO
    return
    
; ******** HC-S04 ************
; Read the HC-S04 - GP1
ReadHCS04: 

    bcf	    STATUS, 5		; Selects Bank 0
    clrf    TMR1H		; Reset TMR1
    clrf    TMR1L

    ; Send 10uS signal to the Trigger pin
    bsf     GPIO,5
    call    Delay10us
    bcf	    GPIO,5
    ; Wait for echo
WaitEcho1: 
    btfss   GPIO,4		; Bit Test f, Skip if Set (do while GP4 is 0)
    goto    WaitEcho1
    bsf	    T1CON,0		; Sets TMR1ON -> TMR1ON = 1
WaitEcho2: 
    btfsc   GPIO,4		; Bit Test f, Skip if Clear  (do while GP4 is 1
    goto    WaitEcho2   
    bcf	    T1CON,0		; Clear TMR1ON -> TMR1ON = 0
    ; Now you have the elapsed time stored in TMR1H and TMR1L
    
    return
    
    
;
; At 4 MHz, one instruction takes 1us
; So, this soubroutine shoul take about 10us    
Delay10us:
    nop		; 8 cycle
    nop
    nop
    nop
    nop
    nop
    nop
    nop	    
    return	; 2 cycles
    
END resetVect
