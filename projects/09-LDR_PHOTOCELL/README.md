# LDR (photocell) with PIC and ADC


To emphasize the use of Analog-to-Digital Converters (ADC) found in some PIC microcontrollers, this small project introduces an emergency light system based on an LDR (also popularly known as a photoresistor or photocell).

It's important to note that for a simple emergency light system like the one presented here, the use of a microcontroller and programming isn't strictly necessary. With just a few passive components, an LDR, and a transistor, it's possible to implement an emergency light system at a much lower cost.

However, this project is educational in nature and serves as a foundation for developing more complex systems, which would be significantly more challenging without the use of microcontrollers. For instance, it could be used to log the times when the emergency system (emergency light) is activated for later analysis or to record the average light intensity over a specific period.

In this project, a transistor is also used to assist in activating a strong light that could not be directly driven by the microcontroller (as is commonly done with LEDs). This approach allows for the activation of higher power systems.

Below is the circuit for our Emergency Light project with LDR and the PIC12F675.


## Schematic

The photoresistor used in this project varies its resistance depending on the intensity of light, ranging from values close to 50Ω to those near 1MΩ. In other words, in a very dark environment, the resistance of this device is quite high, around 1MΩ, whereas in brightly lit areas or in direct sunlight, the resistance can drop to less than 100Ω. To some extent, this device can be likened to a potentiometer. The key difference is that a potentiometer changes its resistance through mechanical action (like a human hand), while a photoresistor varies its resistance with light intensity.

Given these characteristics, this device can be used to develop various products such as alarms, emergency lights, and energy-saving systems in public spaces, among other applications. The strategy for developing the Emergency Light involves creating a voltage divider by placing a fixed 10K resistor in series with the variable photoresistor (LDR). The voltage across the 10K resistor will be read by the microcontroller's analog input and converted into a 10-bit number (ranging from 0 to 1024, with 1024 corresponding to 5V - considering 5V as the reference voltage set in the microcontroller). The circuit below shows the emergency lights and the PIC12F675 setup. 


![Emergency Light System with LDR and PIC12F675](./schematic_emergency_light_ldr_pic12f675.jpg)



## PIC12F675 pinout



![PIC12F675 pinout](./../../images/PIC12F675_PINOUT.png)



## Source code in C lenguage 





## SOurce code in Assembly 




## Prototype



