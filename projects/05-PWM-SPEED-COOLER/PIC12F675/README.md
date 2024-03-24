# Generating PWM with PIC12F675 and interrupt resource.

## Content

- [About this experiment](#about-this-experiment)
- [Schematic](#schematics)
  * [KiCad schematic](./KiCad/)
- [About the PIC12675](#about-the-pic12675)
- [Example in C](#example-in-c)
- [Example in Assembly and interrupt setup](#example-in-assembly-and-interrupt-setup)
- [Prototype](#prototype)
- [MPLAB X Example](./MPLAB_EXAMPLE/)      
- [References](#references)


## About this experiment

In this experiment, a fan speed (or PWM signal) will be controlled by the analog value obtained from one of the ADC interfaces of the PIC12F675 microcontroller. This analog value can be acquired from a potentiometer, a photoresistor, or even a sensor like the LM35. For example: based on the analog value read, the fan speed can be adjusted proportionally to the increase in temperature measured by the sensor. Minimum and maximum limits for the fan speed can be defined. Thus, if the temperature is below 20°C, the fan will not operate, and if the temperature is above 60°C, the fan will reach its maximum speed.

The key aspect of this experiment is that regardless of what is connected to the analog input of the microcontroller, the generated PWM signal will be able to vary in real time according to the value of the received analog signal.
Again, if you use a temperature sensor, you can configure it for temperatures below 20°C, the cooler will not run and for temperatures above 60°C, the cooler will reach its maximum speed.

To control the fan speed (or PWM signal) effectively, the interrupt feature of the PIC12F675 microcontroller can be utilized in conjunction with the internal timer function. In this setup, whenever the internal counter (Timer0) overflows, a function responsible for controlling the signal level of a digital output pin on the PIC12F675 will be executed. This method allows for a more accurate simulation of a PWM output on a digital output pin of the PIC12F675.

The pulse width (PWM) will vary according to the voltage input value, enabling real-time adjustment of the fan speed.


## Schematics 

### PWM General example schematic

![PWM General exsample schematic](./schematic_pwm_with_pic12F675.jpg)


### Schematic - L293D H-bridge with DC MOTOR controlled by PIC12F675 via PWM


![Schematic - L293D H-bridge with DC MOTOR controlled by PIC12F675 via PWM](././schematic_pic12F675_L293D_DC_MOTOR_ADC_PWM.jpg)



### PWM and 4-wires Cooler and PIC12F675 schematic

![PWM and 4-wires Cooler and PIC12F675 schematic](./schematic_4_wire_cooler_pwm_pic12F675.jpg)



### About the PIC12675

The PIC12F675 is a compact and versatile 8-bit microcontroller from Microchip Technology, belonging to the popular PIC12F series. It's known for its small size and low power consumption, making it ideal for space-constrained and power-sensitive applications. The PIC12F675 features 1 KB of flash memory, 64 bytes of EEPROM, and 128 bytes of RAM, along with an onboard 10-bit Analog-to-Digital Converter (ADC), Interrupt capability, 8-level deep hardware stack, which is quite impressive for its size.


![PIC12F675 PINOUT](../../../images/PIC12F675_PINOUT.png)


## Example in C 

```c

#pragma config FOSC = INTRCIO   // Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = OFF      // Power-Up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = OFF       // GP3/MCLR pin function select (GP3/MCLR pin function is MCLR)
#pragma config BOREN = ON       // Brown-out Detect Enable bit (BOD enabled)
#pragma config CP = OFF         // Code Protection bit (Program Memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)


#define _XTAL_FREQ 8000000			// required for delay Routines. 

#include <xc.h>

uint8_t PWM = 50;



void  initADC() {
    TRISIO = 0B00000001;          // GP0 as input and GP1, GP2, GP4 and GP5 as digital output
    ANSEL =  0B00010001;          // AN0 as analog input
    ADCON0 = 0B10000001;          // Right justified; VDD;  01 = Channel 00 (AN0); A/D converter module is 
}

void  initInterrupt() {
    // INTEDG: Interrupt Edge Select bit -  Interrupt will be triggered on the rising edge
    // Prescaler Rate: 1:64 - It generates about 73Hz (assigned to the TIMER0 module)
    OPTION_REG = 0B01000101;       // see  data sheet (page 12)    
    T0IE = 1;                      // TMR0: Overflow Interrupt 
    GIE = 1;                       // GIE: Enable Global Interrupt
}


/**
 * Handle timer overflow
 */
void __interrupt() ISR(void)
{
    if ( T0IF ) {
        
        if (GP5 ) {
            TMR0 = PWM;
            GP5 = 0;
        } else {
            TMR0 = 255 - PWM;
            GP5 = 1;
        }
        
        T0IF = 0;
    }
    
}

unsigned int readADC() {
    ADCON0bits.GO = 1;              // Start conversion
    while (ADCON0bits.GO_nDONE);    // Wait for conversion to finish
    return ((unsigned int) ADRESH << 8) + (unsigned int) ADRESL;  // return the ADC 10 bit integer value 1024 ~= 5V, 512 ~= 2.5V, ... 0 = 0V
}



void main() {
   
    initADC();
    initInterrupt();
    
    while (1) {
        unsigned int value = readADC();
        PWM = (uint8_t) (value >> 2);       // 10-bit adc interger divided by 4.
    }
}

```



## Example in Assembly and interrupt setup

I couldn't find clear documentation on how to configure the interrupt service using "pic-as". Therefore, I attempted various configurations so that the occurrence of a desired interrupt would redirect the program flow to address 4h (as described in the PIC12F675 Data Sheet). I didn't find an Assembly directive that would instruct the assembler to start the interrupt code at address 4h (the ORG directive didn't seem to work). However, this was made possible by adding special parameters in the project settings/properties, as shown below. Go to properties and set the pic-as Additional Options: -Wl,-PresetVec=0x0,-PisrVec=0x04.  The image below shows that setup.

![Assembly and interrupt setup](../../../images/pic12f675_interrupt_setup.png)


```asm

; UNDER  IMPROVEMENTS...
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

auxValue    equ 0x20		; counter 1
adcValueL   equ 0x21		; 8 bits less significant value of the adc
adcValueH   equ 0x22		; 8 bits most significant value of the adc
pwm	    equ	0x23   
   	    
PSECT resetVec, class=CODE, delta=2 
ORG 0x0000	    
resetVect:
    PAGESEL main
    goto main
;
; INTERRUPT IMPLEMENTATION 
; THIS FUNCTION WILL BE CALLED EVERY TMR0 Overflow
; pic-as Additiontal Options: -Wl,-PresetVec=0x0,-PisrVec=0x04    
PSECT isrVec, class=CODE, delta=2
ORG 0x0004     
isrVec:  
    PAGESEL interrupt
    goto interrupt
  
interrupt: 
   
    bcf	    STATUS, 5
    
    bcf	    INTCON, 7	; Disables GIE
    
    ; check if the interrupt was trigged by Timer0	
    btfss   INTCON, 2	; INTCON - T0IF: TMR0 Overflow Interrupt Flag 
    goto    PWM_FINISH
    btfss   GPIO, 5	; 
    goto    PWM_LOW 
    goto    PWM_HIGH
PWM_LOW: 
    movlw   255
    movwf   auxValue
    movf    pwm, w
    subwf   auxValue, w
    movwf   TMR0
    bsf	    GPIO, 5	    ; GP5 = 1
    ; bcf	    GPIO,2	    ; For Debugging 
    goto    PWM_T0IF_CLR
PWM_HIGH: 
    movf    pwm, w
    movwf   TMR0 
    bcf	    GPIO, 5	    ; GP5 = 0
    ; bsf	    GPIO,2	    ; For Debugging    
PWM_T0IF_CLR:
    bcf	    INTCON, 2  
PWM_FINISH:
    bsf	    INTCON, 7		    ; Enables GIE
   
    retfie    
    
    
; PSECT code, delta=2
main: 
    ; Bank 1
    bsf	    STATUS,5	    ; Selects Bank 1  
    movlw   0B00000001	    ; GP0 as input and GP1, GP2, GP4 and GP5 as digital output
    movwf   TRISIO	    ; Sets all GPIO as output    
    movlw   0B00010001	    ; AN0 as analog 
    movwf   ANSEL	    ; Sets GP0 as analog and Clock / 8    

    ; OPTION_REG setup
    ; bit 5 = 0 -> Internal instruction cycle clock;
    ; bit 3 =  0 -> Prescaler is assigned to the TIMER0 module
    ; bits 0,1,2 = 101 -> TMR0 prescaler = 64 
    movlw   0B01000101	
    movwf   OPTION_REG	    
    ; Bank 0
    bcf	    STATUS,5 
    clrf    GPIO	; Turn all GPIO pins low
    ; movlw   0x07	;   
    ; movwf   CMCON	; digital IO  
    movlw   0B10000001	; Right justified; VDD;  01 = Channel 00 (AN0); A/D converter module is 
    movwf   ADCON0	; Enable ADC   
    
    ; INTCON setup
    ; bit 7 (GIE) = 1 => Enables all unmasked interrupts
    ; bit 5 (T0IE) =  1 => Enables the TMR0 interrupt
    movlw   0B10100000
    iorwf   INTCON
    
    movlw   50
    movwf   pwm
    
    ; bcf	    GPIO,2	; For Debugging 
    
MainLoopBegin:		; Endless loop
    call    AdcRead
    
    ; Divide 10-bit integer adc value  by 4 and stores the resul in pwm
    rrf	    adcValueL
    rrf	    adcValueL
    movf    adcValueL, w
    andlw   0B00111111
    movwf   adcValueL
    
    swapf   adcValueH
    rlf	    adcValueH	
    rlf	    adcValueH	     
    movf    adcValueH, w
    andlw   0B11000000
    iorwf   adcValueL, w  

    movwf   pwm		    ;  pwm has now the 10-bit integer adc value divided by 4.      
      
    goto    MainLoopBegin
     

;
; Read the analog value from GP0 (PIN 7 OF THE PIC12F675)
AdcRead: 
      
    ; For debugging
    ; movlw   LOW(100)
    ; movwf   adcValueL
    ; movlw   HIGH(100)
    ; movwf   adcValueH
    ; return 
    
    bcf	  STATUS, 5		; Select bank 0 to deal with ADCON0 register
    bsf	  ADCON0, 1		; Start convertion  (set bit 1 to high)

WaitConvertionFinish:		; do while the bit 1 of ADCON0 is 1 
    btfsc  ADCON0, 1		; Bit Test, Skip if Clear - If bit 1 in ADCON0 is '1', the next instruction is executed.
    goto   WaitConvertionFinish 

    movf  ADRESH, w		; BANK 0
    movwf adcValueH   
    
    bsf	  STATUS, 5		; Select BANK 1 to access ADRESL register
    movf  ADRESL, w		
    movwf adcValueL		; 

    bcf	  STATUS, 5		; Select bank 0 
    
    return    
        
    
END resetVect


```


## Prototype


![Prototype](./protype_pic12f675_pwm_servo.jpg)



## Contribution

If you've found value in this repository, please consider contributing. Your support will assist me in acquiring new components and equipment, as well as maintaining the essential infrastructure for the development of future projects. [Click here](https://www.paypal.com/donate/?business=LLV4PHKTXC4JW&no_recurring=0&item_name=Your+support+will+assist+me+in++maintaining+the+essential+infrastructure+for+the+development+of+future+projects.+&currency_code=BRL) to make a donation or scan the QR code provided below. 


## References

* [PWM pulse generation using PIC12F675 micro-controller](https://labprojectsbd.com/2021/03/31/pwm-pulse-generation-using-pic12f675-micro-controller/)
* [PIC12F675 PWM Code + Proteus Simulation](https://saeedsolutions.blogspot.com/2012/07/pic12f675-pwm-code-proteus-simulation.html)
* [PIC Microcontroller Assembly PIC16F877A](https://github.com/Devilbinder/PIC_Microcontroller_Assembly_PIC16F877A/tree/main)
* [Interrupts](https://picguides.com/beginner/interrupts.php)

