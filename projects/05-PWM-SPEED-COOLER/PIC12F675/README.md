# PWM with PIC12F675

In this experiment, the speed of the cooler will vary according to the temperature measured by the LM35 sensor. In this case, as the temperature increases, the speed of the cooler will also increase.

For temperatures below 20°C, the cooler will not run. For temperatures above 60°C, the cooler will reach its maximum speed.

To control the fan speed effectively, the interrupt feature of the PIC12F675 microcontroller can be utilized in conjunction with the internal timer function. In this setup, whenever the internal counter (Timer0) overflows, a function responsible for controlling the signal level of a digital output pin on the PIC12F675 will be executed.

The pulse width (PWM) will vary according to the temperature value, enabling real-time adjustment of the fan speed.


### About the PIC12675

The PIC12F675 is a compact and versatile 8-bit microcontroller from Microchip Technology, belonging to the popular PIC12F series. It's known for its small size and low power consumption, making it ideal for space-constrained and power-sensitive applications. The PIC12F675 features 1 KB of flash memory, 64 bytes of EEPROM, and 128 bytes of RAM, along with an onboard 10-bit Analog-to-Digital Converter (ADC), Interrupt capability, 8-level deep hardware stack, which is quite impressive for its size.


![PIC12F675 PINOUT](../../../images/PIC12F675_PINOUT.png)




## References

* [PIC12F675 PWM Code + Proteus Simulation](https://saeedsolutions.blogspot.com/2012/07/pic12f675-pwm-code-proteus-simulation.html)

