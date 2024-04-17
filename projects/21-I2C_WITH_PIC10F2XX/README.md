# I2C protocol implementation in PIC10F200 Assembly

## UNDER CONSTRUCTION... 

![UNDER CONSTRUCTION...](../../images/under_construction.png)

## Overview

This project's main objective is to implement the I2C protocol on the PIC10F2XX series of microcontrollers in Assembly. This will enable the development of various interfaces with numerous modules that utilize this protocol.


The I2C (Inter-Integrated Circuit) protocol is a serial communication protocol that enables multiple devices to communicate with each other over a simple two-wire interface. It was originally developed by Philips Semiconductor (now NXP Semiconductors). The two wires are known as SDA (Serial Data Line) and SCL (Serial Clock Line). Each device connected to the I2C bus is software-addressable by a unique address and simple master/slave relationships exist at all times; masters can initiate a data transfer and slaves receive the data.

This protocol is particularly famous for its simplicity and effectiveness in environments where communication complexity and wiring need to be minimized. It supports multiple masters and slaves on the same bus, multi-master arbitration, and collision detection. I2C is widely used in microcontroller-based systems to interface with various peripherals like sensors, displays, and memory modules due to its robustness and ease of implementation.




## References 


* [Adafruit PCA9685 16-Channel Servo Driver](https://learn.adafruit.com/16-channel-pwm-servo-driver?view=all)
* [PCA9685 - Arduino Library Information](https://github.com/janelia-arduino/PCA9685)