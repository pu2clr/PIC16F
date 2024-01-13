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
    
;  It takes about 0.0005105 seconds at 4MHz clock speed    
DelayOne:
    movlw   255		 
    movwf   counter1
DelayOneLoop:       ; Runs 8 instructions 255 times 
    nop
    nop
    nop
    nop
    nop
    nop
    decfsz counter1, f	; Decrements counter1. If the result is zero, then the next instruction is skipped (breaking out of the loop)
    goto DelayOneLoop	; If counter1 is not zero, then go to DelayOneLoop. 
    return

; Runs DelayOne 255 times.  It takes about 0.13 second (I guess).
; The actual duration of the loop depends on the DelayOne subroutine and the clock speed of the PIC microcontroller. 
; At 4MHz clock it is about 520,000 cycles  (520,000 / 4,000,000 is about  0.13 s)  
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

