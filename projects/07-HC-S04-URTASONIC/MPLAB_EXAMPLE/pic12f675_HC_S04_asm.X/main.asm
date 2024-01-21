; UNDER Construction... 
; My PIC Journey   
; Author: Ricardo Lima Caratti
; Jan/2024
    
#include <xc.inc>

; CONFIG
  CONFIG  FOSC = INTRCIO        ; Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-Up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; GP3/MCLR pin function select (GP3/MCLR pin function is MCLR)
  CONFIG  BOREN = ON            ; Brown-out Detect Enable bit (BOD enabled)
  CONFIG  CP = OFF              ; Code Protection bit (Program Memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled) 
  
; declare your variables here
dummy1	    equ 0x20 
durationL   equ 0x21  
durationH   equ 0x22 
value1L	    equ 0x23		; Used by the subroutine to  
value1H	    equ 0x24		; compare tow 16 bits    
value2L	    equ 0x25		; values.
value2H	    equ 0x26		; They will represent two 16 bits values to be compered (if valor1 is equal, less or greter than valor2)  
   
PSECT resetVector, class=CODE, delta=2
resetVect:
    PAGESEL main
    goto main
PSECT code, delta=2
main:
    ; Analog and Digital pins setup
    bcf	    STATUS, 5		; Selects Bank 0
    clrf    GPIO		; Init GPIO
    clrf    CMCON		; COMPARATOR Register setup
    movlw   0b10001101 	; Right justified; VDD;  01 = Channel 3 (AN3); A/D converter module is 
    movwf   ADCON0		; Enable ADC   
    bsf	    STATUS, 5		; Selects Bank 1
    movlw   0b00010000		; GP4 as input
    movwf   TRISIO		 
    clrf    ANSEL	 	; Digital
    bcf	    STATUS, 5		; Selects bank 0
MainLoopBegin:			; Endless loop
    ; Under construction
    call    ReadHCS04		; returns duration in value1
    movlw   LOW(830)		; Checks if it is <= 830 (it means 10 cm less)  
    movwf   value2L		;
    movlw   HIGH(830)		;
    movwf   value2H
    call    Compare16		; compare value1 with value2
    btfsc   STATUS, 0		; 
    goto    ReallyClose		; indicates really close
    movlw   LOW(2450)		; Checks if it is >= 2450 (it means 30 cm or more)     
    movwf   value2L
    movlw   HIGH(2450)
    movwf   value2H
    btfsc   STATUS, 0
    goto    Distant		; Far away    
    goto    Close		; Not too close and not so far away
    goto    MainLoopEnd    
Close:				; Between 10 and 30 cm
    call YellowOn
    goto MainLoopEnd
ReallyClose:			; Less than 10 cm
    call RedOn
    goto MainLoopEnd
Distant:			; 30 cm or more
    call GreenOn
  
MainLoopEnd:    
    call Delay10us
    call Delay10us
    call Delay10us
    
    goto MainLoopBegin

; ******************************      
; Turn Green LED On
GreenOn:
    call AllOff
    movlw 1	  ; 0B00000001  
    movwf GPIO
    return

; ******************************    
; Turn Yellow LED ON    
YellowOn: 
    call AllOff
    movlw 2	   ; 0B00000010
    movwf GPIO
    return  
    
; ******************************    
RedOn: 
    call AllOff
    movlw 4	   ; 0B00000100
    movwf GPIO
    return        

; ******************************
; Turn all LEDs off
AllOff: 
    clrw 
    movwf GPIO
    return
    
; ******** HC-S04 ************
; Read the HC-S04 - GP1
ReadHCS04: 

    movlw   LOW(1450)		; Check test => returns 830 in value1 
    movwf   value1L
    movlw   HIGH(1450)
    movwf   value1H
    return
    
    bcf	    STATUS, 5		; Selects Bank 0
    clrf    TMR1H		; Reset TMR1
    clrf    TMR1L

    ; Send 10uS signal to the Trigger pin
    bsf     GPIO,5
    call    Delay10us
    bcf	    GPIO,5
    ; Wait for echo
WaitEcho1: 
    btfss   GPIO,4		; Bit Test f, Skip if Set (do while GP4 is 0)
    goto    WaitEcho1
    bsf	    T1CON,0		; Sets TMR1ON -> TMR1ON = 1
WaitEcho2: 
    btfsc   GPIO,4		; Bit Test f, Skip if Clear  (do while GP4 is 1
    goto    WaitEcho2   
    bcf	    T1CON,0		; Clear TMR1ON -> TMR1ON = 0
    ; Now you have the elapsed time stored in TMR1H and TMR1L
    
    return
    
    
;
; At 4 MHz, one instruction takes 1us
; So, this soubroutine shoul take about 10us    
Delay10us:
    nop		; 8 cycle
    nop
    nop
    nop
    nop
    nop
    nop
    nop	    
    return	; 2 cycles


; Signed and unsigned 16 bit comparison routine: by David Cary 2001-03-30 
; This function was extracted from http://www.piclist.com/techref/microchip/compcon.htm#16_bit 
; It was adapted by me to run in a PIC12F675 microcontroller    
; Does not modify value2 or value2.
; After calling this subroutine, you can use the STATUS flags (Z and C) like the 8 bit compares 
; I would like to thank David Cary for sharing it.     
Compare16: ; 7
	; uses a "dummy1" register.
	movf	value2H,w
	xorlw	0x80
	movwf	dummy1
	movf	value1H,w
	xorlw	0x80
	subwf	dummy1,w	; subtract Y-X
	goto	AreTheyEqual
CompareUnsigned16: ; 7
	movf	value1H,w
	subwf	value2H,w ; subtract Y-X
AreTheyEqual:
	; Are they equal ?
	btfss	STATUS, 2
	goto	Results16
	; yes, they are equal -- compare lo
	movf	value1L,w
	subwf	value2L,w	; subtract Y-X
Results16:
	; if X=Y then now Z=1.
	; if Y<X then now C=0.
	; if X<=Y then now C=1.
	return
    
    
END resetVect
