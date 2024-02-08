; UNDER CONSTRUCTION... One Wire implementation
    
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
  CONFIG  MCLRE = OFF	       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)

  
; ******* MACROS **********
  
; Delays 2us
DELAY_2us MACRO
    nop
    nop
ENDM    

; Delays 10us    
DELAY_10us MACRO
    goto $ + 1
    goto $ + 1
    goto $ + 1
    goto $ + 1
    goto $ + 1  
ENDM

; Delays 80us    
DELAY_80us MACRO
    movlw  10
    movwf  dummy1
    nop
    goto $ + 1	    ; 2 cycles
    goto $ + 1	    ; 2 cycles
    goto $ + 1	    ; 2 cycles
    goto $ + 1      ; 2 cycles
    decfsz dummy1, f
    goto $ - 6
 ENDM     

; Delays 100us 
DELAY_100us MACRO
    movlw  10
    movwf  dummy1
    nop
    goto $ + 1	    ; 2 cycles
    goto $ + 1	    ; 2 cycles
    goto $ + 1	    ; 2 cycles
    goto $ + 1	    ; 2 cycles
    goto $ + 1      ; 2 cycles
    decfsz dummy1, f
    goto $ - 6
 ENDM 
 
; Delays 500 us
DELAY_500us MACRO
    movlw  50
    movwf  dummy1
    nop
    goto $ + 1	    ; 2 cycles
    goto $ + 1	    ; 2 cycles
    goto $ + 1	    ; 2 cycles
    goto $ + 1	    ; 2 cycles
    goto $ + 1      ; 2 cycles
    decfsz dummy1, f
    goto $ - 6
 ENDM  
 
  
; Sets the GP0 as output 
 SET_PIN_OUT MACRO
    clrw
    tris    GPIO
 ENDM
 
; Sets the GP0 as input  
SET_PIN_IN MACRO
    movlw   0x01
    tris    GPIO
ENDM
 

; Declare your variables here

dummy1	    equ 0x10
value	    equ 0x11 
counter	    equ 0x12
aux	    equ 0x13
tempL	    equ 0x15
tempH	    equ 0x16	    
	    
	    
PSECT AsmCode, class=CODE, delta=2

MAIN:

    clrf    GPIO
    clrw    
    tris    GPIO	    ; Sets all GPIO as output

MainLoop:  
    call    OW_START
    movlw   0xCC	    ; send skip ROM command
    movwf   value	    
    call    OW_WRITE_BYTE
    movlw   0x44	    ; send start conversion command
    movwf   value
    call    OW_WRITE_BYTE
 LoopWaitForConvertion: 
    call    OW_READ_BYTE 
    clrw
    subwf   value,w
    btfsc   STATUS, 2	    ; if Z flag  = 0; temp == wreg ? 
    goto    LoopWaitForConvertion
 
    call    OW_START
    movlw   0xCC	    ; send skip ROM command
    movwf   value	    
    call    OW_WRITE_BYTE
    movlw   0xBE	    ; send send read command
    movwf   value
    call    OW_WRITE_BYTE    
    call    OW_READ_BYTE    ; LSB value of the temperature
    movf    value, w
    movwf   tempL
    call    OW_READ_BYTE    ; MSB value of the temperature
    movf    value, w
    movwf   tempH    
    

MainLoopEnd: 
    
    bsf	    GPIO,1
    DELAY_500us
    goto    MainLoop    
    
; ******************************
; START COMMUNICATION      
; Initiates the 1-wire device communication  
; GP0 is the pin connected to the device    
OW_START: 

    clrf    value
    SET_PIN_OUT		; Reset
    DELAY_500us
    SET_PIN_IN
    DELAY_100us
    btfss GPIO, 0	; if not 1 (set) no device is present
    retlw   0		
    DELAY_100us    
    retlw   1

    
; ******************************
; Writes a byte    
; Sends a byte to the device
; Parameter: value 
OW_WRITE_BYTE: 
    movlw   8
    movwf   counter
    
OW_WRITE_BIT:
    
     SET_PIN_OUT		; GP0 output setup
     DELAY_2us			
     btfss value, 0		; Check if LSB of value is HIGH or LOW (Assigns valuer LSB to GP0)  
     goto OW_WRITE_BIT_0
     goto OW_WRITE_BIT_1
OW_WRITE_BIT_0:
    bcf GPIO, 0			; Assigns 0 to GP0
    goto  OW_WRITE_BIT_END
OW_WRITE_BIT_1:    
    bsf GPIO, 0			; Assigns 1 to GP0
OW_WRITE_BIT_END:
    DELAY_80us
    
    SET_PIN_IN
    DELAY_2us    

    bcf	    STATUS, 0
    rrf	    value		; Right shift - writes the next bit
    decfsz  counter, f
    goto    OW_WRITE_BIT
    
    retlw   0
    
   

; ******************************
; Reads a byte    
; Receives a byte from the device        
    
OW_READ_BYTE:
    
    movlw   8
    movwf   counter

OW_READ_BIT: 
    
    SET_PIN_OUT
    DELAY_2us
    SET_PIN_IN
    DELAY_2us
    DELAY_2us
    nop
    ; Assigns 1 or 0 depending on the value of the first bit of the GPIO (GP0).
    movlw   1		
    andwf   GPIO, w
    movwf   aux
    movf   value, w
    iorwf  aux, w
    movwf  value    ; The first bit of value now has the value of GP0
    DELAY_100us    
    
    bcf	    STATUS, 0
    rlf	    value
    decfsz  counter, f
    goto    OW_READ_BIT

    retlw   0    
    
    
END MAIN    



