# PWM with PIC12F675

Generating PWM with PIC12F675 and  interrupt resource.

## Content

- [About this experiment](#about-this-experiment)
- [Schematic](#schematics)
  * [KiCad schematic](./KiCad/)
- [About the PIC12675](#about-the-pic12675)
- [Prototype](#prototype)
- [MPLAB X Example](./MPLAB_EXAMPLE/)      
- [References](#references)


## About this experiment

In this experiment, a fan speed (or PWM signal) will be controlled by the analog value obtained from one of the ADC interfaces of the PIC12F675 microcontroller. This analog value can be acquired from a potentiometer, a photoresistor, or even a sensor like the LM35. The key aspect of this experiment is that regardless of what is connected to the analog input of the microcontroller, the generated PWM signal will be able to vary in real time according to the value of the received analog signal.


The pulse width (PWM) will vary according to the voltage input value, enabling real-time adjustment of the fan speed.


## Schematics 

### PWM General exsample schematic

![PWM General exsample schematic](./schematic_pwm_with_pic12F675.jpg)


### PWM Servo and PIC12F675 schematic


![PWM Servo and PIC12F675 schematic](./schematic_servo_pwm_pic12F675.jpg)


### About the PIC12675

The PIC12F675 is a compact and versatile 8-bit microcontroller from Microchip Technology, belonging to the popular PIC12F series. It's known for its small size and low power consumption, making it ideal for space-constrained and power-sensitive applications. The PIC12F675 features 1 KB of flash memory, 64 bytes of EEPROM, and 128 bytes of RAM, along with an onboard 10-bit Analog-to-Digital Converter (ADC), Interrupt capability, 8-level deep hardware stack, which is quite impressive for its size.


![PIC12F675 PINOUT](../../../images/PIC12F675_PINOUT.png)


## Prototype


![PIC12F675 PWM SERVO Prototype](./protype_pic12f675_pwm_servo.jpg)


## References

* [PWM pulse generation using PIC12F675 micro-controller](https://labprojectsbd.com/2021/03/31/pwm-pulse-generation-using-pic12f675-micro-controller/)
* [PIC12F675 PWM Code + Proteus Simulation](https://saeedsolutions.blogspot.com/2012/07/pic12f675-pwm-code-proteus-simulation.html)
