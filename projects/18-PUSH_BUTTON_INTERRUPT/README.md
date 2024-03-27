# Using PUSH BUTTONS with interrupt

This folder contains examples in C and Assembly for the PIC12F675 and PIC16F628A microcontrollers, which demonstrate how to execute an action upon the press of a button (push button) by using interrupt setup.

## Content 

1. [Overview](#overview)
2. [PIC12F675 examples in Assembly and C](./PIC12F675/)
3. [PIC16F628A examples in Assembly and C](./PIC16F628A/)
4. [References](#references)


## Overview

Using interrupts instead of polling (active querying) in applications with microcontrollers offers several advantages, especially in terms of system efficiency and performance.

-  __Energy Efficiency__: Interrupts allow the microcontroller to enter a low-power mode and only wake up in response to a specific event. This is particularly useful in battery-powered applications, as it extends battery life. In contrast, polling requires the microcontroller to be constantly active and checking the status of a device or condition, consuming more energy.

-  __Better Processor Utilization__: With the use of interrupts, the microcontroller can dedicate itself to performing other tasks instead of spending CPU cycles continuously checking a condition. When a specific condition is met (e.g., an input signal is received), the interrupt signals the microcontroller to handle the event, thereby optimizing processor use.

-  __Faster Response Time__: Interrupts provide a quicker response time to external events, as the microcontroller can immediately react to an interrupt. In systems that use polling, there can be a significant delay between the time an event occurs and when it is detected, depending on the polling frequency.

-  __Code Simplification__: Interrupt-based programming can lead to simpler and more manageable code, especially in complex systems where multiple events need to be monitored. This contrasts with the polling approach, where the code to constantly check various conditions can become complex and difficult to maintain.

-  __Improved Concurrency__: Interrupts facilitate the implementation of concurrent systems, allowing the microcontroller to respond to multiple types of events without the need to rigidly sequence them, as is the case with polling.


However, it is necessary for the microcontroller to offer the feature of interrupts in its architecture for this approach to be used. The PIC16F628A, the PIC16F887, and the PIC12F675 are examples of microcontrollers that allow the use of this approach. Refer to the microcontroller's Data Sheet for more information.


## References

- [Introduction to Microcontrollers: Interrupt Processing](https://www.renesas.com/us/en/support/engineer-school/mcu-05)
- [Introduction to Microcontrollers - Interrupts](https://www.embeddedrelated.com/showarticle/469.php)
- [How an MCU Processes Interrupts](https://www.renesas.com/us/en/support/engineer-school/mcu-programming-peripherals-04-interrupts)


