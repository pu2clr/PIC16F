# PIC10F200 and DHT11 example

This project uses a DHT11 sensor to  measure humidity and temperature. This application with the PIC10F100 uses eight LEDs driven by the 74HC595 device to display temperature and humidity. Four LEDs indicate temperature ranges: cold, cool to comfortable, comfortable, and hot. The other four LEDs indicate humidity levels: Low, Moderate, Desirable, and HIGH.  


## Content

1. [Considerations to implement this single-wire protocol ](#considerations-to-implement-this-single-wire-protocol)
2. [Schematic](#pic10f200-and-dht11-schematic)
    * [KiCad schematic](./KiCad/)
3. [PIC10F200 PINOUT](#pic10f200-pinout)    
4. [PIC10F200 with  DHT11 and 74HC595 Assembly code](#pic10f200-with-dht11-and-74hc595-assembly-code)    
5. [MPLAB X IDE project](./MPLAB_EXAMPLE/)    
6. [References](#references)


## Considerations to implement this single-wire protocol 

Developing the 'single-wire' protocol used by the DHT11 device on the PIC10F200 presents a challenge in several aspects:

* The memory limitation for data (only 16 bytes) complicates the development of a more robust implementation.
* The limited stack capacity, which is only capable of two levels, hampers the creation of more rational and readable code.
* Using the internal oscillator may not provide sufficient precision for time counting, which is a relatively critical feature for implementing this protocol.
* The absence of an 'Open-Drain' GPIO pin may require special attention in circuit design for more critical applications.


## PIC10F200 and DHT11 Schematic 


![PIC10F200 and DHT11 Schematic](./schematic_pic10f200_DHT11_74HC595_LEDs.jpg)


## PIC10F200 PINOUT

### SMD (6-PIN SOT-23)

![PIC10F200 SMD PINOUT](./../../../images/pic10f200_smd_pinout.png)

### 8-PIN PDIP

![PIC10F200 DIP PINOUT](../../../images/PIC10F200_PINOUT.jpg)


### 74HC595 PINOUT

![74HC595 PINOUT](./../../../images/74HC595_PINOUT.png)



## PIC10F200 with  DHT11 and 74HC595 Assembly code

**IMPORTANT:** To assemble this code correctly, please follow the steps below:
1. Go to "Project Properties" in MPLAB X.
2. Select "Global Options" for the pic-as assembler/compiler.
3. In the "Additional Options" box, enter the following parameters: **-Wl,-pAsmCode=0h**

![PIC10F200 MPLAB X setup](../../../images/PIC10F200_MPLAB_SETUP.png)


```asm
; Under construction...
; This project uses a DHT11 sensor to  measure humidity and temperature. 
; This application with the PIC10F100 uses eight LEDs driven by the 74HC595 to display 
; temperature and humidity. ; Four LEDs indicate temperature ranges: cold, cool to 
; comfortable, comfortable, and hot. 
; The other four LEDs indicate humidity levels: Low, Moderate, Desirable, and HIGH.    
;    
; The temperature values that define the "COOL", "COOL to COMFORTABLE", "COMFORTABLE", and "HOT" 
; sensations were arbitrarily chosen by the author of this program based on their personal opinion 
; and experience in the coastal city of Fortaleza, CearÃ¡, Brazil. These values may not be suitable 
; for other scenarios. So far, The lowest temperature recorded in the city of Fortaleza was 21Âº Celsius.
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
  

BEGIN_74HC595_TRANS MACRO
   bcf	    GPIO, SR_CLOK
   goto	    $+1
ENDM   
    
END_74HC595_TRANS MACRO
   bsf	    GPIO, SR_CLOK
   goto	    $+1
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

workValue1  equ	0x10    
workValue2  equ 0x11		; Initial value to be sent
oldValue    equ	0x12	 
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
    movwf   workValue1
    call    SendTo74HC595   ; Turn all LEDs on
    call    DELAY_600ms	    ;   
    clrf    workValue1
    call    SendTo74HC595   ; Turn all LEDs off    
MainLoop:		    ; Endless loop
    call    DELAY_600ms	    ; 
    call    DELAY_600ms	    ; 
    call    DELAY_600ms	    ; 
    call    DELAY_600ms	    ; 

    call    DHT11_READ	    ; Checksum: if wreg = 1 then chcksum error
    ; movwf   workValue2
    ; btfsc   workValue2, 0
    ; call    BLINK_LED	    ; Indicate Checksum error
    ; goto    MainLoopEnd	    ; Checksum error: Skip reading / No result to be shown
    ; Avoind LEDs refresh for the same value
    movf    checkSum, w
    subwf   oldValue, w
    btfsc   STATUS, 2	    ; (Z == 1)? - if current value = oldValue dont refresh
    goto    MainLoopEnd
    
    ; Begin check
    ;   DEBUG
    ;   This check shows the temperature or humidity in binary representation via 8 LEDs
    ;    movlw   0B00010001
    ;    ; movf    temperature, w
    ;    movf    humidity, w
    ;    movwf   workValue1
    ;    call    SendTo74HC595   ; shoul show the temperature in binary
    ;    goto    MainLoopEnd
    ; End check

FormatTemp:
    movlw   13
    subwf   temperature, w
    btfsc   STATUS, 0
    goto    CheckTempCoolConfortable
    movlw   0B00010000                  ; COOL
FormatTempFinish:  
    movwf   temperature 
    goto    FormatHumidity
CheckTempCoolConfortable:
    movlw   25
    subwf   temperature, w
    btfsc   STATUS, 0
    goto    CheckTempConfortable
    movlw   0B00110000                  ; COOL to CONFORTABLE
    goto    FormatTempFinish
CheckTempConfortable:                    
    movlw   31
    subwf   temperature, w
    btfsc   STATUS, 0
    goto    CheckTempHot
    movlw   0B01110000                  ; CONFORTABLE
    goto    FormatTempFinish    
CheckTempHot: 
    movlw   0B11110000			        ; HOT
    goto    FormatTempFinish  
FormatHumidity: 
    movlw   30
    subwf   humidity, w
    btfsc   STATUS, 0
    goto    CheckHumidityModerate 
    movlw   0B00000001                  ; Humidity LOW 
FormatHumidityFinish: 
    movwf   humidity 
    goto    ShowTempHumidity
CheckHumidityModerate: 
    movlw   40
    subwf   humidity, w
    btfsc   STATUS, 0
    goto    CheckHumidityDesirable 
    movlw   0B00000011                  ; Humidity Moderate 
    goto    FormatHumidityFinish
CheckHumidityDesirable:
    movlw   60
    subwf   humidity, w
    btfsc   STATUS, 0
    goto    CheckHumidityHigh 
    movlw   0B00000111                  ; Humidity Desirable 
    goto    FormatHumidityFinish
CheckHumidityHigh: 
    movlw   0B00001111                  ; Humidity High 
    goto    FormatHumidityFinish    
ShowTempHumidity:
    movf    temperature, w
    iorwf   humidity, w
    movwf   workValue1
    call    SendTo74HC595  
    
MainLoopEnd:
    call    DELAY_600ms
    call    DELAY_600ms
    call    DELAY_600ms
    call    DELAY_600ms
    goto    MainLoop
    
; ******** DHT11 ****************************************
; Reading 5 bytes and storing the values in: 
; humidity, fracHumid, temperature, fracTemp and checkSum    
DHT11_READ: 

    SET_PIN_OUT
    bcf	    GPIO, DHT_DATA	; DHT_DATA = low
    
    movlw   20			; Wait 20ms 
    call    DELAY_Nx1ms
    
    bsf	    GPIO, DHT_DATA	; DHT_DATA = HIGH
    
    movlw   4   			; Wait 40us
    call    DELAY_Nx10us

    SET_PIN_IN 
    
    ; The DHT11 shoud send a low pulse during 80us
    ; Wait for response from DHT11 
    movlw   13
    movwf   counterM 
DHT11_WAIT_RESPONSE_0:    
    btfsc   GPIO, DHT_DATA	        ; 1 cycle +
    goto    $+2			            ; 2 cycle +
    goto    DHT11_PRESENT	
    goto    $+1	
    decfsz  counterM, f		        ; 1 cycle  +
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
    btfss   GPIO, DHT_DATA	    ; 1 cycle +
    goto    $+2			        ; 2 cycle +
    goto    DHT11_READY_TO_TRANS	
    goto    $+1	
    decfsz  counterM, f		    ; 1 cycle  +
    goto    DHT11_WAIT_RESPONSE_1   ; 2 cycles = 6 cycle (about 6us)
    ; DHT11 ERROR 
    goto    SYSTEM_ERROR
DHT11_READY_TO_TRANS:     

    ; **** CHECK IT ******
    ; Wait for DHT11 makes the bus down
    btfsc   GPIO, DHT_DATA	    
    goto    $-1	
  
    ; Gets 5 bytes from DHT11
    
    call    DHT11_READ_BYTE	; Gets the first byte (humidity)
    movf    workValue1, w
    movwf   humidity
    
    call    DHT11_READ_BYTE	; Gets the secound byte (humidity - decimal part)
    movf    workValue1, w
    movwf   fracHumid
    
    call    DHT11_READ_BYTE	; Gets the third byte (temperature)
    movf    workValue1, w
    movwf   temperature
    
    call    DHT11_READ_BYTE	; Gets the fourth  byte (temperature - decimal part)
    movf    workValue1, w
    movwf   fracTemp
    call    DHT11_READ_BYTE	; Gets the last  byte (Checaluek sum v)
    movf    workValue1, w
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
    
    
    clrf    workValue1
    movlw   8
    movwf   counter1
DHT11_READ_BYTE_LOOP: 
    ; while DHT_DATA == LOW 
    btfss   GPIO, DHT_DATA	; skip next instruction if HIGH 
    goto    $-1
    
    movlw   3			; Delays 30us (did not "call DELAY_Nx10us" due to stack limit)
    NOCALL_DELAYxN10us		
    ; At this point if the signal is high, so the sent value is 1, else, it is 0

    btfss   GPIO, DHT_DATA 
    goto    SET_BIT_0
    goto    SET_BIT_1
 SET_BIT_0:   
    bcf	    STATUS, 0
    rlf	    workValue1
    goto    DHT11_READ_BYTE_CONT
 SET_BIT_1:   
    bsf	    STATUS, 0
    rlf	    workValue1    
DHT11_READ_BYTE_CONT: 
    
    ; if data bus is still HIGH, then wait for it becomes low => while DHT_DATA == HIGH 
    btfsc   GPIO, DHT_DATA	    ; skip next instruction if LOW 
    goto    $-1

    decfsz  counter1, f
    goto    DHT11_READ_BYTE_LOOP    ; Gets the next bit

    retlw   0


    
; **************************************************************    
; Send the content of the workValue1 to the 74HC595 device
; parameter: workValue1 - Value to be sent to the 74HC595 device    
;    
SendTo74HC595: 
    
    BEGIN_74HC595_TRANS
    
    movlw   8
    movwf   counterM
    movf    workValue1, w
PrepereToSend:  
    btfss   workValue1, 0   ; Check if less significant bit is 1
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
    rrf	    workValue1, f
    decfsz counterM, f	    ; Decrement the counter1 and check if it becomes zero.
    goto PrepereToSend	    ; if not, keep prepering to send
    
    END_74HC595_TRANS
   
    retlw   0



; *********** Divide ***************
; Divides workValue1 by workValue2 
; Returns the result in workValue2    
;     
Divideg8: 
    clrf    counter1
Divideg8Loop:    
    movf    workValue2,w 
    subwf   workValue1, f
    btfsc   STATUS, 0
    goto    Divideg8Contine
    goto    Divideg8Finish
Divideg8Contine: 
    movlw   1
    addwf   counter1
    goto    Divideg8Loop
Divideg8Finish:
    movf    counter1, w
    movwf   workValue2
    
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
    movwf   workValue1
    call    SendTo74HC595
    call    DELAY_600ms
    movlw   0B01010101
    movwf   workValue1
    call    SendTo74HC595
    call    DELAY_600ms

    goto    SYSTEM_ERROR


BLINK_LED:
    
    movlw   0B11111111
    movwf   workValue1
    call    SendTo74HC595   ; Turn all LEDs on
    call    DELAY_600ms	    ; 
    clrf    workValue1
    call    SendTo74HC595   ; Turn all LEDs off    
    call    DELAY_600ms	    ; 
    retlw   0
    
    
END MAIN

```


## Contribution

If you've found value in this repository, please consider contributing. Your support will assist me in acquiring new components and equipment, as well as maintaining the essential infrastructure for the development of future projects. [Click here](https://www.paypal.com/donate/?business=LLV4PHKTXC4JW&no_recurring=0&item_name=Your+support+will+assist+me+in++maintaining+the+essential+infrastructure+for+the+development+of+future+projects.+&currency_code=BRL) to make a donation or scan the QR code provided below. 

![Contributing QR Code](./images/PIC_JOURNEY_QR_CODE.png)


## References

* [PIC10F200 Data Sheet](https://ww1.microchip.com/downloads/en/DeviceDoc/40001239F.pdf)
* [DHT11 Humidity & Temperature Sensor](https://www.mouser.com/datasheet/2/758/DHT11-Technical-Data-Sheet-Translated-Version-1143054.pdf)

