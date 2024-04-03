# PIC16F887 and 74HC151 MULTIPLEXER 

Under construction...

![Under construction...](../../../images/under_construction.png)

**Waiting for the arrival of components for completion.**


This folder showcases the processing of analog readings from various sensors using the PIC16F887 and the 74HC151 multiplexer.


## Overview 

The PIC16F887 has 13 pins that can be configured as analog inputs and 21 pins that can be configured as digital inputs (not necessarily simultaneously with the analog inputs). That said, the following question arises: why then would I use an 8-channel multiplexer like the 74HC151 to take analog or digital readings from sensors?


### Why use a multiplexer with the PIC16F887?

Although the PIC16F887 has 13 pins configurable as analog inputs and 21 as digital inputs, using a multiplexer like the 74HC151 offers several advantages in analog and digital sensor readings:

**1. Increased number of inputs:** The 74HC151 allows you to connect up to 8 additional sensors, significantly expanding the capabilities of the PIC. This is especially useful when the number of sensors exceeds the available pins on the microcontroller.

**2. Flexibility:** The multiplexer offers flexibility in choosing the pins to be used. You can connect sensors to any pin of the multiplexer, regardless of their predefined functions in the PIC.

**3. Wiring simplification: By using a multiplexer, you reduce the number of wires needed to connect the sensors to the microcontroller. This simplifies the installation and maintenance of the system**.

**4. Optimization of pin usage:** The multiplexer allows you to use pins for other functions, such as communication, LED control, or other devices, even if the pins are also configurable as analog or digital inputs.

**5. Ease of Scalability: If you anticipate that your project might scale up, incorporating a multiplexer from the start makes it easier to add more input channels in the future without significant redesign. It’s a forward-looking approach that accommodates growth**.


