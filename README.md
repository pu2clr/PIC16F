# PIC Journey: Navigating the World of Microchip's Microcontrollers

Welcome to "PIC Journey: Navigating the World of Microchip's Microcontrollers".

In this comprehensive learning series, we invite enthusiasts, students, and professionals alike to embark on an exciting voyage into the intricate world of PIC microcontrollers by Microchip Technology. Whether you're a beginner curious about the fundamentals or a seasoned tinkerer looking to expand your skillset, this journey is tailored for you.


The __projects__ folder contains several projects involving circuits with the PIC16F628A and LEDs that may help beginners.


All content (including code and schematic) of this repository can be freely distributed using the MIT Free Software model. By using or installing Library you are agreeing to the terms of the MIT licence (see license.txt file).

Copyright (c) 2019 Ricardo Lima Caratti.

Contact: pu2clr@gmail.com.


## Tools to program the PIC16FXXX 


### MPLAB X

MPLAB X is an integrated development environment (IDE) produced by Microchip Technology for the development of embedded applications on PIC microcontrollers. MPLAB X is based on the open-source NetBeans platform and runs on Windows, macOS, and Linux operating systems, offering a versatile and user-friendly interface for developers.

Key features of MPLAB X include:

1. **Cross-Platform Support**: Compatible with multiple operating systems, allowing for a flexible development environment.

2. **Advanced Editor**: Features like code completion, syntax highlighting, and a range of debugging tools aid in efficient code development.

3. **Debugger Integration**: Supports in-circuit debugging and emulation for Microchip's microcontrollers and digital signal controllers.

4. **Project Management Tools**: Simplifies the process of managing multiple project elements, including source files, libraries, and toolchains.

5. **Compiler Integration**: Compatible with Microchip's MPLAB XC Compilers as well as other third-party compilers.

6. **Version Control Support**: Offers support for popular version control systems for collaborative and organized development.

7. **Extensibility**: Users can add new functionality or support for new devices through plugins.

8. **Simulator**: Includes a simulator for virtual testing of code, which is useful for early stage development and troubleshooting.

MPLAB X is widely used by professionals, hobbyists, and students due to its comprehensive features and the broad range of Microchip devices it supports. It's a crucial tool for anyone working on projects involving Microchip's microcontrollers or digital signal controllers.


See [MPLAB® X Integrated Development Environment (IDE)](https://www.microchip.com/en-us/tools-resources/develop/mplab-x-ide)


### K150


The K150 is a low-cost, high-performance PIC programmer. It is designed to support a wide range of popular PIC microcontroller chips. The K150 allows for various operations such as reading, writing, and encryption of the microcontroller's memory. One of its key features is the use of high-speed USB communication, which facilitates faster programming compared to some other programmers like PICSTART. The device's programming speed and quality are reliable, making it a suitable choice for both hobbyists and professionals working with PIC microcontrollers.


To use the K150 PIC programmer, several key components and steps are required:

1. **K150 Programmer Hardware**: The primary device needed is the K150 programmer itself. It's a compact unit designed specifically for programming PIC microcontrollers.

2. **Computer with USB Port**: A computer (Windows-based, typically) with a USB port is required to connect the K150 programmer. The computer acts as the host for the programming software.

3. **Programming Software**: Software compatible with the K150 is needed to interface with the programmer. This software is used to write, read, and transfer the microcontroller code. Popular choices include "PICPgm Programmer" or "Microbrn".

4. **Device Drivers**: Appropriate drivers must be installed on the computer to ensure that the K150 programmer is recognized and can communicate effectively. These drivers are usually available on the website of the K150 manufacturer or from the software provider.

5. **USB Cable**: A USB cable is used to connect the K150 programmer to the computer. This cable is essential for data transfer and powering the device.

6. **PIC Microcontroller**: The specific PIC microcontroller that you intend to program. The K150 supports a wide range of PIC microcontrollers.

7. **Source Code for the PIC**: The actual program or code that you want to write into the PIC microcontroller. This code is written in a suitable programming language, usually Assembly or C.

8. **Basic Knowledge of PIC Programming**: A fundamental understanding of microcontroller programming and operation is necessary to effectively use the K150.

Once everything is set up, the programming process involves connecting the PIC microcontroller to the K150, using the software to load and transfer the code, and then writing the code to the microcontroller's memory. The K150 provides a cost-effective and user-friendly solution for programming PIC microcontrollers, making it a popular choice among hobbyists and educators.


### The image below show the K150 device


![Prototype PIC16F286A blink](./images/K150_device.jpg)


### K150 hardware and software external references

* [K150 PIC Programmer](https://www.sigmaelectronica.net/manuals/K150.pdf)
* [PIC K150 ICSP Programmer – PHI1072218](https://www.phippselectronics.com/support/pic-k150-icsp-programmer-phi1072218/)
* [Tutorial](https://youtu.be/CuJEQqz99IQ?si=BY09ux4ct4F9OVSA)


## PICKit3 and ICSP


The PICkit 3 is a programmer and debugger for Microchip's PIC microcontrollers and dsPIC digital signal controllers. It is part of Microchip's suite of tools for developing and debugging embedded systems applications using their microcontrollers. Here are some key features of the PICkit 3:

1. **Compatibility**: The PICkit 3 is compatible with a wide range of PIC microcontrollers and dsPIC digital signal controllers, making it a versatile tool for a broad array of development projects.

2. **USB Interface**: It connects to a PC via USB, providing an easy and convenient way to program and debug microcontrollers without needing an external power supply.

3. **In-Circuit Debugging**: The tool allows for in-circuit debugging, which means you can program, monitor, and debug your code directly on the target device while it is operating within your system. This feature is crucial for real-time testing and troubleshooting.

4. **MPLAB IDE Integration**: It integrates seamlessly with Microchip's MPLAB Integrated Development Environment (IDE), offering a full range of development tools within a single platform. This integration simplifies the programming and debugging process.

5. **Programming**: The PICkit 3 can be used to program microcontrollers with the user's application code. It supports a variety of programming modes and can program memory, EEPROM, and other components of the microcontroller.

6. **Portability**: Its compact size makes it portable and convenient for use in various settings, from development labs to educational environments.

7. **Advanced Features**: It supports advanced features like serial wire debugging and can provide power to the target board if needed.

8. **Target Voltage Range**: The PICkit 3 can support a target voltage range of 2.0V to 6.0V.

Overall, the PICkit 3 is a powerful and versatile tool for anyone working with Microchip's range of microcontrollers and digital signal controllers, from hobbyists and students to professional engineers.


### The image below shows the PICKit3 and ICSP setup


![PICKit3 and ICSP programming](./images/PICKit3_ICSP_01.jpg)


### The image below shows the PICKit3 pinout

![PICKit3 pinout](./images/pickit3_icsp_setup.png)

Source: [PICkit™ 3 Programmer/Debugger User’s Guide](https://ww1.microchip.com/downloads/en/DeviceDoc/51795B.pdf)


### Other PICKit3 and PIC ICSP setup 

![Pickit 3 Programmer/Debugger](./images/pickit3-microcontroller-connections.png)

Source: [Pickit 3 Programmer/Debugger](https://components101.com/misc/pickit3-programmer-debugger-pinout-connections-datasheet)


### PICKit3 References

* [PICkit™ 3 Programmer/Debugger User’s Guide](https://ww1.microchip.com/downloads/en/DeviceDoc/51795B.pdf)
* [In-Circuit Serial Programming™ (ICSP™) Guide](https://ww1.microchip.com/downloads/en/DeviceDoc/30277d.pdf)
* [Diagram 01 - ICSP Wiring (PIC Series)](https://www.piccircuit.com/shop/pic-code/120-diagram-01-icsp-wiring-pic-series.html)
* [Pickit 3 Programmer/Debugger](https://components101.com/misc/pickit3-programmer-debugger-pinout-connections-datasheet)




### Other Tools

* [C Compiler Solution Suite](https://www.ccsinfo.com/compilers.php)
* [SourceBoost IDE](http://www.sourceboost.com/CommonDownload.html)
* [MikroElektronika MikroC](https://www.mikroe.com/mikroc-pic)


## Microchip references

1. [PIC16F87XA Data Sheet](https://ww1.microchip.com/downloads/en/devicedoc/39582b.pdf)
2. [PIC16F87XA Data Sheet](https://ww1.microchip.com/downloads/en/devicedoc/39582b.pdf)
3. [PIC16F627A/628A/648A Data Sheet](https://ww1.microchip.com/downloads/en/DeviceDoc/40044G.pdf)
4. [MPLAB® XC8 C Compiler User’s Guide](https://ww1.microchip.com/downloads/en/devicedoc/50002053g.pdf)
5. [MPASMTM Assembler, MPLINKTM Object Linker, MPLIBTM Object Librarian User’s Guide](https://ww1.microchip.com/downloads/en/DeviceDoc/33014L.pdf)
6. [MPLAB® XC8 PIC® Assembler User's Guide](https://ww1.microchip.com/downloads/en/DeviceDoc/MPLAB%20XC8%20PIC%20Assembler%20User%27s%20Guide%2050002974A.pdf)
7. [Simulator](https://onlinedocs.microchip.com/pr/GUID-240F27AA-C615-4705-B68C-6E434B126B47-en-US-1/index.html?GUID-95DA81C7-47DF-4C86-BC12-0D9D018909C3)
8. [PICSimLab means Programmable IC Simulator Laboratory ](https://lcgamboa.github.io/picsimlab_docs/stable/Introduction.html#x2-10001)
9. [PICSimLab - Programmable IC Simulator Laboratory](https://github.com/lcgamboa/picsimlab)


## General References

* M. P. Bates, Interfacing PIC microcontrollers: Embedded design by interactive simulation. Newnes, 2013.
* F. Pereira, Microcontroladores PIC: programação em C. Saraiva Educação SA, 2007.
* [Experiments with PIC16F628A](http://electronicexperiments.blogspot.com/p/pic16f628a_01.html)

