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
; About this implementation: 
; The PIC10F200 does not support the Open-Drain Output feature. 
; Therefore, this application may not function correctly in certain scenarios.
; Given this, carefully review your implementation before deploying it in 
; critical applications.     
;    
; You will find good tips about the PIC10F200 here:
; https://www.circuitbread.com/tutorials/christmas-lights-special-microcontroller-basics-pic10f200

     
#include <xc.inc>

; CONFIG
  CONFIG  WDTE = OFF           ; Watchdog Timer (WDT disabled)
  CONFIG  CP = OFF             ; Code Protect (Code protection off)
  CONFIG  MCLRE = ON	       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)

  
; ******* MACROS **********

  
; Delays about 2us
DELAY_2us MACRO
    goto $+1
    nop
ENDM 

; Delays 6us
DELAY_6us MACRO
    goto $ + 1	; 2 cycles
    goto $ + 1	; 2 cycles
    goto $ + 1	; 2 cycles
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

value	    equ 0x11 
counter1    equ 0x12
counter2    equ	0x13  
counterM    equ	0x14    
aux	    equ 0x15
tempL	    equ 0x16	; LSB information of the temperature
tempH	    equ 0x17	; MSB information of the temperature    
frac	    equ 0x18	; fraction of the temperature		    
	    
	    
PSECT AsmCode, class=CODE, delta=2

MAIN:

    clrf    GPIO
    clrw    
    tris    GPIO	    ; Sets all GPIO as output

    bsf	    GPIO,1
    call    DELAY_600ms
    bcf	    GPIO,1
MainLoop:  
    ; SendS skip ROM command
    call    OW_START
    movlw   0xCC	    
    movwf   value	    
    call    OW_WRITE_BYTE
    ; SendS start conversion command
    ; The default resolution at power-up is 12-bit. 
    movlw   0x44	    
    movwf   value
    call    OW_WRITE_BYTE
    
    clrf    value
    ; Wait for Convertion 
WaitConvertion:	    ; do while value is 0
    call    OW_READ_BYTE    ; begin 
    clrw
    subwf   value,w
    btfsc   STATUS, 2	    ; if Z flag  = 0; temp == wreg ? 
    goto    WaitConvertion  ; end do
 
    call    BLINK_LED
    
    call    OW_START
    movlw   0xCC	    ; Sends skip ROM command
    movwf   value	    
    call    OW_WRITE_BYTE
    movlw   0xBE	    ; Sends read command
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
 
    call    OW_READ_BYTE    ; MSB value of the temperature
    movf    value, w
    movwf   tempH
    
    
    movf    tempL,w
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
    

   
    ; Shift to right the MSB of the tempH   
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
    
    movlw   26
    subwf   tempL
    btfss   STATUS, 0
    goto    TurnLedOn
    goto    TurnLedOff

TurnLedOff:
    bcf	    GPIO,1
    goto    MainLoopEnd
TurnLedOn:
    bsf	    GPIO, 1
MainLoopEnd: 
    call    DELAY_600ms
    goto    MainLoop    

; ************************ Subroutines ************************************     
    
; *******************************************
; START COMMUNICATION      
; Initiates the 1-wire device communication  
; GP0 is the pin connected to the device    
OW_START: 

    clrf    value
    SET_PIN_OUT		
    bcf	    GPIO,0		; make the GP0 LOW for 480 us
    movlw   48
    call DELAY_Nx10us 
    bsf	    GPIO,0
    
    movlw   7			; 70us
    call DELAY_Nx10us 
    
    SET_PIN_IN
    
    movlw   1			; 10us
    call DELAY_Nx10us
    
    movlw   125			; Waiting for device response by checking 125 times if GP0 is low
    movwf   counter1
OW_START_DEVICE_RESPONSE:
    btfsc GPIO, 0		; if not 0,  no device is present so far
    goto  OW_START_NO_DEVICE
    goto  OW_START_DEVICE_FOUND
OW_START_NO_DEVICE:
    decfsz  counter1, f
    goto   OW_START_DEVICE_RESPONSE ; check once again 
    goto   SYSTEM_ERROR		; Device not found - Exit/Halt
    retlw   0			
OW_START_DEVICE_FOUND:    
    retlw   1			; Device found

    
; ******************************
; Writes a byte    
; Sends a byte to the device
; Parameter: value 
OW_WRITE_BYTE: 
    movlw   8
    movwf   counter1
OW_WRITE_BIT: 	
     btfss value, 0		; Check if LSB of value is HIGH or LOW (Assigns valuer LSB to GP0)  
     goto OW_WRITE_BIT_0
     goto OW_WRITE_BIT_1
OW_WRITE_BIT_0:
    SET_PIN_OUT			; GP0 output setup
    bcf GPIO, 0			; turn bus low for
    movlw   9			; 90us
    call DELAY_Nx10us 	
    bsf GPIO, 0			; turn bus high for 
    movlw   1			; 10us
    call DELAY_Nx10us		
    goto  OW_WRITE_BIT_END
OW_WRITE_BIT_1:    
    SET_PIN_OUT			; GP0 output setup
    bcf GPIO, 0			; turn bus low for
    goto $+1			; 4us
    goto $+1			; 
    bsf	GPIO, 0			; turn bus high
    movlw   9			; wait for 90 us
    call DELAY_Nx10us
OW_WRITE_BIT_END:
    
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
    bcf	GPIO,0
    goto $+1	    ; Wait for 3us or a bit more
    nop
    SET_PIN_IN
    goto $+1	    ; wait for 3us or a bit more
    nop		    ; 
    ; Assigns 1 or 0 depending on the value of the first bit of the GPIO (GP0).
    movlw   1		
    andwf   GPIO, w
    movwf   aux
    movf   value, w
    iorwf  aux, w
    movwf  value    ; The first bit of value now has the value of GP0
    movlw   9	    ; 90us
    call DELAY_Nx10us ; 
  
    decfsz  counter1, f
    goto    OW_READ_BIT_NEXT
    goto    OW_READ_BIT_END
OW_READ_BIT_NEXT: 
    bcf	    STATUS, 0
    rlf	    value
    goto    OW_READ_BIT
OW_READ_BIT_END:
    nop   
    retlw   0    


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
    goto $ - 5		; 2 cycle = 11 cycles
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

; Endless loop due to system error (1-wire device not detected) 
SYSTEM_ERROR:
    bsf	    GPIO,1
    call    DELAY_600ms
    call    DELAY_600ms
    call    DELAY_600ms
    call    DELAY_600ms
   
    bcf	    GPIO,1
    call    DELAY_600ms

    goto    SYSTEM_ERROR

BLINK_LED:
    movlw   5
    movwf   counterM
BLINK_LED_LOOP:    
    bsf	    GPIO,1
    call    DELAY_600ms
    bcf	    GPIO,1
    call    DELAY_600ms
    decfsz  counterM, f
    goto    BLINK_LED_LOOP  
    retlw   0
    
END MAIN    



