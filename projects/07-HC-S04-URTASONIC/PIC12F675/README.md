# PIC12F675 HC-S04 Version

The experiment below uses the PIC12F675 and the HC-S04 ultrasonic distance sensor utilizing three LEDs (Red, Yellow, and Green) to indicate, respectively, a distance of less than 10 cm, between 10 and 30 cm, and more than 30 cm.  In this case, there is no requirement to compute the exact distance to determine if it falls within specific ranges, such as being greater than 10, less than 30, or exceeding these values. Instead, you simply need to measure and compare the elapsed time corresponding to each of these distance thresholds.


## Content

1. [PIC12F675 and HC-S04 schematic](#pic12f675-and-hc-s04-schematic)
    * [KiCad schematic](./KiCad/)
2. [PIC12F675 pinout](#pic12f675-pinout)
3. [PIC12F675 and HC-S04 source code in C](#pic12f675-and-hc-s04-source-code-in-c)
4. [PIC12F675 and HC-S04 Assembly version](#pic12f675-and-hc-s04-assembly-version)
5. [PIC12F675 and HC-S04 prototype](#pic12f675-and-hc-s04-prototype)
5. [MPLAB X IDE projects](./MPLAB_EXAMPLE/)
6. [References](#references)


## PIC12F675 and HC-S04 schematic


![PIC12F675 and HC-S04 schematic](./schematic_pic12F765_HC_S04_led.jpg)



## PIC12F675 pinout


![PIC12F675 pinout](../../../images/PIC12F675_PINOUT.png)



### PIC12F675 and HC-S04 source code in C

```cpp
/*
 * Distance Sensor with PIC12F675 and HC-S04
 * Author: Ricardo Lima Caratti
 * Jan/2024
 */

#pragma config FOSC = INTRCIO   // Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = OFF      // Power-Up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = ON       // GP3/MCLR pin function select (GP3/MCLR pin function is MCLR)
#pragma config BOREN = ON       // Brown-out Detect Enable bit (BOD enabled)
#pragma config CP = OFF         // Code Protection bit (Program Memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)

// 4Mhz internal oscillator
#define _XTAL_FREQ 4000000
#include <xc.h>


/**
 * Turns Green LED On
 */
void inline GreenOn() {
    GPIO =  1;
}

/**
 * Turns Yellow LED On
 */
void inline YellowOn() {
    GPIO =  2;
}

/**
 * Turns Red LED On
 */
void inline RedOn() {
    GPIO =  4;
}


void main(void)
{   
    TRISIO = 0;        // Trigger (GP5), and GP0, GP1 and GP2 (LEDs) are output   
    TRISIO4 = 1;       // Echo
    ANSEL = 0;         // Digital input setup          
    
    while (1)
    {
        TMR1H = 0;      // Reset TMR1
        TMR1L = 0;

        GP5 = 1;        // Send 10uS signal to the Trigger pin
        __delay_us(10);
        GP5 = 0;

        while (!GP4);   // Wait for echo
        TMR1ON = 1;
        while (GP4);
        TMR1ON = 0;    
        // Now you have the elapsed time stored in TMR1H and TMR1L
        unsigned int duration = (unsigned int) (TMR1H << 8) | TMR1L;
        if ( duration < 830)        // this time is equivalent to 10 cm
            RedOn();
        else if (duration <= 2450 ) // this time is equivalent to 30 cm 
            YellowOn();
        else
            GreenOn();
        __delay_ms(100); 
    }

}

```


### PIC12F675 and HC-S04 Assembly version

```asm
; Distance Sensor with PIC12F675 and HC-S04.  
; This experiment uses the PIC12F675 and the HC-S04 ultrasonic distance sensor. 
; It utilizes three LEDs (Red, Yellow, and Green) to indicate, respectively, a distance 
; of less than 10 cm, between 10 and 30 cm, and more than 30 cm. 
; In this case, there is no requirement to compute the exact current distance 
; to determine if it falls within specific ranges, such as being greater than 10, 
; less than 30, or exceeding these values. Instead, you simply need to measure and 
; compare the elapsed time corresponding to each of these distance thresholds.
;    
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
    btfsc   STATUS, 0		; It is <= 830? So the object is very close ( <= 10 cm)
    goto    ReallyClose		; indicates really close
    movlw   LOW(2450)		; Checks if it is >= 2450 (it means 30 cm or more)     
    movwf   value2L
    movlw   HIGH(2450)
    movwf   value2H
    call    Compare16		; compare value1 with value2 
    btfsc   STATUS, 0		; Is it <= 2450?  (<= 30 cm)
    goto    Close		; Not too close and not so far away
    goto    Distant		; Far away       
            
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
    call Delay2ms
    
    goto MainLoopBegin

; ******************************      
; Turn Green LED On
GreenOn:
    call AllOff
    bsf	 GPIO,0
    return

; ******************************    
; Turn Yellow LED ON    
YellowOn: 
    call AllOff
    bsf  GPIO,1
    return  
    
; ******************************    
RedOn: 
    call AllOff
    bsf	  GPIO,2  
    return        

; ******************************
; Turn all LEDs off
AllOff: 
    clrw 
    bcf  GPIO,0
    bcf  GPIO,1
    bcf	 GPIO,2
    return
    
; ******** HC-S04 ****************
; Read and process the HC-S04 data
; There is no requirement to compute the exact distance to determine if it falls within specific ranges, 
; such as being greater than 10, less than 30, or exceeding these values. Instead, you simply need to 
; measure and compare the elapsed time corresponding to each of these distance thresholds.
; Thus, an elapsed time of 830 µs means that the distance traveled was approximately 10 cm (you may need calibrate it).   
; An elapsed time of 2450 µs means that the distance traveled was approximately 30 cm (you may need calibrate it).
ReadHCS04: 
    
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
    
    movf  TMR1L, w
    movwf value1L
    movf  TMR1H, w
    movwf value1H  
    
    return

; ************************* Compare function ***********************************    
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
    
;************** Delay functions *************      
; At 4 MHz, one instruction takes 1µs
; So, this soubroutine should take about 10µs 
; This time is used by the HC-S04 ultrasonic sensor 
; to determine the distance. 	
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

;
; It takes about 2ms
Delay2ms: 
    movlw  200
    movwf  dummy1
LoopDelay2ms: 
    call Delay10us 
    decfsz dummy1, f
    goto LoopDelay2ms
    return
        
END resetVect

```


### PIC12F675 and HC-S04 prototype 

![PIC12F675 and HC-S04 prototype](./prototype_pic12f675_hc_s04.jpg)


## Contribution

If you've found value in this repository, please consider contributing. Your support will assist me in acquiring new components and equipment, as well as maintaining the essential infrastructure for the development of future projects. [Click here](https://www.paypal.com/donate/?business=LLV4PHKTXC4JW&no_recurring=0&item_name=Your+support+will+assist+me+in++maintaining+the+essential+infrastructure+for+the+development+of+future+projects.+&currency_code=BRL) to make a donation or scan the QR code provided below. 

![Contributing QR Code](../../../images/PIC_JOURNEY_QR_CODE.png)


## References

* [Ultrasonic sensor with Microchip's PIC - Part 14 Microcontroller Basics (PIC10F200)](https://youtu.be/_k5f_zpP2lg?si=B3KbHLU_tqzUIZ7E)
* [Ultrasonic Sensor HC-SR04 With PIC Microcontroller](https://www.trionprojects.org/2020/03/ultrasonic-sensor-hc-sr04-with-pic.html)
* [Ultrasonic Sensor HC-SR04 Code for PIC18F4550](https://www.electronicwings.com/pic/ultrasonic-module-hc-sr04-interfacing-with-pic18f4550)
* [Distance Measurement Using HC-SR04 Via NodeMCU](https://www.instructables.com/Distance-Measurement-Using-HC-SR04-Via-NodeMCU/)
* [Obstacle Avoidance Robot - Part 14 Microcontroller Basics (PIC10F200)](https://www.circuitbread.com/tutorials/obstacle-avoidance-robot-part-14-microcontroller-basics-pic10f200)