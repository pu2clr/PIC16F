; UNDER CONSTRUCTION...
; IMPORTANT: If you are using the PIC10F200, to assemble this code correctly, please follow the steps below:
; 1. Go to "Project Properties" in MPLAB X.
; 2. Select "Global Options" for the pic-as assembler/compiler.
; 3. In the "Additional Options" box, enter the following parameters:
; -Wl,-pAsmCode=0h
    
#include <xc.inc>

#define KEY_ON_CMD	0B11100000
#define KEY_ON_ADDR	0B10111111	    
    
    
; CONFIG
  CONFIG  WDTE = OFF           ; Watchdog Timer (WDT disabled)
  CONFIG  CP = OFF             ; Code Protect (Code protection off)
  CONFIG  MCLRE = OFF	        

; pulses a signal during about 9ms    
sendPulse9ms MACRO
    bsf		GPIO, 0		; Make the GP0 high
    movlw	36		; takes 9ms
    call	delayWx250us    
    bcf		GPIO, 0		; Make the GP0 low
ENDM

; pulses a signal during about 560us
sendPulse560us MACRO
    bsf		GPIO, 0		; Make the GP0 high
    movlw	2		; delays 500us
    call	delayWx250us
    movlw	6		; delays 60us
    call	delayWx10us    
    bcf		GPIO, 0		; Make the GP0 low    
ENDM 
    
; delays about 4.5ms    
delay4dot5ms MACRO
    movlw	18		
    call	delayWx250us  
ENDM

; delays about 560us    
delay560us MACRO
    movlw	2
    call	delayWx250us
    movlw	6
    call	delayWx10us
ENDM 
       
  
; Declare your variables here
; irData is an array and stores the 32 bits data to be sent
irData		equ	    0x10    ; irData[0]
irData1		equ	    0x11    ; irData[1]
irData2		equ	    0x12    ; irData[2]
irData3		equ	    0x13    ; irData[3]
dummy		equ	    0x14	    
clockI		equ	    0x15
clockJ		equ	    0x16
counterBit	equ	    0x17
counterByte	equ	    0x18  
 
PSECT AsmCode, class=CODE, delta=2

MAIN:
    ; GPIO and registers setup
    clrf   GPIO		    ; Sets all GPIO pins as output
    clrw
    TRIS   GPIO
    
MainLoop:		    ; Endless loop
 
    ; In NEC protocol,  the Address and Command are transmitted twice.
    ; The second time all bits are inverted and can be used for verification of the received message (redundancy)
    ; LSB is transmitted first.
    movlw   KEY_ON_ADDR	    ; Address 
    movwf   irData
    comf    irData, w	    ; ~Adress (Address inverted bits)   
    movwf   irData1	     
    movlw   KEY_ON_CMD	    ; Command
    movwf   irData2
    movwf   irData3	
    call    sendNEC32
 
    movlw   255
    call    delayWx250us
    
    goto    MainLoop
    

; Send the 32 bits (4 bytes array) data (irData)    
sendNEC32: 
    sendPulse9ms	    ; pulse during 9ms
    delay4dot5ms	    ; delays 4.5ms
    
    movlw	4	    ; index for irData[]	
    movwf	counterByte
    ; gets the point to irData array
    movlw	irData	
    movwf	FSR	
sendNEC32NextByte: 
    movlw	8
    movwf	counterBit
sendNEC32NextBit:    
    btfss	INDF, 0
    goto	sendZero
sendOne: 
    ; sends 1
    sendPulse560us		    ; send pulse during 560us
    movlw	6		    ; delay 1690us		    
    call	delayWx250us	    ; delays about 1500us
    movlw	16
    call	delayWx10us	    ; delays about 160us
    goto	sendNEC32Continue  
sendZero:  
    ; sends 0
    sendPulse560us    
    delay560us   
sendNEC32Continue:
    rrf		INDF 
    decfsz	counterBit, f
    goto	sendNEC32NextBit 
    incf	FSR 
    decfsz	counterByte
    goto	sendNEC32NextByte
    
    ; Final pulse to end
    sendPulse560us    
    delay560us  
    
    retlw   0

;
; Delay about WREG x 250us  
; Parameter: W register    
delayWx250us: 
    movwf   clockI    
    movlw   85
    movwf   clockJ
    decfsz  clockJ, f	; 1 cucle
    goto    $-1		; 2 cycles = 2us
    decfsz  clockI, f
    goto    $-5		; while clockI > 0 do
    retlw   0

;
; Delay about WREG x 10us  
; Parameter: W register       
delayWx10us:
    movwf   clockJ
    goto    $+1		; 2 cycles +    
    goto    $+1		; 2 cycles +
    goto    $+1		; 2 cycles +
    nop
    decfsz  clockJ, f	; 1 cycle  + 
    goto    $-5		; 2 cycles 
    retlw   0		; 
    
END MAIN



