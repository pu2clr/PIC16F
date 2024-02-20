; Under construction...
; This project uses a DHT11 sensor to  measure humidity and temperature. 
; This application with the PIC10F100 uses eight LEDs to display temperature and humidity.
; Four LEDs indicate temperature ranges: cold, cool to comfortable, comfortable, and hot. 
; The other four LEDs indicate humidity levels: Low, Moderate, Desirable, and HIGH.    
;    
; IMPORTANT: To assemble this code correctly, please follow the steps below:
; 1. Go to "Project Properties" in MPLAB X.
; 2. Select "Global Options" for the pic-as assembler/compiler.
; 3. In the "Additional Options" box, enter the following parameters:
; -Wl,-pAsmCode=0h
;
; Please check the AsmCode reference in the "PSECT" directive below.
;
; Author: Ricardo Lima Caratti
; Feb/2024    
    
#include <xc.inc>

; CONFIG
  CONFIG  WDTE = OFF           ; Watchdog Timer (WDT disabled)
  CONFIG  CP = OFF             ; Code Protect (Code protection off)
  CONFIG  MCLRE = ON	       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)


; ******* MACROS **********

#define   SR_DATA	0
#define   SR_CLOK	1
#define   DHT_DATA	2  
  
; Sets all PIC10F200 pins as output 
 SET_PIN_OUT MACRO
    clrw
    tris    GPIO
 ENDM
 
; Sets the PIC10F200 DS18B20_DATA pin as input  
SET_PIN_IN MACRO
    movlw  (0x01 << DHT_DATA)
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
 
NOCALL_DELAYxN10us  MACRO
    ; WREG is the parameter: 5 = 50us; 10 = 100us and so on..
    movwf  counterM
    goto $ + 1		; 2 cycles +
    goto $ + 1		; 2 cycles +
    goto $ + 1		; 2 cycles +
    goto $ + 1		; 2 cycles = 8 cycles +
    decfsz counterM, f	; 1 cycle + 
    goto $ - 5		; 2 cycle = 11 cycles **** Fix it later  
ENDM    
  
; Declare your variables here

aux	    equ	0x10
oldValue    equ	0x11	    
paramValue  equ 0x12		; Initial value to be sent	
srValue	    equ 0x13		; shift register Current value to be sent to 74HC595
counter1    equ 0x14		
counter2    equ 0x15	
counterM    equ 0x16 
temperature equ	0x17
humidity    equ 0x18	
fracTemp    equ	0x19
fracHumid   equ	0x1A
checkSum    equ	0x1B   
	    
	    
 
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
    clrf    oldValue
    ; Just BLINK all LEDs indicating start
    movlw   0B11111111
    movwf   paramValue
    call    SendTo74HC595   ; Turn all LEDs on
    call    DELAY_600ms	    ;   
    clrf    paramValue
    call    SendTo74HC595   ; Turn all LEDs off    
    call    DELAY_600ms	    ; Time to the system become stable
    call    DELAY_600ms	    ; 
    call    DELAY_600ms	    ; 
    call    DELAY_600ms	    ; 
    call    DELAY_600ms	    ; 
MainLoop:		    ; Endless loop
    call    DHT11_READ	    ; Checksum: if wreg = 1 then chcksum error
    movwf   aux
    btfsc   aux, 0
    ; call    BLINK_LED	    ; Indicate Checksum error
    goto    MainLoopEnd	    ; Checksum error: Skip reading / No result to be shown
    ; Avoind LEDs refresh for the same value
    movf    checkSum, w
    subwf   oldValue, w
    btfsc   STATUS, 2	    ; (Z == 1)? - if current value = oldValue dont refresh
    goto    MainLoopEnd
    
    ; Begin check
    movf    temperature, w
    movwf   paramValue
    call    SendTo74HC595   ; shoul show the temperature in bynary
    nop
    nop
    nop
    goto    MainLoopEnd
    ; End check
    
    
    
    
    ; Start preprering data to be shown 	    
    ; 4 LEDs (4 bits) will represent the temperature and 4 LEDs the humidity
    movlw   20
    subwf   humidity	    ; Adjuste the scale (90-20)
    
    ; Adjust temperature and humidity to fit in 4 bits
    
    
    
    movlw   4
    movwf   counter1
AdjustValuesLoop:     
    bcf	    STATUS, 0
    rrf	    temperature	    ; divide temperature by 2 
    bcf	    STATUS, 0
    rrf	    humidity	    ; divide humidity by 2
    decfsz  counter1, f	    ; 1 cycle + 
    goto    AdjustValuesLoop 
    
    movf    temperature, w
    movwf   paramValue
    rlf	    paramValue
    rlf	    paramValue
    rlf	    paramValue
    rlf	    paramValue
    movlw   0B11110000
    andwf   paramValue	    ; the 4 MSB have the temperature		
    movlw   0B00001111
    andwf   humidity, w	    ; the 4 LSB have the humidity
    iorwf   paramValue,f	    ; paramValue has now temperature and humidity
    call    SendTo74HC595   ; 4 MSB => temperature; 4 LSB humidity
MainLoopEnd:
    call DELAY_600ms
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
    
    ; DOCLOCK                 ; ===> CHECK IT!!!!!!!!!
    
    retlw   0
    
  
; ******** DHT11 ****************************************
; Reading 5 bytes and storing the values in: 
; humidity, fracHumid, temperature, fracTemp and checkSum    
; Steps: 
; 1) MCU Sends out Start Signal to DHT  
;    The Data Single-bus operates at a high voltage level under free status conditions (pull up). 
;    When initiating communication between the Microcontroller Unit (MCU) and the DHT11 
;    sensor, the MCU's programming transitions the Data Single-bus's voltage from high to 
;    low. This transition must be maintained for a minimum of 18 milliseconds to guarantee 
;    the DHT11 sensor's successful detection of the MCU's signal. 
;    Following this, the MCU elevates the voltage level and enters a waiting period of 
;    20 to 40 microseconds for the DHT11's response    
DHT11_READ: 

    SET_PIN_OUT
    bcf	    GPIO, DHT_DATA	; DHT_DATA = low
    
    movlw   20			; Wait 20ms 
    call    DELAY_Nx1ms
    
    bsf	    GPIO, DHT_DATA	; DHT_DATA = HIGH
    
    movlw   3			; Wait 30us
    call    DELAY_Nx10us

    SET_PIN_IN 
    
    
    ; The DHT11 shoud send a low pulse during 80us
    ; Wait for response from DHT11 
    movlw   13
    movwf   counterM 
DHT11_WAIT_RESPONSE_0:    
    btfsc   GPIO, DHT_DATA	    ; 1 cycle +
    goto    $+2			    ; 2 cycle +
    goto    DHT11_PRESENT		
    decfsz  counterM, f		    ; 1 cycle  +
    goto    DHT11_WAIT_RESPONSE_0   ; 2 cycles = 6 cycle (about 6us)
    ; DHT11 was not present 
    goto    SYSTEM_ERROR
DHT11_PRESENT:  
    
    ; Wait the DHT11 release the bus
    btfsc   GPIO, DHT_DATA	    
    goto    $-1	
    
    ; The DHT11 shoud send a HIGH pulse during 80us
    ; Wait for response from DHT11 
    movlw   13
    movwf   counterM 
DHT11_WAIT_RESPONSE_1:    
    btfsc   GPIO, DHT_DATA	    ; 1 cycle +
    goto    $+2			    ; 2 cycle +
    goto    DHT11_READY_TO_TRANS		
    decfsz  counterM, f		    ; 1 cycle  +
    goto    DHT11_WAIT_RESPONSE_1	    ; 2 cycles = 6 cycle (about 6us)
    ; DHT11 ERROR 
    goto    SYSTEM_ERROR
DHT11_READY_TO_TRANS:     
    
    
    ; TODO: Gets 5 bytes from DHT11
    
    call    DHT11_READ_BYTE	; Gets the first byte (humidity)
    movf    paramValue, w
    movwf   humidity
    
    call    DHT11_READ_BYTE	; Gets the secound byte (humidity - decimal part)
    movf    paramValue, w
    movwf   fracHumid
    
    call    DHT11_READ_BYTE	; Gets the third byte (temperature)
    movf    paramValue, w
    movwf   temperature
    
    call    DHT11_READ_BYTE	; Gets the fourth  byte (temperature - decimal part)
    movf    paramValue, w
    movwf   fracTemp
    call    DHT11_READ_BYTE	; Gets the last  byte (Checaluek sum v)
    movf    paramValue, w
    movwf   checkSum
    clrw
    addwf   humidity, w
    addwf   fracHumid, w
    addwf   temperature, w
    addwf   fracTemp, w
    subwf   checkSum, w
    btfsc   STATUS, 2		; (Z == 1)? - Is checksum ok? 
    retlw   1			; Checksum is not ok
    retlw   0			; Checksum is ok

; ******* DHT11_READ_BYTE *********************************   
; Reads the next 8 bits (one byte)  from DHT11  
; GPIO  DHT_DATA must bin configured as input    
DHT11_READ_BYTE:
    
    
    clrf    paramValue
    movlw   8
    movwf   counter1
DHT11_READ_BYTE_LOOP: 
    ; while DHT_DATA == LOW 
    btfss   GPIO, DHT_DATA	; skip next instruction if HIGH 
    goto    $-1
    
    movlw   3			; Delays 30us (did not "call DELAY_Nx10us" due to stack limit)
    NOCALL_DELAYxN10us
    
    btfss   GPIO, DHT_DATA 
    goto    SET_BIT_0
    goto    SET_BIT_1
 SET_BIT_0:   
    bcf	    STATUS, 0
    rlf	    paramValue
    goto    DHT11_READ_BYTE_CONT
 SET_BIT_1:   
    bsf	    STATUS, 0
    rlf	    paramValue    
DHT11_READ_BYTE_CONT: 
    
    ; while DHT_DATA == HIGH 
    btfsc   GPIO, DHT_DATA	; skip next instruction if LOW 
    goto    $-1
    
    decfsz  counter1, f
    goto    DHT11_READ_BYTE_LOOP  
 
    ; movlw   2			; When the last bit data is transmitted, DHT11 pulls down the voltage level and keeps it for 50us. 
    ; NOCALL_DELAYxN10us          ; Then the Single-Bus voltage will be pulled up by the resistor to set it back to the free status.
    
    retlw   0
    

; *********** DELAY ************
; Delay function    
; Takes (WREG * 10)us    
; Examples: if WREG=1 => 10us; WREG=7 => 70us; WREG=48 => 480us; and so on     
DELAY_Nx10us:
    movwf  counterM
    nop			; 1 cycle +
    goto $ + 1		; 2 cycles +
    goto $ + 1		; 2 cycles +
    goto $ + 1		; 2 cycles = 7 cycles +
    decfsz counterM, f	; 1 cycle = 8 us 
    goto $ - 5		; 2 cycle = 10 cycles 
    retlw   0
    

; ****************** DELAY_Nx1ms *****************    
; Delays about WREG ms where the WREG is the parameter
; if WREG = 20 => 20us; if WREG = 100 => 100us and so on.      
;     
DELAY_Nx1ms:
    movwf   counter1	    ; wreg is the parameter in ms. 
DELAY_Nx1ms_01:			
    movlw   200		    ; It is about 200 * 5us ( 5 cycles) = 1000us (1ms) 
    movwf   counter2
DELAY_Nx1ms_02:		    ; Delays about 5us        
    goto    $+1		    ; 2 cycles (2us) +
    decfsz  counter2, f	    ; 1 cycle [1]  +   |  1. most of time 1 cycle     
    goto    DELAY_Nx1ms_02  ; 2 cycles (2us) = about 5us
    decfsz  counter1, f
    goto    DELAY_Nx1ms_01
    
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


BLINK_LED:
    
    movlw   0B11111111
    movwf   paramValue
    call    SendTo74HC595   ; Turn all LEDs on
    call    DELAY_600ms	    ; 
    clrf    paramValue
    call    SendTo74HC595   ; Turn all LEDs off    
    call    DELAY_600ms	    ; 
    retlw   0
    
    
END MAIN



