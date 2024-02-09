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

; Delays X us  
; usParam a multiple of 10 value in microseconds
; it must be greater or equal to 10  and multiple of 10. 
DELAY_Xus MACRO usParam
    movlw  (usParam / 10)
    movwf  dummy1
    nop
    goto $ + 1	    ; 2 cycles
    goto $ + 1	    ; 2 cycles
    goto $ + 1	    ; 2 cycles
    goto $ + 1      ; 2 cycles
    decfsz dummy1, f
    goto $ - 6 
ENDM 
  
; Delays 2us
DELAY_2us MACRO
    nop
    nop
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
counter1    equ 0x12
counter2    equ	0x13  
counter3    equ	0x14    
aux	    equ 0x15
tempL	    equ 0x16	; LSB information of the temperature
tempH	    equ 0x17	; MSB information of the temperature    
frac	    equ 0x18	; fraction of the temperature	    
	    
	    
PSECT AsmCode, class=CODE, delta=2

MAIN:

    clrf    GPIO
    clrw    
    tris    GPIO	    ; Sets all GPIO as output

MainLoop:  
    call    OW_START
    subwf   1
    btfsc   STATUS, 2
    goto    SYSTEM_ERROR    ; No DS18B20
   
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
    
    ; The first 4 bits (LSB) represent the fractional part of the temperature. The fraction 
    ; is obtained by dividing this number by 16. Therefore, if the values are, 
    ; for example, 2, 4, 8, or 12, the fractional part of the temperature will be 
    ; respectively 0.125, 0.25, 0.5, and 0.75.
    ; That being said, instead of obtaining the maximum precision (resolution) of the DS18B20,
    ; this program will have a resolution of 0.25 degrees Celsius
    
    call    OW_READ_BYTE    ; LSB value of the temperature
    movf    value, w
    movwf   tempL
    
    andlw   0B00001111	    ; Gets the firs 4 bits to know the fraction of the temperature
    movwf   frac
    ; Shift 4 bits to right the MSB of the tempL   
    rrf	    tempL
    rrf	    tempL
    rrf	    tempL
    rrf	    tempL
    
    movf    tempL, w
    andlw   0B00001111	    ; clear the last 4 bits (4 MSB)
    movwf   tempL
    
    call    OW_READ_BYTE    ; MSB value of the temperature
    movf    value, w
    movwf   tempH
   
    ; Shift to right the MSB of the tempL   
    rlf	    tempH
    rlf	    tempH
    rlf	    tempH
    rlf	    tempH    
    
    movf    tempH, w
    andlw   0B11110000
    iorwf   tempL,w	    ; tempL now has the temperature.
    movwf   tempL
    
    ; Begin Check
    ; movlw   27
    ; movwf   tempL
    ; End Check
    
    ; Process the temperature value (turn on or off the LEDs 
    
    movlw   29
    subwf   tempL
    btfss   STATUS, 0
    goto    TurnLedOff
    goto    TurnLedOn
TurnLedOff:
    bcf	    GPIO,1
    goto    MainLoopEnd
TurnLedOn:
    bsf	    GPIO, 1
MainLoopEnd: 
    movlw   255
    movwf   counter1 
LoopDelay:     
    DELAY_Xus 500
    decfsz  counter1, f
    goto    LoopDelay
    goto    MainLoop    

; ************************ Subroutines ************************************     
    
; *******************************************
; START COMMUNICATION      
; Initiates the 1-wire device communication  
; GP0 is the pin connected to the device    
OW_START: 

    clrf    value
    SET_PIN_OUT		
    bcf	    GPIO,0	; make the GP0 LOW for 480 us
    DELAY_Xus 480
    bsf	    GPIO,0
    DELAY_Xus 70 
    SET_PIN_IN
    DELAY_Xus 10    
    movlw   125		; Waiting for device response by checking GP0 125 times
    movwf   counter1
OW_START_DEVICE_RESPONSE:
    DELAY_Xus 410
    btfsc GPIO, 0	; if not 0,  no device is present so far
    goto  OW_START_NO_DEVICE
    goto  OW_START_DEVICE_FOUND
OW_START_NO_DEVICE:
    decfsz  counter1, f
    goto   OW_START_DEVICE_RESPONSE 
    retlw   0		; Device not found
OW_START_DEVICE_FOUND:    
    retlw   1		; Device found

    
; ******************************
; Writes a byte    
; Sends a byte to the device
; Parameter: value 
OW_WRITE_BYTE: 
    movlw   8
    movwf   counter1
    
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
    DELAY_Xus 80
    
    SET_PIN_IN
    DELAY_2us    

    bcf	    STATUS, 0
    rrf	    value		; Right shift - writes the next bit
    decfsz  counter1, f
    goto    OW_WRITE_BIT
    
    retlw   0
    
   

; ******************************
; Reads a byte    
; Receives a byte from the device        
    
OW_READ_BYTE:
    
    movlw   8
    movwf   counter1

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
    DELAY_Xus 100   
    
    bcf	    STATUS, 0
    rlf	    value
    decfsz  counter1, f
    goto    OW_READ_BIT

    retlw   0    
    
 
DELAY_ERRO:
  
    movlw   255
    movwf   counter1
LOOP_ERROR_01:
    movlw   255
    movwf   counter2
LOOP_ERROR_02: 
    DELAY_Xus 10
    decfsz  counter2, f
    goto    LOOP_ERROR_02
    decfsz  counter1, f
    goto    LOOP_ERROR_01
    
    retlw   0

; Endless loop due to system error (1-wire device not detected) 
SYSTEM_ERROR:
    bsf	    GPIO,1
    call    DELAY_ERRO
    bcf	    GPIO,1
    call    DELAY_ERRO
    goto    SYSTEM_ERROR
    
END MAIN    



