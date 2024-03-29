# PIC10F200 and 74HC595 Shift Register device

The decision to use only the PIC10F200 in this project, alongside the Shift Register 74HC595, was due to this microcontroller's limited resources and the availability of only 4 GPIO pins. I believe these constraints underscore the significance of a component like the 74HC595 in many projects.

The 74HC595 is a widely-used integrated circuit in digital electronics, known as a Serial-in, Parallel-out Shift Register. This device is essential for expanding the output capabilities of microcontrollers while minimizing the number of required I/O pins. Here's a detailed description of the 74HC595:

1. **Functionality**:
   - The 74HC595 receives data serially and outputs it in parallel. This means it can take input from a microcontroller through a single pin and then control multiple outputs.

2. **Pin Configuration**:
   - The device typically has 16 pins, including 8 output pins, 3 pins for data input and shifting control (Serial Data Input, Shift Register Clock, and Storage Register Clock), a latch pin, an output enable pin, a master reset pin, and power supply pins (Vcc and GND).

3. **Data Transfer Process**:
   - Data is sent to the 74HC595 serially through the Serial Data Input pin. Each bit of data is then shifted into the shift register on the rising edge of the Shift Register Clock.
   - Once all data bits are shifted in, they can be latched to the storage register, making them available at the output pins. The latching occurs on the rising edge of the Storage Register Clock (also known as the Latch Clock).

4. **Cascading Capability**:
   - Multiple 74HC595 chips can be cascaded or daisy-chained together. This means that the Serial Data Output of one chip can be connected to the Serial Data Input of the next, allowing for the control of an even larger number of outputs with the same number of microcontroller pins.

5. **Applications**:
   - The 74HC595 is commonly used in applications requiring control over multiple outputs, such as driving LEDs, seven-segment displays, and other digital indicators. It's also useful in situations where microcontroller pins are limited, as it significantly expands the output capabilities.

6. **Voltage and Current Specifications**:
   - The device operates at standard logic levels and can be powered by a typical 5V power supply, making it compatible with most microcontrollers.

The 74HC595 is appreciated for its ease of use, efficiency in saving microcontroller pins, and its ability to handle multiple outputs simultaneously. Its versatility makes it a staple component in many electronic projects and commercial products.


## PIC10F200 and 74HC595 cotrolling 8 LEDs

Why choose the PIC10F200 as an example?

As I mentioned before, the PIC10F200 is a microcontroller with very limited memory resources, requiring designers and programmers to have advanced optimization skills. Thus, it is believed that if one can develop significant and robust projects using the PIC10F200, with similar challenges and more advanced microcontrollers features, it can  become easier. This approach encourages deep learning of the fundamentals of programming and embedded system design, establishing a solid understanding that will be beneficial when dealing with more complex devices.


### PIC10F200 and 74HC595 with two wires interface schematic


In this interface that utilizes only 2 pins of the microcontroller, it can be particularly advantageous in some scenarios. However, with each bit sent and the clock triggered, the pins (QA to QH and QH') are updated. Note that the OE/G pin is grounded, keeping the output constantly active. It's important to highlight that this configuration may not be suitable for some applications due to the continuous transition of the output status of the 74HC595 pins.


![PIC10F200 and 74HC595 schematic](./schematic_pic10f200_74hc595_2wires.jpg)


### PIC10F200 PINOUT

![PIC10F200 PINOUT](./../../images/PIC10F200_PINOUT.jpg)


### 74HC595 PINOUT

![74HC595 PINOUT](./../../images/74HC595_PINOUT.png)


| 74HC595 Pin | Name    | Description                                                   |
|------------|---------|---------------------------------------------------------------|
| 16         | Vcc     | Power supply pin, typically connected to +5V.                 |
| 8          | GND     | Ground pin, connected to the circuit's ground.                |
| 15, 1-7    | QA to QH| Output pins. Data shifted into the register appears here.     |
| 14         | DS/SER  | Serial data input pin for shifting data into the register.    |
| 13         | OE/¯G   | **Output enable pin. Low activates outputs; high disables them.** |
| 12         | ST_CP/RCLK | Latch pin to transfer data to the storage register.        |
| 11         | SH_CP/SRCLK | Clock pin to shift data into the register.               |
| 10         | MR/¯SRCLR | Master reset pin. Low clears the shift register.          |
| 9          | QH'/QHS | Serial output from the last bit for cascading shift registers.|



## PIC10F200 and 74HC595 C Example

In this example, the LEDs are controlled according to the following sequence: first, all of them are lit for a duration of 5 seconds, then they are all turned off for another 5 seconds. Finally, in an infinite cycle, each LED is lit one at a time, shifting from left to right.


```cpp

/*
 * PIC10F200 and two wires 74HC595 setup controlling 8 LEDs
 * File:   main.c
 * Author: Ricardo Lima Caratti
 *
 * Created on January 30
 */


#include <xc.h>

// CONFIG
#pragma config WDTE = OFF       // Watchdog Timer (WDT disabled)
#pragma config CP = OFF         // Code Protect (Code protection off)
#pragma config MCLRE = ON      // Master Clear Enable (GP3/MCLR pin fuction is digital I/O, MCLR internally tied to VDD)

#define _XTAL_FREQ  4000000


void inline sendData(unsigned char data) {
    for (unsigned char i = 0; i < 8; i++) {
        GP0 = (data >> i & 0B00000001);
        GP1 = 1;        // Clock and Latch (HIGH)
        __delay_us(2);
        GP1 = 0;
        __delay_us(2);  // Clock and Latch (LOW)
    }
}

void main(void) {
    TRIS = 0B00000000; // All GPIO (GP0:GP3) pins as output
    GPIO = 0;          // Data => GP0; Clock and Latch => GP1 

    sendData(0B11111111);
    __delay_ms(5000);
    sendData(0);
    __delay_ms(5000);

    unsigned char data = 1;
    while (1) {
        __delay_ms(1000);
        sendData(data);
        data = (unsigned char) (data << 1);
        if (data == 0) {
            sendData(0);
            data = 1;
        }
    }

}


```



## PIC10F200 and 74HC595 ASM Example

This example controls 8 LEDs using the 74HC595 device in such a way that, with each cycle of approximately 1 second, the LEDs alternate between being lit and turned off.

**IMPORTANT:** 

To assemble this code correctly, please follow the steps below:

1. Go to "Project Properties" in MPLAB X.
2. Select "Global Options" for the pic-as assembler/compiler.
3. In the "Additional Options" box, enter the following parameters: **-Wl,-pAsmCode=0h**


![PIC10F200 MPLAB setup](./Images/pic10f200_mplab_setup.png)


![PIC10F200 MPLAB setup assembly code](./Images/pic10f200_mplab_setup_asm.png) 



```asm

; Controlling 8 LEDs with PIC10F200 and the Shift Register 74HC595
; The PIC10F200 and 74HC595 interface uses two wires     
; This example controls 8 LEDs using the 74HC595 device in such a way that, 
; with each cycle of approximately 1 second, the LEDs alternate between being 
; lit and turned off.    
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
  CONFIG  MCLRE = ON	       ; Master Clear Enable (GP3/MCLR pin function  is MCLR)

  
; Declare your variables here

dummy1	    equ 0x10
dummy2	    equ 0x11 
startValue  equ 0x12		; Initial value to be sent	
valueToSend equ 0x13		; Current value to be sent
counter	    equ 0x14		
	
 
PSECT AsmCode, class=CODE, delta=2

MAIN:   
    ; 74HC595 and PIC10F200 GPIO SETUP 
    ; GP0 -> Data		-> 74HC595 PIN 14 (SER); 
    ; GP1 -> Clock		-> 74HC595 PINs 11 and 12 (SRCLR and RCLK);   
    movlw   0B00000000	    ; All GPIO Pins as output		
    tris    GPIO
    movlw   0B10101010	    ; An alternating sequence of lit LEDs 
    movwf   startValue	    ; The initial value to be sent to the 74HC595
MainLoop:		    ; Endless loop
    movlw   7
    movwf   counter
    movf    startValue, w
    movwf   valueToSend	    ;  
    ; Start sending  
PrepereToSend:  
    btfss   valueToSend, 0  ; Check if less significant bit is 1
    goto    Send0	    ; if 0 turn GP0 low	
    goto    Send1	    ; if 1 turn GP0 high
Send0:
    bcf	    GPIO, 0	    ; turn the current 74HC595 pin off 
    goto    NextBit
Send1:     
    bsf	    GPIO, 0	    ; turn the current 74HC595 pin on
NextBit:    
    ; Clock 
    call doClock	    ; Process current data (bit)
    ; Shift all bits of the valueToSend to the right and prepend a 0 to the most significant bit
    
    bcf	    STATUS, 0	    ; Clear cary flag before rotating 
    rrf	    valueToSend, f
    
    decfsz counter, f	    ; Decrement the counter and check if it becomes zero.
    goto PrepereToSend	    ; if not, keep prepering to send
    
    ; The data has been queued and can now be sent to the 74HC595 port
    call doClock	    ; Process latest data (bit)
      
MainLoopEnd:
    ; Delays about 1 second 
    movlw   255
    movwf   dummy2
Delay1s:
    call    Delay2ms
    call    Delay2ms
    decfsz  dummy2, f
    goto    Delay1s
    
    comf    startValue, f   ; Inverts the startValue bits. Alternating its value with each iteration 
    
    goto    MainLoop

; 74HC595 Clock processing
; ATTENTION: Due to the two-level stack limit of the PIC10F200, avoid calling this  
;            subroutine from within another subroutine to prevent stack overflow issues.    
doClock:
    ; Clock 
    bsf	    GPIO, 1	    ; Turn GP1 HIGH
    call    Delay100us	    ;
    bcf	    GPIO, 1	    ; Turn GP1 LOW
    call    Delay100us
    retlw   0
    
; ******************
; Delay function

; At 4 MHz, one instruction takes 1us
; So, this soubroutine should take about 10 x 10 us 

; It takes 100 us    
Delay100us:
    movlw   10
    movwf   dummy1    
LoopDelay100us:   
    goto $+1		    ; 2 cycles
    goto $+1		    ; 2 cycles
    goto $+1		    ; 2 cycles
    nop
    decfsz  dummy1, f	    ; 1 cycles (2 if dummy = 0)
    goto    LoopDelay100us  ; 2 cycles
    retlw   0
    
; It takes about 2ms
Delay2ms: 
    movlw  200
    movwf  dummy1
LoopDelay2ms: 
    goto $+1		    ; 2 cycles
    goto $+1		    ; 2 cycles
    goto $+1		    ; 2 cycles
    nop			        ; 1 cycle
    decfsz  dummy1, f	    ; 1 cycles (2 if dummy = 0)
    goto LoopDelay2ms	    ; 2 cycles
    retlw   0
    
END MAIN


```


## PIC10F200 and two 74HC595 devices with two wires interface controlling 16 LEDs 



### PIC10F200 and two 74HC595 devices with two wires interface schematic


![PIC10F200 and two 74HC595 devices with two wires interface controlling 16 LEDs ](./schematic_pic10f200_2x_74hc595_2wires.jpg)


## PIC10F200 and two 74HC595  controlling 16 LEDs C Example

In this example with 16 LEDs, the LEDs are controlled according to the following sequence: first, all of them are lit for a duration of 5 seconds, then they are all turned off for another 5 seconds. Finally, in an infinite cycle, each LED is lit one at a time, shifting from left to right.


```cpp
/*
 * PIC10F200 and two 74HC595 controlling 16 LEDs
 * File:   main.c
 * Author: Ricardo Lima Caratti
 *
 * Created on January 30
 */


#include <xc.h>

// CONFIG
#pragma config WDTE = OFF       // Watchdog Timer (WDT disabled)
#pragma config CP = OFF         // Code Protect (Code protection off)
#pragma config MCLRE = ON      // Master Clear Enable (GP3/MCLR pin fuction is digital I/O, MCLR internally tied to VDD)

#define _XTAL_FREQ  4000000


void inline sendData(unsigned int data) {
    for (unsigned char i = 0; i <= 16; i++) {
        GP0 = (data >> i & 1);
        GP1 = 1;
        __delay_us(2);
        GP1 = 0;
        __delay_us(2);
    }
}

void main(void) {
    TRIS = 0B00000000; // All GPIO (GP0:GP3) pins as output
    GPIO = 0;          // Data => GP0; Clock and Latch => GP1 
    
    // Turn all LEDs on
    sendData(0B1111111111111111);
    __delay_ms(5000);
    // Turn all LEDs off
    sendData(0);
    __delay_ms(5000);

    // 
    unsigned int data = 1;
    while (1) {
        __delay_ms(1000);
        sendData(data);
        data = (unsigned int) (data << 1);
        if (data == 0) {
            sendData(0);
            data = 1;
        }
    }

}


```


### PIC10F200 and two 74HC595 devices with two wires interface prototype


![PIC10F200 and two 74HC595 devices with two wires interface prototype](./prototype_pic10F200_2x_74HC595_16LEDs.jpg)





### PIC10F200 and two 74HC595 devices with three wires interface schematic

This example uses the PIC10F200 with two 74HC595 shift registers and a 3-pin (GPIO) interface. This interface appears to be the most commonly used with the 74HC595, unlike the two-pin interface presented previously. Below, the circuit is shown followed by the source code in C.


![PIC10F200 and two 74HC595 devices with three wires interface schematic](./prototype_pic10F200_2x_74HC595_16LEDs_3wires_interface.jpg)


```cpp

/*
 * PIC10F200 and two 74HC595 with 16 LEDs and three wires interface
 * File:   main.c
 * Author: Ricardo Lima Caratti
 * Created on January 30
 * 
 * GP0 => Data
 * GP1 => Clock 
 * GP2 => Latch
 */

#include <xc.h>

// CONFIG
#pragma config WDTE = OFF       // Watchdog Timer (WDT disabled)
#pragma config CP = OFF         // Code Protect (Code protection off)
#pragma config MCLRE = ON      // Master Clear Enable (GP3/MCLR pin fuction is digital I/O, MCLR internally tied to VDD)

#define _XTAL_FREQ  4000000

void sendData(unsigned int data) {
     GP2 = 0; // Latch low
    __delay_us(20);
    for (unsigned char i = 0; i < 16; i++) {
        GP0 = (data >> i & (unsigned int ) 1);
        __delay_us(100);
        GP1 = 1;
        __delay_us(100);
        GP1 = 0;
        __delay_us(100);
    }
    GP2 = 1; // Latch HIGH
    __delay_us(20);
}

void main(void) {
    TRIS = 0B00000000; // All GPIO (GP0:GP3) pins as output
    GPIO = 0; // Data => GP0; Clock => GP1; Latch = GP2 

    sendData(0);
    __delay_ms(3000);

    unsigned int data = 0B1010101010101010;

    while (1) {
        sendData(data);
        data = ~data;
        __delay_ms(3000);         
    }
}


```


## Contribution

If you've found value in this repository, please consider contributing. Your support will assist me in acquiring new components and equipment, as well as maintaining the essential infrastructure for the development of future projects. [Click here](https://www.paypal.com/donate/?business=LLV4PHKTXC4JW&no_recurring=0&item_name=Your+support+will+assist+me+in++maintaining+the+essential+infrastructure+for+the+development+of+future+projects.+&currency_code=BRL) to make a donation or scan the QR code provided below. 

![Contributing QR Code](../../images/PIC_JOURNEY_QR_CODE.png)


## Video

* [PIC10F200 and HC74595 device setup](https://youtu.be/quRumJupcdo?si=FNSA6wZ0tLC44LKt)
* [Two PINs of the PIC10F200 and two 74HC595 controlling 16 LEDs](https://youtu.be/2BrsyhduLC0?si=inql7uqsdXsxkR16)



## References

* [74HC595 Serial Shift Register Interfacing with Pic Microcontroller](https://microcontrollerslab.com/74hc595-shift-register-interfacing-pic-microcontroller/)
* [Smallest and cheapest microcontroller - tutorial](https://youtu.be/300HMv6gOs8?si=MKiTwYgLA295LC7H)
* [How 74HC595 Shift Register Works ? | 3D animated](https://youtu.be/Rftc7yEGfKU?si=b_ajpwzWRA0hUGYd)
* [16-Bit Bargraph Control Using Two 74HC595 Shift Registers](https://youtu.be/voV1z9RaINI?si=Hz-5AWeL9Oy1fCpq)



