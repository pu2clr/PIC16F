    
#include <xc.inc>

; CONFIG
  CONFIG  WDTE = OFF           ; Watchdog Timer (WDT disabled)
  CONFIG  CP = OFF             ; Code Protect (Code protection off)
  CONFIG  MCLRE = OFF	       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)

  
; ******* MACROS **********
   
DELAY3us MACRO
    goto $+1
    nop
ENDM    
  
; Sets the GP0 as output 
 SET_PIN_OUT MACRO
    clrf    GPIO
    clrw
    tris    GPIO
ENDM
 
; Sets the GP0 as input  
SET_PIN_IN MACRO
    bsf	    GPIO, 0
    movlw   0x01
    tris    GPIO
ENDM
 

; Declare your variables here

value	    equ 0x10
counter1    equ 0x11
counter2    equ 0x12    
counterM    equ 0x13
	    
PSECT AsmCode, class=CODE, delta=2

MAIN:

    clrf    GPIO
    clrw    
    tris    GPIO	    ; Sets all GPIO as output

    
MainLoop: 
   
    
    movlw   0B11111100;
    movwf   value
    call    OW_WRITE_BYTE
    
      
    ; bsf	    GPIO,   0
    ; DELAY3us
    ; bcf	    GPIO,   0
    ; DELAY3us
    

    
    
    goto    MainLoop    

 
; Delay function    
; Takes (WREG * 10)us    
; Examples: if WREG=1 => 10us; WREG=7 => 70us; WREG=48 => 480us; and so on     
DELAY_Nx10us:
    movwf  counterM
    goto $ + 1		; 2 cycles +
    goto $ + 1		; 2 cycles +
    goto $ + 1		; 2 cycles +
    goto $ + 1		; 2 cycles = 8 cycles +
    decfsz counterM, f	; 1 cycle + 
    goto $ - 5		; 2 cycle = 11 cycles **** Fix it later
    retlw   0
    

    
    
; ******************************
; Writes a byte    
; Sends a byte to the device
; Parameter: value 
OW_WRITE_BYTE: 
    movlw   8
    movwf   counter1
OW_WRITE_BIT: 	
    btfss   value, 0		; Check if LSB of value is HIGH or LOW (Assigns valuer LSB to GP0)  
    goto    OW_WRITE_BIT_0
    goto    OW_WRITE_BIT_1
OW_WRITE_BIT_0:
    bcf	    GPIO, 0		; turn bus low for
    movlw   7
    call    DELAY_Nx10us
    goto    OW_WRITE_BIT_END
OW_WRITE_BIT_1: 
    bsf	    GPIO, 0
    goto $+1
    goto $+1
    goto $+1
OW_WRITE_BIT_END:
    bcf	    GPIO, 0
    bcf	    STATUS, 0
    rrf	    value		; Right shift - writes the next bit
    decfsz  counter1, f
    goto    OW_WRITE_BIT
    
    retlw   0
        
    
; ***********************    
; It takes about 600ms 
DELAY_600ms:
  
    movlw   255
    movwf   counter1
DELAY_LOOP_01:
    movlw   255
    movwf   counter2
DELAY_LOOP_02: 
    goto $+1
    goto $+1
    goto $+1
    goto $+1
    decfsz  counter2, f
    goto    DELAY_LOOP_02
    decfsz  counter1, f
    goto    DELAY_LOOP_01
    
    retlw   0
    
END MAIN    






