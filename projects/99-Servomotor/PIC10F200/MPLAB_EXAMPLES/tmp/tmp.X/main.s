; CircuitBread Tutorials
; Microcontroller Basics (PIC10F200), Part 10 - Servo motor, indirect addressing, and electronic lock
; Link: https://www.circuitbread.com/tutorials/servo-motor-indirect-addressing-and-electronic-lock---part-10-microcontroller-basics-pic10f200
; Source code conversion from Microchip MPASM to Microchip XC8 PIC Assembler.

; Include target device specific definitions.
#include <xc.inc>

; Some equates not included in the device specific definitions.
;----- OPTION_REG Bits -----------------------------------------------------
T0CS        EQU 0005h
NOT_GPPU    EQU 0006h
;----- STATUS Bits -----------------------------------------------------
Z           EQU 0002h

; Set the configuration word.
CONFIG WDTE = OFF  ; Watchdog Timer (WDT disabled)
CONFIG CP = OFF    ; Code Protect (Code protection off)
CONFIG MCLRE = OFF ; Master Clear Enable (MCLR disabled, GP3 enabled)

code_value  EQU     01011110B  ;code 2 3 1 1
                               ; 01 01 11 10
                               ;  1  1  3  2

i           EQU    010h    ;Delay register 1
j           EQU    011h    ;Delay register 2
lock_state  EQU    012h    ;Lock state: 3 - closed, 2 - opened
count       EQU    013h    ;Counter of the pressed buttons
code_reg    EQU    014h    ;Register for code
servo_steps EQU    015h    ;Number of pulses for servo to change position
num1        EQU    016h    ;First number register

; NOTE: To make sure the PIC10F200 RC oscillator calibration instruction at
; the 0xFF program memory address is not overwriten place this psect elsewhere
; , for example at the program memory start address: Project Properties >
; pic-as Global Options > Additional Options: -Wl,-pMyCode=0h
    PSECT MyCode,class=CODE,delta=2
INIT:
    MOVLW ~((1<<T0CS)|(1<<NOT_GPPU))
    OPTION                 ;Enable GPIO2 and pull-ups
    MOVLW ~(1 << GPIO_GP2_POSITION)
    TRIS GPIO              ;Set GP2 as output
    MOVLW 3
    MOVWF lock_state       ;Set lock state as "closed"
    GOTO LOCK_CLOSE        ;and close the lock
LOOP:

    CALL INIT_REGS         ;Initialize the registers values
READ_BUTTONS:              ;Here the "read buttons" part starts
    CALL CHECK_BUTTONS     ;Read the buttons state
    ANDLW 3                ;Clear all the bits of the result except two LSBs
    BTFSC STATUS, Z        ;If result is 0 (none of buttons were pressed)
    GOTO READ_BUTTONS      ;then return to the READ_BUTTONS label
    MOVLW 40               ;Otherwise load initial value for the delay
    CALL DELAY             ;and perform the debounce delay
    CALL CHECK_BUTTONS     ;Then check the buttons state again
    ANDLW 3
    BTFSC STATUS, Z
    GOTO READ_BUTTONS      ;If button is still pressed
    MOVWF INDF             ;Then save the button code in the INDF register
    CALL CHECK_BUTTONS     ;and keep checking the buttons state
    ANDLW 3
    BTFSS STATUS, Z
    GOTO $-3               ;until it becomes 0
    MOVLW 40               ;Perform the debounce delay again
    CALL DELAY
    BTFSS lock_state, 0    ;If the last bit of the lock_state is 0(lock is opened)
    GOTO LOCK_CLOSE        ;then close the lock (with any button)
    INCF FSR, F            ;otherwise increment the indirect address,
    DECFSZ count, F        ;decrement the button press counter,check if it is 0
    GOTO READ_BUTTONS      ;If it is not, then return to the READ_BUTTONS

    CALL INIT_REGS         ;otherwise initialize registers again
CHECK_CODE:                ;and start checking the code
    MOVF code_reg, W       ;Copy the code value into the W
    ANDLW 3                ;and clear all the bits of W except of the two LSBs
    SUBWF INDF, W          ;Subtract W from the indirectly addressed register
    BTFSS STATUS, Z        ;If result is not 0 (code is not correct)
    GOTO LOOP              ;then return to the LOOP label
    RRF code_reg, F        ;otherwise shift the code register right
    RRF code_reg, F        ;two times
    INCF FSR, F            ;Increment the the indirect address
    DECFSZ count, F        ;Decrement the counter and check if it is 0
    GOTO CHECK_CODE        ;If it is not, then check the next code value

LOCK_OPEN:                 ;otherwise open the lock
    BCF lock_state, 0      ;Clear the LSB of the lock_state
    CALL MANIPULATE_SERVO  ;and manipulate the servo to open the lock
    GOTO LOOP              ;Then return to the LOOP label

LOCK_CLOSE:                ;Code part to close the lock
    BSF lock_state, 0      ;Set the LSB of the lock state
    CALL MANIPULATE_SERVO  ;and manipulate the servo to open the lock
    GOTO LOOP              ;Then return to the LOOP label

;----------------Subroutines----------------------------------------
INIT_REGS:                 ;Initialize the  registers
    MOVLW num1             ;Copy the num1 register address to the
    MOVWF FSR              ;indirect address pointer
    MOVLW 4                ;Set count as 4 wait for 4 buttons presses
    MOVWF count
    MOVLW code_value       ;Copy code_value
    MOVWF code_reg         ;into the code_reg register
    RETLW 0                ;Return from the subroutine

CHECK_BUTTONS:
    BTFSS GPIO, GPIO_GP3_POSITION  ;Check if GP3 is 0 (SW1 is pressed)    
    RETLW 1                ;and return 1 (b'01')
    BTFSS GPIO, GPIO_GP0_POSITION  ;Check if GP0 is 0 (SW2 is pressed)    
    RETLW 2                ;and return 2 (b'10')
    BTFSS GPIO, GPIO_GP1_POSITION  ;Check if GP1 is 0 (SW3 is pressed)    
    RETLW 3                ;and return 3 (b'11')
    RETLW 0                ;If none of the buttons are pressed then return 0

DELAY:                     ;Start DELAY subroutine here    
    MOVWF i                ;Copy the W value to the register i
    MOVWF j                ;Copy the W value to the register j
DELAY_LOOP:                ;Start delay loop
    DECFSZ i, F            ;Decrement i and check if it is not zero
    GOTO DELAY_LOOP        ;If not, then go to the DELAY_LOOP label
    DECFSZ j, F            ;Decrement j and check if it is not zero
    GOTO DELAY_LOOP        ;If not, then go to the DELAY_LOOP label
    RETLW 0                ;Else return from the subroutine

MANIPULATE_SERVO:          ;Manipulate servo subroutine
    MOVLW 20               ;Copy 20 to the servo_steps register
    MOVWF servo_steps      ;to repeat the servo move condition 20 times
SERVO_MOVE:                ;Here servo move condition starts
    BSF GPIO, GPIO_GP2_POSITION  ;Set the GP2 pin to apply voltage to the servo
    MOVF lock_state, W     ;Load initial value for the delay
    CALL DELAY             ;(2 to open the lock, 3 to close it)
    BCF GPIO, GPIO_GP2_POSITION  ;Reset GP2 pin to remove voltage from the servo
    MOVLW 25               ;Load initial value for the delay
    CALL DELAY             ;(normal delay of about 20 ms)
    DECFSZ servo_steps, F  ;Decrease the servo steps counter, check if it is 0
    GOTO SERVO_MOVE        ;If not, keep moving servo
    RETLW 0                ;otherwise return from the subroutine

    END INIT        ; Program entry point.


