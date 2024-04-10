# Under construction

![Under construction](../../images/under_construction.png)



To develop an application using OLED with I2C, this project implements the I2C protocol and interface with the SSD1306 controller.



## About I2C protocol

The I2C (Inter-Integrated Circuit) protocol is a synchronous, multi-master, multi-slave, packet-switched, single-ended, serial communication bus invented by Philips Semiconductor (now NXP Semiconductors). It is widely used for attaching low-speed peripheral devices to motherboards, embedded systems, and small form factor devices. The I2C protocol is particularly popular in microcontroller-based projects for sensor and device interfacing due to its simplicity and efficiency.

I2C uses only two bidirectional open-drain lines, Serial Data Line (SDA) and Serial Clock Line (SCL), pulled up with resistors. Multiple devices can be connected to these lines, allowing for communication between devices using just two wires, which helps to reduce complexity and save space, especially in small or compact electronic devices.

One of the core features of I2C is its ability to support multiple masters and slaves within the same bus. Each device is recognized by a unique address, and the protocol supports both 7-bit and 10-bit addressing, enhancing its flexibility to accommodate a wide range of devices. The master device controls the clock line (SCL) and initiates communication with slaves, which can either send or receive data.

I2C operates in several speed modes: Standard mode with a bit rate up to 100 kbit/s, Fast mode up to 400 kbit/s, Fast Mode Plus (Fm+) up to 1 Mbit/s, and High-Speed Mode (Hs-mode) up to 3.4 Mbit/s, making it versatile for various applications, from simple to more data-intensive tasks.

Overall, the I2C protocol's design simplicity, efficiency, and the flexibility of connecting multiple devices over a simple two-wire interface have made it an enduring standard in electronic communication.

## About the SSD1306 device 

The SSD1306 is a single-chip CMOS OLED/PLED driver with controller for organic/polymer light-emitting diode dot-matrix graphic display systems. It is designed to offer a simple and efficient way to integrate OLED displays into a variety of electronic products. The SSD1306 manages a display panel size of up to 128x64 pixels and supports multiple communication interfaces, including I2C (Inter-Integrated Circuit), which is often utilized for connecting small peripheral devices like sensors, displays, and microcontrollers in short-distance, intra-board communication.

A key feature of the SSD1306 is its built-in 128x64 bit Graphic Display Data RAM (GDDRAM), which stores the bit pattern to be displayed, thereby offloading complex graphics processing from the host processor. This makes the SSD1306 an ideal choice for applications where processor resources are limited or where simple and quick development of the display functionality is desired.

The SSD1306 is powered by a wide range of supply voltages, making it versatile for various electronic projects or commercial product designs. Its efficient power management and low power consumption are advantageous for battery-operated devices. Additionally, the SSD1306 supports horizontal and vertical scrolling functions, which can be particularly useful for creating dynamic displays or showing longer messages on small screens.

Its compatibility with OLED displays makes it a popular choice for developers looking to create high-contrast, high-resolution displays for wearable devices, portable electronics, and other applications where space is at a premium and power efficiency is crucial. The SSD1306's ability to drive OLED displays with crisp, clear visuals, even in low light conditions, adds to its appeal in the market.


## References 

* [I2C Communication using PIC Microcontroller with Example Codes](https://microcontrollerslab.com/i2c-communication-pic-microcontroller/)
* [PIC16F628A i2c (bit banging) code + Proteus simulation](https://saeedsolutions.blogspot.com/2014/03/pic16f628a-i2c-bit-banging-code-proteus.html)
* [Room Thermostat PIC16F628A](https://hackaday.io/project/185478-room-thermostat-pic16f628a)
* [OLED_I2C](https://github.com/gavinlyonsrepo/pic_16F1619_projects/tree/master/projects/OLED_I2C)
* [I2C Master Mode](https://ww1.microchip.com/downloads/en/devicedoc/i2c.pdf)
* [PIC Microcontoller Input / Output Method for I2C](http://www.piclist.com/techref/microchip/i2c-dv.htm)
* [I2C Communication with PIC Microcontroller PIC16F877](https://circuitdigest.com/microcontroller-projects/i2c-communication-with-pic-microcontroller-pic16f877a)
* [SSD1306](https://cdn-shop.adafruit.com/datasheets/SSD1306.pdf)
* [Controlling the SSD1306 OLED through I2C](https://mrdrprofbolt.wordpress.com/2020/04/23/controlling-the-ssd1306-oled-through-i2c/)
