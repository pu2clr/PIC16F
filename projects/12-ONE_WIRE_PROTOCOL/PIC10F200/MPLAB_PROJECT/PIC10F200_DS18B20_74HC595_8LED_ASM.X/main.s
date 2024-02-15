; UNDER CONSTRUCTION...  
; This project uses a DS18B20 sensor, a PIC10F200 microcontroller, and a 74HC595 
; shift register to control 8 LEDs that indicate the ambient temperature according 
; to the Gagge scale ("A psychophysical model of thermal comfort and discomfort"). 
; The goal is to visually represent the level of comfort or discomfort of the 
; temperature through the LEDs.   
;    
; Author: Ricardo Lima Caratti
; Feb/2024
;
; IMPORTANT: To assemble this code correctly, please follow the steps below:
; 1. Go to "Project Properties" in MPLAB X.
; 2. Select "Global Options" for the pic-as assembler/compiler.
; 3. In the "Additional Options" box, enter the following parameters:
; -Wl,-pAsmCode=0h
;
; Please check the AsmCode reference in the "PSECT" directive below.
;
    
#include <xc.inc>

; CONFIG
  CONFIG  WDTE = OFF           ; Watchdog Timer (WDT disabled)
  CONFIG  CP = OFF             ; Code Protect (Code protection off)
  CONFIG  MCLRE = ON	       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)

  
; Declare your variables here

dummy1	    equ 0x10
dummy2	    equ 0x11 
startValue  equ 0x12		; Initial value to be sent	
valueToSend equ 0x13		; Current value to be sent
counter	    equ 0x14		
	
 
PSECT AsmCode, class=CODE, delta=2

MAIN:   
    ; 74HC595 and PIC10F200 GPIO SETUP 
    ; GP0 -> Data		    -> 74HC595 PIN 14 (SER); 
    ; GP1 -> Clock		    -> 74HC595 PINs 11 and 12 (SRCLR and RCLK);   
    movlw   0B00000000	    ; All GPIO Pins as output		
    tris    GPIO
    movlw   0B10101010	    ; An alternating sequence of lit LEDs 
    movwf   startValue	    ; The initial value to be sent to the 74HC595
MainLoop:		    ; Endless loop
    movlw   7
    movwf   counter
    movf    startValue, w
    movwf   valueToSend	    ;  
    ; Start sending  
PrepereToSend:  
    btfss   valueToSend, 0  ; Check if less significant bit is 1
    goto    Send0	    ; if 0 turn GP0 low	
    goto    Send1	    ; if 1 turn GP0 high
Send0:
    bcf	    GPIO, 0	    ; turn the current 74HC595 pin off 
    goto    NextBit
Send1:     
    bsf	    GPIO, 0	    ; turn the current 74HC595 pin on
NextBit:    
    ; Clock 
    call doClock	    ; Process current data (bit)
    ; Shift all bits of the valueToSend to the right and prepend a 0 to the most significant bit
    
    bcf	    STATUS, 0	    ; Clear cary flag before rotating 
    rrf	    valueToSend, f
    
    decfsz counter, f	    ; Decrement the counter and check if it becomes zero.
    goto PrepereToSend	    ; if not, keep prepering to send
    
    ; The data has been queued and can now be sent to the 74HC595 port
    call doClock	    ; Process latest data (bit)
      
MainLoopEnd:
    ; Delays about 1 second 
    movlw   255
    movwf   dummy2
Delay1s:
    call    Delay2ms
    call    Delay2ms
    decfsz  dummy2, f
    goto    Delay1s
    
    comf    startValue, f   ; Inverts the startValue bits. Alternating its value with each iteration 
    
    goto    MainLoop

; 74HC595 Clock processing
; ATTENTION: Due to the two-level stack limit of the PIC10F200, avoid calling this  
;            subroutine from within another subroutine to prevent stack overflow issues.    
doClock:
    ; Clock 
    bsf	    GPIO, 1	    ; Turn GP1 HIGH
    call    Delay100us	    ;
    bcf	    GPIO, 1	    ; Turn GP1 LOW
    call    Delay100us
    retlw   0
    
; ******************
; Delay function

; At 4 MHz, one instruction takes 1us
; So, this soubroutine should take about 10 x 10 us 

; It takes 100 us    
Delay100us:
    movlw   10
    movwf   dummy1    
LoopDelay100us:   
    goto $+1		    ; 2 cycles
    goto $+1		    ; 2 cycles
    goto $+1		    ; 2 cycles
    nop
    decfsz  dummy1, f	    ; 1 cycles (2 if dummy = 0)
    goto    LoopDelay100us  ; 2 cycles
    retlw   0
    
; It takes about 2ms
Delay2ms: 
    movlw  200
    movwf  dummy1
LoopDelay2ms: 
    goto $+1		    ; 2 cycles
    goto $+1		    ; 2 cycles
    goto $+1		    ; 2 cycles
    nop			    ; 1 cycle
    decfsz  dummy1, f	    ; 1 cycles (2 if dummy = 0)
    goto LoopDelay2ms	    ; 2 cycles
    retlw   0
    
END MAIN
