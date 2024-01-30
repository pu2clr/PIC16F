; Controlling 8 LEDs with PIC10F200 and the Shift Register 74HC595
; My PIC Journey
; Author: Ricardo Lima Caratti
; Jan/2024
;
; IMPORTANT: To assemble this code correctly, please follow the steps below:
; 1. Go to "Project Properties" in MPLAB X.
; 2. Select "Global Options" for the pic-as assembler/compiler.
; 3. In the "Additional Options" box, enter the following parameters:
; -Wl,-pAsmCode=0h
;
; Please check the AsmCode reference in the "PSECT" directive below.
;
; You will find good tips about the PIC10F200 here:
; https://www.circuitbread.com/tutorials/christmas-lights-special-microcontroller-basics-pic10f200

 
    
#include <xc.inc>

; CONFIG
  CONFIG  WDTE = OFF           ; Watchdog Timer (WDT disabled)
  CONFIG  CP = OFF             ; Code Protect (Code protection off)
  CONFIG  MCLRE = ON	       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)

  
; Declare your variables here

dummy1	equ 0x10
dummy2	equ 0x11 
value	equ 0x12	 
 
PSECT AsmCode, class=CODE, delta=2

MAIN:   
    ; 74HC595 and PIC10F200 GPIO SETUP 
    ; GP0 -> Data		-> 74HC595 PIN 14 (SER); 
    ; GP1 -> Clock		-> 74HC595 PINs 11 and 12 (SRCLR and RCLK);   
    ; GP2 -> Output Enable/OE	-> 74HC595 PIN 13
    movlw   0B00000000	    ; All GPIO Pins as output		
    tris    GPIO
MainLoop:		    ; Endless loop
    ; Under construction
    movlw   0B11111111
    
    movlw   255
    
Loop74HC595:
    
    andlw   0x01
    subwf   1,w
    
    ; Under construction
    
    
    
    ; Prepere Data to send
    
    
    ; Clock 
    bsf	    GPIO, 1		    ; Turn GP1 HIGH
    call    Delay100us		    ;
    bcf	    GPIO, 1		    ; Turn GP1 LOW
    call    Delay100us
    
    
    ; Enable Output
    bsf	    GPIO, 2		    ; Turn GP2 HIGH
    call    Delay100us
    bcf	    GPIO, 2		    ; Turn GP2 LOW
    
    
    
    
    goto Loop74HC595
    
MainLoopEnd:
    ; Delay about 1 second ( You can not use more than two stack levels )
    movlw   255
    movwf   dummy2
Delay1s:
    call    Delay2ms
    call    Delay2ms
    decfsz  dummy2, f
    goto    Delay1s
    
    goto    MainLoop
     
; ******************
; Delay function

; At 4 MHz, one instruction takes 1us
; So, this soubroutine should take about 10?s 
; This time is used by the HC-S04 ultrasonic sensor 
; to determine the distance. 	
Delay10us:
    nop		;  2 cycles (CALL) + 6 cycles (NOP)
    nop
    nop
    nop
    nop
    nop	    
    retlw 0	; + 2 cycles (retlw) => 10 cycles =~ 10us at 4MHz frequency clock    

; It takes 100 us    
Delay100us:
    movlw   10
    movwf   dummy1    
LoopDelay100us:   
    call    Delay10us    
    decfsz  dummy1, f
    goto    LoopDelay100us
    retlw   0
    
; It takes about 2ms
Delay2ms: 
    movlw  200
    movwf  dummy1
LoopDelay2ms: 
    call Delay10us    
    decfsz dummy1, f
    goto LoopDelay2ms
    retlw   0
    
END MAIN
