# 1-Wire protocol with PIC and DS18B20

This folder presents some implementations with the DS18B20 temperature sensor using PIC microcontrollers.


## Content

1. [About 1-wire protocol](#about-1-wire-protocol)
2. [About DS18B20 device](#about-ds18b20-device)
3. [PIC10F200](./PIC10F200/)
4. [PIC16F877](./PIC16F887/)
5. [DS18B20 Interface and Commands](#ds18b20-commands)
    * [How the DS18B20 Measures Temperature](#how-the-ds18b20-maasures-temperature)
    * [Initializing the DS18B20 Dialog Process](#initialization-the-ds18b20-dialog-process)
    * [Reading data from DS18B20](#read-data-from-ds18b20)
6. [References](#references)


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


## DS18B20 COMMANDS 

The commands below are used to control the DS18B20 and communicate with it via a 1-Wire interface. Each command has a specific purpose, such as initiating a temperature measurement, reading or writing to the sensor's scratchpad memory, and configuring device-specific settings.

| Command Byte | Description                                   |
|--------------|-----------------------------------------------|
| 0x44         | Start temperature conversion                  |
| 0xBE         | Read Scratchpad                               |
| 0x4E         | Write Scratchpad                              |
| 0x48         | Copy Scratchpad                               |
| 0xB8         | Recall E^2 data                               |
| 0xB4         | Read Power Supply                             |
| 0x55         | Match ROM                                     |
| 0xF0         | Search ROM                                    |
| 0xCC         | Skip ROM                                      |
| 0xEC         | Alarm Search                                  |

It's important to highlight that it's possible to use multiple DS18B20 sensors on the same 1-Wire bus in a single application (program). Consequently, a single application can measure the temperature of one or more distinct objects or environments simultaneously.

## DS18B20 PINOUT

![DS18B20 PINOUT](../../images/DS18B20_PINOUT.png)


## How the DS18B20 maasures temperature  

The DS18B20's primary feature is its direct-to-digital temperature sensor, offering user-configurable resolution settings of 9, 10, 11, or 12 bits. These settings correspond to temperature increments of 0.5°C, 0.25°C, 0.125°C, and 0.0625°C, respectively, with a default resolution of 12 bits upon power-up. Initially, the DS18B20 starts in a low-power idle state.

To begin a temperature measurement and analog-to-digital conversion, the controlling device (master) needs to send a Convert T [44h] command. After this conversion, the temperature data is stored within a 2-byte temperature register located in the scratchpad memory, and the DS18B20 reverts to its idle state.

When externally powered, the master can request "read time slots" following the Convert T command. During these slots, the DS18B20 indicates an ongoing temperature conversion by transmitting a 0 and switches to transmitting a 1 once the conversion is complete. However, if the DS18B20 uses parasitic power, this signaling method is not feasible. This is because, during the entire temperature conversion process, the 1-Wire bus must be maintained high through a strong pull-up resistor. The specific bus requirements for using parasitic power are detailed in the Powering the DS18B20 section.

**In Summary, the steps to mensaure a temperature are decribed below:** 

1. **Power-Up**: The DS18B20 initializes in a low-power idle state with a default resolution of 12 bits, which corresponds to a temperature increment of 0.0625°C.

2. **Resolution Configuration** (Optional):
   - The user can configure the sensor's resolution to 9, 10, 11, or 12 bits, corresponding to temperature increments of 0.5°C, 0.25°C, 0.125°C, and 0.0625°C, respectively.

3. **Initiate Temperature Measurement**:
   - To start a temperature measurement and analog-to-digital (A-to-D) conversion, the master device issues a Convert T [44h] command.

4. **Temperature Conversion**:
   - The DS18B20 performs the temperature measurement and A-to-D conversion.

5. **Data Storage**:
   - Once the conversion is complete, the temperature data is stored in a 2-byte register within the sensor's scratchpad memory.

6. **Return to Idle**:
   - After storing the temperature data, the DS18B20 returns to its idle state.

7. **Reading the Result**:
   - If the DS18B20 is externally powered, the master can issue "read time slots" after the Convert T command. The DS18B20 will signal an ongoing conversion by transmitting a 0 and indicate completion by transmitting a 1.
   - If the DS18B20 operates in parasitic power mode, the above signaling method cannot be used due to the need for a strong pull-up on the 1-Wire bus during the conversion.


### Initialization the DS18B20 dialog process

Every interaction with the DS18B20 starts with an initialization sequence that involves a reset pulse issued by the controlling device (master), followed by a presence pulse from the DS18B20. This process ensures that the DS18B20 is present on the bus and ready for operation.

Here's a clearer step-by-step breakdown:

1. **Reset Pulse**: The sequence begins with the bus master generating a reset pulse. This is done by pulling the 1-Wire bus low for at least 480 microseconds (µs).

2. **Bus Release and Receive Mode**: After sending the reset pulse, the bus master releases the bus, allowing it to return to a high state due to the 5kΩ pull-up resistor. The master then switches to receive mode to detect the DS18B20's response.

3. **Presence Pulse**: In response to the reset pulse, the DS18B20 waits for 15µs to 60µs before acknowledging its presence. It does this by pulling the 1-Wire bus low again, this time for a duration of 60µs to 240µs, signaling to the master that it is ready for communication.

This initialization ensures a clear start to communication, confirming the DS18B20's readiness to the bus master.


### Read data from DS18B20 

Data transfer from the DS18B20 to the master device is facilitated through specific intervals known as read time slots. The master must initiate these slots right after sending commands like Read Scratchpad [BEh] or Read Power Supply [B4h], allowing the DS18B20 to relay the requested information. Similarly, read time slots are necessary after commands like Convert T [44h] or Recall E2 [B8h] to determine the status of these operations, as detailed in the DS18B20 Function Commands section.

Key aspects of read time slots include:

1. **Duration**: Each read time slot should last at least 60 microseconds (μs), with a recovery period of at least 1μs between consecutive slots.

2. **Initiation**: A read time slot begins when the master pulls the 1-Wire bus low for at least 1μs, followed by releasing the bus. This action signals the DS18B20 to start transmitting data.

3. **Data Transmission**: The DS18B20 sends a '1' by keeping the bus high and a '0' by pulling the bus low. It ensures the bus returns to its high idle state by the end of the time slot, facilitated by the pull-up resistor.

4. **Timing for Data Sampling**: Data output from the DS18B20 remains valid for 15μs after the read time slot is initiated. Hence, the master should sample the bus state within this timeframe to accurately capture the transmitted data.

Illustrations in the documentation highlight that the total time for initiating the slot (TINIT), releasing the bus (TRC), and sampling the data (TSAMPLE) should not exceed 15μs. To optimize system timing, it's recommended to keep TINIT and TRC brief and perform data sampling towards the latter part of the 15μs window.

### Write data (command) do DS18B20

For writing data to the DS18B20, the communication process involves two distinct types of write time slots: the "Write 1" time slots for sending a logic '1', and the "Write 0" time slots for sending a logic '0'. The bus master controls the transmission of these bits through specific actions:

1. **Duration and Recovery**: Each write time slot, whether for writing a '1' or a '0', needs to last at least 60 microseconds (μs), with a minimum recovery period of 1μs between consecutive slots.

2. **Initiation**: Both "Write 1" and "Write 0" time slots begin with the master pulling the 1-Wire bus low.

3. **Generating Write 1**:
   - To write a '1', after initially pulling the bus low, the master releases the bus within 15μs.
   - Upon release, the 5kΩ pull-up resistor automatically pulls the bus high, signaling a '1'.

4. **Generating Write 0**:
   - To write a '0', after pulling the bus low, the master maintains this low state for the entire duration of the slot, at least 60μs.

5. **Data Sampling by DS18B20**:
   - The DS18B20 samples the state of the 1-Wire bus within a specific window, from 15μs to 60μs after the write slot initiation.
   - A high bus state during this window results in a '1' being registered by the DS18B20; a low state results in a '0'.




# REFERENCES


* [DS18B20 Data Sheet](https://www.analog.com/media/en/technical-documentation/data-sheets/DS18B20.pdf)
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

