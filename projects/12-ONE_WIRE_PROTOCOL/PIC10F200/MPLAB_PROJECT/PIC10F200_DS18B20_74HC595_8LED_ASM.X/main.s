; UNDER CONSTRUCTION...  
; This project uses a DS18B20 sensor, a PIC10F200 microcontroller, and a 74HC595 
; shift register to control 8 LEDs that indicate the ambient temperature based on
; the table below:
;    
; | Discomfort level | Celsius degree  |
; | ---------------- | --------------- |    
; |      COLD	     | less than  17   | 
; |    MODERATE      | >= 17 and <= 30 |  
; |       HOT        | greater than 30 |    
; 
; The eight LEDs utilized in this setup are organized into four pairs, each 
; representing different temperature perceptions: Blue for cold, Green for 
; comfortable, Yellow for mildly comfortable, and Red for hot. These LEDs will
; activate based on the ambient temperature, without taking into account humidity 
; or other factors that may affect thermal sensation.    
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


; ******* MACROS **********

#define   SR_DATA	0
#define   SR_CLOK	1
#define   DS18B20_DATA	2  
  
; Sets all PIC10F200 pins as output 
 SET_PIN_OUT MACRO
    clrw
    tris    GPIO
 ENDM
 
; Sets the PIC10F200 DS18B20_DATA pin as input  
SET_PIN_IN MACRO
    movlw  (0x01 << DS18B20_DATA)
    tris    GPIO
ENDM  
  

DOCLOCK MACRO
  bsf	    GPIO, SR_CLOK 	    
  goto	    $+1
  goto	    $+1
  bcf	    GPIO, SR_CLOK	    
  goto	    $+1
  goto	    $+1
ENDM  
  
; Declare your variables here

aux	    equ	0x10
oldTemp	    equ	0x11	    
paramValue  equ 0x12		; Initial value to be sent	
srValue	    equ 0x13		; shift register Current value to be sent to 74HC595
counter1    equ 0x14		
counter2    equ 0x15	
counterM    equ 0x16 
tempL	    equ	0x17
tempH	    equ 0x18	
frac	    equ	0x19	    
	    
	    
 
PSECT AsmCode, class=CODE, delta=2

MAIN:   
    
    ; Wake-up on Pin Change bit  disabled
    ; Weak Pull-ups bit (GP0, GP1, GP3) diabled
    movlw   0B11000000 
    OPTION    
    ; 74HC595 and PIC10F200 GPIO SETUP 
    ; GP0 -> Data   (SR_DATA)	    -> 74HC595 PIN 14 (SER); 
    ; GP1 -> Clock  (SR_CLOCK)	    -> 74HC595 PINs 11 and 12 (SRCLR and RCLK);
    ; DS18B20 and PIC10F200 GPIO setup
    ; GP2 -> DS18B20_DATA
    movlw   0B00000000	    ; All GPIO Pins as output		
    tris    GPIO  
    clrf    oldTemp
MainLoop:		    ; Endless loop
    ; SendS skip ROM command
    call    OW_START
    movlw   0xCC	    
    movwf   paramValue	    
    call    OW_WRITE_BYTE
    ; Sends start conversion command
    ; The default resolution at power-up is 12-bit. 
    movlw   0x44	    
    movwf   paramValue
    call    OW_WRITE_BYTE
    clrf    paramValue
WaitForConvertion: 
    call    OW_READ_BYTE
    clrw    
    subwf   paramValue, w
    btfsc   STATUS, 2		; Skip if value - wreg = 0
    goto    WaitForConvertion	; else goto WaitForConvertion
    goto    $+1
    goto    $+1
    goto    $+1    
    ; Start reading the temperature from the DS18B20
    call    OW_START
    movlw   0xCC	    ; Sends skip ROM command
    movwf   paramValue	    
    call    OW_WRITE_BYTE
    movlw   0xBE	    ; Sends read command
    movwf   paramValue
    call    OW_WRITE_BYTE

    call    OW_READ_BYTE    ; LSB value of the temperature
    movf    paramValue, w
    movwf   tempL
 
    call    OW_READ_BYTE    ; MSB value of the temperature
    movf    paramValue, w
    movwf   tempH

    call    OW_START	    ; STOP reading 
  
    btfss   tempH, 7	    ; Check if MSB  is 1
    goto    AboveZero	    ; Above Zero
    clrf    tempL	    ; Below Zero - Will show COLD
    clrf    tempH
AboveZero: 
    movf    tempL,w
    andlw   0B00001111	    ; Gets the firs 4 bits to know the fraction of the temperature
    movwf   frac	    ; if frac >= 8 then set it to 1 else set it to 0
    ; Round off if the fractional part is greater than or equal to 8 (0.5).
    movlw   8
    subwf   frac
    btfss   STATUS, 0
    goto    SetFracToZero
    goto    SetFracToOne
SetFracToZero:
    clrf    frac
    goto    CalcTemp
SetFracToOne:
    movlw   1
    movwf   frac
   
CalcTemp: 
    
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
    
    ; Round off the fractional part to final tempL value (add 0 or 1)
    movf    frac, w
    addwf   tempL   	    
    ; tempL now has the temperature to be shown
    ; COLD....: < 17 
    ; MODERATE: >= 17 and <= 30  
    ; HOT.....: > 30
    movlw   17			; 30 - 13
    subwf   tempL
    
    movf    tempL, w
    
    ; TODO: Avoind LEDs refresh for the same value
    subwf   oldTemp, w
    btfss   STATUS, 2		; (Z == 1)? - if current value = oldValue dont refresh
    goto    MainLoopEnd
    movf    tempL, w
    movwf   oldTemp		; save the new temperature value
    movwf   aux
    bcf	    STATUS, 0
    rrf	    aux			; aux / 2 => number of LEDs to be lit (from LSB to MSB)
    movf    aux, w
    movwf   counter1		; number o bits to shif to left
    clrf    aux 
    clrf    paramValue
    call    SendTo74HC595
ShowTemp:    
    bsf	    STATUS, 0		; Sets carry flag 1
    rlf	    aux			; Rotate bit to left
    movf    aux,w
    movwf   paramValue		; Value to be sent to the 74HC595
    call    SendTo74HC595 
    decfsz  counter1, f
    goto    ShowTemp
MainLoopEnd:
    call DELAY_600ms
    goto    MainLoop

    
; *********************************************************    
; Send the content of the paramValue to the 74HC595 device
; parameter: paramValue - Value to be sent to the 74HC595 device    
;    
SendTo74HC595: 
    movlw   8
    movwf   counterM
    movf    paramValue, w
PrepereToSend:  
    btfss   paramValue, 0  ; Check if less significant bit is 1
    goto    Send0	    ; if 0 turn GP0 low	
    goto    Send1	    ; if 1 turn GP0 high
Send0:
    bcf	    GPIO, SR_DATA	    ; turn the current 74HC595 pin off 
    goto    NextBit
Send1:     
    bsf	    GPIO, SR_DATA	    ; turn the current 74HC595 pin on
NextBit:    
    ; Clock 
    DOCLOCK
    ; Shift all bits of the srValue to the right and prepend a 0 to the most significant bit
    bcf	    STATUS, 0	    ; Clear cary flag before rotating 
    rrf	    paramValue, f
    decfsz counterM, f	    ; Decrement the counter1 and check if it becomes zero.
    goto PrepereToSend	    ; if not, keep prepering to send
    ; The data has been queued and can now be sent to the 74HC595 port
    DOCLOCK 
    
    retlw   0
    
  
; ******** DS18B20 **************************
    
; *******************************************
; START COMMUNICATION      
; Initiates the 1-wire device communication  
; GP0 is the pin connected to the device    
OW_START: 

    clrf    paramValue
    SET_PIN_OUT		
    bcf	    GPIO, DS18B20_DATA		; make the DS18B20_DATA LOW for 480 us
    movlw   48
    call DELAY_Nx10us 
    bsf	    GPIO, DS18B20_DATA
    
    movlw   7			; 70us
    call DELAY_Nx10us 
    
    SET_PIN_IN
    
    movlw   1			; 10us
    call DELAY_Nx10us
    
    movlw   125			; Waiting for device response by checking 125 times if GP0 is low
    movwf   counter1
OW_START_DEVICE_RESPONSE:
    btfsc   GPIO, DS18B20_DATA		; if not 0,  no device is present so far
    goto    OW_START_NO_DEVICE
    goto    OW_START_DEVICE_FOUND
OW_START_NO_DEVICE:
    decfsz  counter1, f
    goto    OW_START_DEVICE_RESPONSE	; check once again 
    goto    SYSTEM_ERROR		; Device not found - Exit/Halt
    retlw   0			
OW_START_DEVICE_FOUND:  
    movlw   60
    call    DELAY_Nx10us
    retlw   1			; Device found

    
; ******************************
; Writes a byte    
; Sends a byte to the device
; Parameter: value (byte value to be send)
OW_WRITE_BYTE: 
    movlw   8
    movwf   counter1
OW_WRITE_BIT: 	
    btfss   paramValue, 0		; Check if LSB of value is HIGH or LOW (Assigns valuer LSB to GP0)  
    goto    OW_WRITE_BIT_0
    goto    OW_WRITE_BIT_1
OW_WRITE_BIT_0:
    bcf	    GPIO, DS18B20_DATA
    SET_PIN_OUT			; GP0 output setup
    goto    $+1			; Wait for a bit time
    nop
    bcf	    GPIO, DS18B20_DATA
    movlw   8			; 80us
    call    DELAY_Nx10us 
    SET_PIN_IN
    goto $+1
    nop
    goto    OW_WRITE_BIT_END
OW_WRITE_BIT_1: 
    bcf	    GPIO, DS18B20_DATA	; turn bus low for
    SET_PIN_OUT			; GP0 output setup
    goto    $+1
    nop
    bsf	    GPIO, DS18B20_DATA
    movlw   8			; 80us
    call    DELAY_Nx10us 	
    SET_PIN_IN
    goto $+1
    nop    
OW_WRITE_BIT_END:
    bcf	    STATUS, 0
    rrf	    paramValue		; Right shift - writes the next bit
    decfsz  counter1, f
    goto    OW_WRITE_BIT
        
    retlw   0
    
   

; ******************************
; Reads a byte    
; Receives a byte from the device        
    
OW_READ_BYTE:
    
    clrf    paramValue
    movlw   8
    movwf   counter1

OW_READ_BIT:  
    bcf	    GPIO, DS18B20_DATA
    SET_PIN_OUT
    goto    $+1	    ; Wait for 2us or a bit more
    nop
    SET_PIN_IN
    goto $+1
    goto $+1
    goto $+1
    nop

    ; Assigns 1 or 0 depending on the value of the first bit of the GPIO (GP0).
    btfss   GPIO, DS18B20_DATA		 
    goto    OW_READ_BIT_0
    goto    OW_READ_BIT_1
OW_READ_BIT_0:
    bcf	    STATUS, 0
    rrf	    paramValue
    goto    OW_READ_BIT_NEXT
OW_READ_BIT_1:
    bsf	    STATUS, 0
    rrf	    paramValue
OW_READ_BIT_NEXT:  
    movlw   9		    ; 
    call    DELAY_Nx10us    ; 
    decfsz  counter1, f
    goto    OW_READ_BIT
    nop  
    retlw   0    


; *********** DELAY ************
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
    movlw   0B10101010
    movwf   paramValue
    call    SendTo74HC595
    call    DELAY_600ms
    movlw   0B01010101
    movwf   paramValue
    call    SendTo74HC595
    call    DELAY_600ms

    goto    SYSTEM_ERROR

    

    
END MAIN
