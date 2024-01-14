# Assembly Journey 

Although modern C compilers implement excellent optimization techniques (some of which are quite impressive), it's possible that in some very special situations, coding in Assembly language may be more advantageous. Below you have some pros in coding in Assembly. 

**Pros of Assembly:**

1. **Efficiency**: Assembly allows for more efficient use of memory and processing power, which is crucial in resource-constrained environments.
2. **Control**: Provides low-level control of hardware, offering precise manipulation of registers and memory.
3. **Timing**: Enables accurate timing and performance tuning, essential for time-critical applications.

**However, you can face with some cons.**

**Cons of Assembly:**
1. **Complexity**: Writing in Assembly is more complex and time-consuming, requiring detailed knowledge of the microcontroller's architecture.
2. **Maintenance**: Assembly code is harder to read, understand, and maintain, especially for larger projects.
3. **Portability**: Assembly code is processor-specific and not portable across different microcontrollers.

In summary, Assembly is beneficial for highly optimized, resource-constrained, or hardware-specific applications but poses challenges in complexity, maintenance, and portability. C offers a balance of efficiency and ease of use, making it suitable for a broader range of applications.

## Compilling assembly programs for PIC microcontrollers using MPLAB X

You can compile an assembly program for PIC devices using MPLAB X. The steps below show you the actions to do that

1. **Open MPLAB X IDE**: Start MPLAB X IDE on your computer.

2. **Create a New Project**:
   - Select `File` > `New Project`.
   - Choose `Microchip Embedded` under `Categories` and `Standalone Project` under `Projects`. Click `Next`.
   - Select the  PIC microcontroller you are using (for example: PIC16F628A) from the device list. Click `Next`.
   - Choose your connected programmer or debugger (if you have one). Click `Next`.
   - For the compiler toolchain, select `PIC-AS`. Click `Next`.
   - Name your project and choose a project location. Click `Finish`.

3. **Add Assembly File to the Project**:
   - Right-click on the `Source Files` in the `Project` window.
   - Choose `New` > `ASM File` to create a new assembly file or `Add Existing Item` to add an existing .asm file.
   - Write or paste your assembly code into this file.

4. **Build and Load the Project**:
   - Connect your PIC microcontroller to the programmer (for example PICKit3).
   - Click on the `Build Project` button (the hammer icon) in the toolbar, or right-click on your project and select `Build`.
   - CLick in Make and Program Device 



```cpp

; PIC16F628A Configuration Bit Settings
; Assembly source line config statements
;    
; Author: Ricardo Lima Caratti - Jan/2024
;    
#include <xc.inc>
    
; CONFIG
  CONFIG  FOSC = INTOSCIO       ; Internal oscilator
  CONFIG  WDTE = OFF            ; Watchdog Timer Disable bit 
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RA5/MCLR/VPP Pin Function Select bit (RA5/MCLR/VPP pin function is MCLR)
  CONFIG  BOREN = ON            ; Brown-out Detect Enable bit (BOD enabled)
  CONFIG  LVP = OFF             ; Low-Voltage Programming Disable bit (RB4/PGM 
  CONFIG  CPD = OFF             ; Data EE Memory Code Protection bit (Data memory code protection off)
  CONFIG  CP = OFF              ; Flash Program Memory Code Protection bit (Code protection off)

; declare your variables here
var1 equ 0x20       ; Memory position (check the memory organization of your PIC device datasheet)
var2 equ 0x21       ;
    
PSECT resetVector, class=CODE, delta=2
resetVect:
    PAGESEL main
    goto main
PSECT code, delta=2
main:
    bsf STATUS, 5	; Select the Bank 1 - See PIC16F627A/628A/648A Data Sheet, page 20 and 21 (MEMORY ORGANIZATION)
    clrf PORTB		; Initialize PORTB by setting output data latches
    bcf STATUS, 5	; Return to Bank 0  

    ; example of using var 
    movlw 10
    movwf var1
    movlw 250
    movlw var2
    ;

loop:			    ; Endless loop
    ;
    ; Your application
    ;
    goto loop
     
    ;
    ; Your subroutines
    ;  

END resetVect

```

## Example - BLINK a LED with the PIC16F628A

```cpp

; PIC16F628A Configuration Bit Settings
; Assembly source line config statements
;    
; Author: Ricardo Lima Caratti - Jan/2024
;    
#include <xc.inc>
    
; CONFIG
  CONFIG  FOSC = INTOSCIO       ; Oscillator Selection bits (INTOSC oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer disable bit 
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RA5/MCLR/VPP Pin Function Select bit (RA5/MCLR/VPP pin function is MCLR)
  CONFIG  BOREN = ON            ; Brown-out Detect Enable bit (BOD enabled)
  CONFIG  LVP = OFF             ; Low-Voltage Programming disble
  CONFIG  CPD = OFF             ; Data EE Memory Code Protection bit (Data memory code protection off)
  CONFIG  CP = OFF              ; Flash Program Memory Code Protection bit (Code protection off)

// config statements should precede project file includes.

counter1 equ 0x20
counter2 equ 0x21
  
PSECT resetVector, class=CODE, delta=2
resetVect:
    PAGESEL main
    goto main
PSECT code, delta=2
main:
    bsf STATUS, 5	; Select the Bank 1 - See PIC16F627A/628A/648A Data Sheet, page 20 and 21 (MEMORY ORGANIZATION)
    clrf PORTB		; Initialize PORTB by setting output data latches
    clrf TRISB
    bcf STATUS, 5	; Return to Bank 0
    CLRW		    ; Clear W register
    movwf PORTB		; Turn all pins of the PORTB low    
loop:			    ; Loop without a stopping condition - here is your application code
    bsf PORTB, 3    ; Sets RB3 to high (turn the LED on)
    call DelayTwo
    bcf PORTB, 3    ; Sets RB3 to low (turn the LED off) 
    call DelayTwo
    goto loop

;
; Delay functions
;  
    
;  It should take about 0.00255 second.
;  One instruction cycle consists of four oscillator periods. 
;  For a oscillator of 4MHz a regular instructions takes 1us (See pic16f628a Datasheet, page 117). 
;  time = 10 cyclos * 255 * 0.000001 (1us per cyclo at 4MHz clock frequency)
;  time = 0.00255 second   
DelayOne:
    movlw   255		 
    movwf   counter1
DelayOneLoop:       ; Runs 10 cycles 255 times - You can try to improve precision by adding or removing nop instructions
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    decfsz counter1, f	; It takes two cucles - Decrements counter1. If the result is zero, then the next instruction is skipped (breaking out of the loop)
    goto DelayOneLoop	; It takes two cycles - If counter1 is not zero, then go to DelayOneLoop. 
    return

; Runs DelayOne 255 times.  It takes about 0,65 second (255 * 0.00255) 
; The actual duration of the loop depends on the DelayOne subroutine and the clock speed of the PIC microcontroller. 
; 
DelayTwo:
    movlw 255
    movwf counter2
 DelayTowLoop:
    call DelayOne
    decfsz counter2, f	; Decrements counter2. If the result is zero, then the next instruction is skipped (breaking out of the loop)
    goto DelayTowLoop	; If counter2 is not zero, then go to DelayOneLoop. 
    return

    
END resetVect
 

```



## References

* [MPLAB® XC8 PIC® Assembler User's Guide](https://ww1.microchip.com/downloads/en/DeviceDoc/MPLAB%20XC8%20PIC%20Assembler%20User%27s%20Guide%2050002974A.pdf)
* [Multibyte Arithmetic Assembly Library for PIC Microcontrollers - Code Generator](http://avtanski.net/projects/math/#det_m_div)
* [PIC Microcontoller Basic Math Methods](http://www.piclist.com/techref/microchip/math/basic.htm)
* [PIC Microcontroller Comparison Math Methods ](http://www.piclist.com/techref/microchip/compcon.htm)
* [PIC Microcontroller Tutorial / Good Programming Techniques](https://www.hobbyprojects.com/pic_tutorials/tutorial1.html)
* [PIC16C5X / PIC16CXXX Math Utility Routines](https://ww1.microchip.com/downloads/en/AppNotes/00526e.pdf)
* [Multi-byte Math on the 16Fxxx PIC chips](http://robotics.mcmanis.com/articles/20130117_pic_math.html)





### Videos

* [Arithmetic Instructions in PIC microcontrollers](https://youtu.be/8MlblPanBkM?si=IrNt-micQv_Jx01z)
* [PIC16F877 Arithmetic and Logical Operations](https://youtu.be/qFKnzxdRy2s?si=KYq55EuB7RzuePws)
* [Arithmetic Operations using PIC16F877A (Addition and Subtraction)](https://youtu.be/j5A6LC_kk20?si=RFDxYFWGeiH1amwl)

