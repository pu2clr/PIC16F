# 1-Wire protocol with PIC and DS18B20

This folder presents some implementations with the DS18B20 temperature sensor using PIC microcontrollers.


## Content

1. [About 1-wire protocol](#about-1-wire-protocol)
2. [About DS18B20 device](#about-ds18b20-device)
3. [PIC10F200 (UNDER CONSTRUCTION...)](./PIC10F200/)
4. [PIC16F877](./PIC16F887/)
5. [References](#references)



##  About 1-wire protocol 

The 1-wire protocol is a simple, single-wire communication system used to connect multiple devices to a single microcontroller.  The main features and advantages are: 

* **Single wire:** Eliminates the need for dedicated data and clock lines, simplifying wiring.
* **Master-slave architecture:** One microcontroller acts as the master, controlling communication with multiple slave devices (sensors, actuators).
* **Data transmission:** Uses pulses on the single wire to represent data bits (high pulse for 1, low pulse for 0).
* **Power delivery:** Often, the same wire supplies both power and data.
* **Low complexity:** Easy to implement in both hardware and software due to its basic nature.

**Applications:**

* Temperature sensors (e.g., DS18B20)
* Memory chips (e.g., DS2432)
* Real-time clocks (e.g., DS3231)
* Low-cost, low-power communication systems

**Limitations:**

* Slower communication speed compared to multi-wire protocols.
* Limited cable length due to signal attenuation.

Overall, the 1-wire protocol offers an efficient and cost-effective way to connect basic devices to microcontrollers, particularly useful in space-constrained or battery-powered applications.



## About DS18B20 device 

The DS18B20 is a versatile and popular digital temperature sensor thanks to its ease of use, low cost, and wide range of features. Here are some of its main applications:

**1. Environmental monitoring:**

* Monitoring temperature in greenhouses, data centers, and other critical environments.
* Tracking temperature changes in soil, water, or air for scientific research or agricultural applications.

**2. Industrial control and automation:**

* Monitoring temperature in industrial processes, such as food processing, chemical manufacturing, and power generation.
* Controlling temperature-sensitive equipment, such as 3D printers or laser cutters.

**3. Consumer electronics:**

* Measuring temperature in wearable devices, fitness trackers, and smart home devices.
* Monitoring battery temperature in laptops, smartphones, and other portable devices.

**4. Data logging and recording:**

* Recording temperature data over time for weather stations, environmental monitoring systems, and scientific experiments.
* Creating temperature profiles for quality control or process optimization.

**5. Medical and healthcare:**

* Monitoring temperature in incubators, refrigerators, and other medical equipment.

* Measuring body temperature in thermometers or wearable health monitors.

These are just a few examples of the many applications for the DS18B20. Its versatility, affordability, and ease of use make it a valuable tool for a wide range of temperature measurement tasks.

### DS18B20 main features 

* **Digital temperature sensor:** Measures and outputs temperature digitally.
* **1-wire communication:** Connects to a microcontroller using a single wire, reducing wiring complexity.
* **Wide temperature range:** Measures temperatures from -55°C to +125°C.
* **High resolution:** Provides 9-bit to 12-bit temperature readings.
* **Low power consumption:** Ideal for battery-powered applications.
* **Durable:** Hermetically sealed for harsh environments.
* **Widely used:** Affordable and popular choice for temperature sensing in various applications like HVAC, industrial control, and data logging.

**Additional details:**

* Available in various packages (TO-92, SO-8).
* Operates with 3.0V to 5.5V power supply.
* Programmable resolution.
* Can be used in multi-drop configurations with multiple sensors on the same wire.



# REFERENCES


* [1-Wire ® Communication with PIC ® Microcontroller](https://ww1.microchip.com/downloads/en/appnotes/01199a.pdf)
* [The 1-Wire Communication Protocol](http://pic16f628a.blogspot.com/2009/09/1-wire-communication-protocol.html)
* [1-Wire Communication with a Microchip PICmicro Microcontroller](https://pdfserv.maximintegrated.com/en/an/AN2420.pdf)
* [1-wire slave emulator for PIC16 microcontroller – owslave](http://www.fabiszewski.net/1-wire-slave/)
* [Interface PIC MCU with DS18B20 sensor and SSD1306 | mikroC Projects](https://simple-circuit.com/pic-mcu-ds18b20-ssd1306-mikroc/)
* [PIC 1-Wire - Github](https://github.com/robvanbentem/pic-1wire/tree/master) 
* [Interfacing DS18B20 sensor with PIC microcontroller | MPLAB Projects](https://simple-circuit.com/mplab-xc8-ds18b20-pic-microcontroller/)
* [What is the 1-Wire protocol?](https://www.engineersgarage.com/what-is-the-1-wire-protocol/)

### Videos

* [1-Wire® Technology Overview](https://youtu.be/CjH-OztKe00?si=pAX-iU1oLr1Tuirv)
* [1-Wire® Technology Overview - Part 1](https://youtu.be/lsikcaA7q-c?si=Wmx4GoRT0IICpKza)
* [1-Wire® Technology Overview - Part 2](https://youtu.be/e6ORIDKA-QA?si=s8A--7CYRWxi0LlG)
* [1-Wire® Technology Overview - Part 3](https://youtu.be/WtifDKtRFQ4?si=R7ElFn5N9K81oF3Z)

