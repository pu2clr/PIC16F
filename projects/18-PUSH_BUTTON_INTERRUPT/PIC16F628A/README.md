# PIC16F628A and Push Button with Interrupt

This project, while simple in terms of its functionalities, can assist you in setting up more robust projects. The goal here is to present shortcuts for configuring the MPLAB development environment, setting up the microcontroller's registers, the feature of power saving, as well as the use of the interrupt feature, whereby a specific code can be executed in response to the press of a button.

Additionally, this project aims to provide examples in C (XC8) and Assembly (pic-as) as starting points for your own code.


## PIC16F28A with PUSH BUTTON and LED Schematic

![Schematic PIC16F286A blink](./SCHEMATIC_PIC16F628A_PUSH_BUTTON_INTERRUPT.jpg)

### About debounce capacitor

Using a capacitor for debouncing a button press in a circuit, especially in one involving a microcontroller, offers several benefits. When a button is pressed, it doesn't simply close the circuit; instead, due to mechanical imperfections, it can "bounce", causing rapid, multiple transitions between the ON and OFF states in a very short time. This bouncing can lead to multiple interrupts being triggered by a single press, which could cause unpredictable behavior in the microcontroller's response.

The inclusion of a 22 nF (nanofarad) capacitor in parallel with the button (connected to ground and the output pin GP2 through a 1kΩ resistor) serves as a debounce mechanism. Here are some benefits of this approach:

1. **Noise Filtering**: The capacitor acts as a low-pass filter, smoothing out the rapid changes or bounces caused by the mechanical action of the button. This ensures that the microcontroller sees a clean, stable transition from the unpressed to the pressed state.

2. **Prevention of Multiple Triggers**: By filtering out the noise and bounces, the capacitor prevents the microcontroller from detecting false multiple presses. This means that for each physical press of the button, the microcontroller will only register one interrupt event, improving the reliability of the input.

3. **Simplified Software**: Debouncing can also be achieved through software, by implementing timers or checking the button state over a period to confirm its state. However, a hardware debounce mechanism like a capacitor allows for a simpler and more efficient software design, as the microcontroller can react to button presses without needing to implement additional debouncing logic.

4. **Reduced Power Consumption**: In designs where power efficiency is crucial, hardware debouncing is advantageous. Software debouncing typically requires the microcontroller to be awake and polling the button state frequently, which consumes more power. With hardware debouncing, the microcontroller can spend more time in low-power modes, waking up only when a true button press event occurs.

5. **Enhanced Response Time**: Since the debouncing is handled by the hardware, the response to a button press can be immediate and precise from the microcontroller's perspective, allowing for faster and more predictable system reactions.


## PIC16F628A PINOUT

![PIC16F628A pinout](../../../images/PIC16F628A_PINOUT.png)



## PIC16F28A with PUSH BUTTON and LED

![Schematic PIC16F286A blink](./PROTOTYPE_PIC16F628A_PUSH_BUTTON_INTERRUPT.jpg)


## References 

- [Programming PIC16F84A-PIC16F628A Interrupts Tutorial](https://www.bristolwatch.com/k150/f84e.htm)
- [PIC16F628A external interrupt code + Proteus simulation](https://saeedsolutions.blogspot.com/2013/09/pic16f628a-external-interrupt-code.html)
- [Implementing Interrupts Using MPLAB® Code Configurator](https://developerhelp.microchip.com/xwiki/bin/view/software-tools/mcc/interrupts/)
- [Interrupts In PIC Microcontrollers](https://deepbluembedded.com/interrupts-in-pic-microcontrollers/)
- [8-bit PIC® MCU Interrupts](https://developerhelp.microchip.com/xwiki/bin/view/products/mcu-mpu/8bit-pic/peripherals/interrupts/)
