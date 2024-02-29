# PIC16F887 GAS SENSOR

The combination of accurate analog-to-digital conversion, sufficient I/O ports, serial communication capabilities, and cost-effectiveness makes the PIC16F887 an excellent choice for interfacing with MQ gas sensors. Whether for environmental monitoring, safety systems, or educational purposes, this microcontroller offers the flexibility and features necessary for a wide range of gas detection applications.



## Content

1. [PIC16F877 and MQ-2 schematic](#pic16f877-and-mq-2-schematic) 
    * [KiCad Schematic](./KiCad/)
2. [PIC16F877 PINOUT](#pic16f877-pinout)
3. [Prototype](#prototype---pic16f887-mq-2-gas-sensor-and-lcd16x2)
5. [MPLAB X IDE project](./MPLAB_EXAMPLE/)
6. [References](#references)



**ATTENTION:** This experiment is solely intended to demonstrate the interfacing of an MQ series gas sensor with PIC microcontrollers. The gas concentration values and thresholds used in the example programs have been arbitrarily set to illustrate high, medium, or low gas concentration levels. However, it is crucial to emphasize that these values may not accurately reflect the real concentrations that pose a health risk. Therefore, if you plan to use the examples provided, it is strongly recommended to consult the gas sensor's Datasheet. This is essential to ascertain the exact values that define dangerous, tolerable, or low gas concentrations.


## PIC16F877 and MQ-2 schematic

![PIC16F877 and MQ-2 schematic](./schematic_pic16F887_MQ_2_LCD16x2.jpg)


## PIC16F877 PINOUT

![PIC16F877 PINOUT](../../../images/PIC16F887_PINOUT.png)


## MQ-2 PINOUT

![MQ-2 PINOUT](../images/MQ_PINOUT.jpg)

| # | Pin/Part | Description |
|---|---|---|
| 1 | VCC | Power supply (5V) |
| 2 | GND | Ground |
| 3 | Dout (optional) | Digital output (optional) |
| 4 | Aout | Analog output |
| 5 | LED  | Gas indicator | 
| 6 | LED  | Power Supply | 
| 7 | Trim-pot | Tune the sensitivity | 



## Prototype - PIC16F887, MQ-2 gas sensor and LCD16x2


![PIC16F887, MQ-2 gas sensor and LCD16x2](./prototype_pic16F887_MQ_2_LCD16x2.jpg)


## References

* [Introduction to Gas Sensors: Construction Types and Working ](https://components101.com/articles/introduction-to-gas-sensors-types-working-and-applications)
* [What is a Gas Sensor: Working and Types](https://wiki.dfrobot.com/What_is_a_Gas_Sensor)
* [Gas detector](https://en.wikipedia.org/wiki/Gas_detector)
