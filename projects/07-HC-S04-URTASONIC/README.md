# PIC Mic rocontrollers and HC-S04 Ultrasonic Sensor

This folder presents the [PIC10F200](./PIC10F200/), [PIC12F675](./PIC12F675/), [PIC16F628A](./PIC16F628A/) and [PIC16F876A](./PIC16F876A/) applications.


# Content

1. [Accuracy of this System](#accuracy-of-this-system) 
2. [HC-S04 Ultrasonic Sensor](#hc-s04-ultrasonic-sensor)
3. [Accuracy of this System](#accuracy-of-this-system)
4. [PIC10F200 example](./PIC10F200/)
5. [PIC12F675 example](./PIC12F675/)
6. [PIC16F628A example](./PIC16F628A/)
7. [PIC16F876A example](./PIC16F876A/)
8. [References](#references)


## HC-S04 Ultrasonic Sensor

The HC-SR04 Ultrasonic Sensor is a popular sensor used for measuring distance with high accuracy and stable readings. It operates by emitting an ultrasonic sound pulse and then measuring the time it takes for the echo to return. Features include:

- Range: Typically 2cm to 400cm.
- Accuracy: Can detect objects with precision, often around 3mm.
- Operating Voltage: Generally 5V.
- Interface: Consists of four pins - VCC, Trig (trigger), Echo, and GND.

Applications:
- Robotics for obstacle avoidance.
- Distance measurement in industrial environments.
- Proximity and level sensing applications.
- Parking sensors in vehicles.
- Projects requiring non-contact distance measurement.

The HC-SR04 is valued for its ease of use, affordability, and integration with microcontrollers like Arduino and PIC.


## Accuracy of this System

In applications based on PIC microcontrollers configured with its internal oscillator for operations such as distance measurement with the HC-S04 ultrasonic sensor, achieving optimal accuracy often requires careful calibration and fine-tuning. The internal oscillator of the PIC12F675, for example, while convenient and cost-effective, may not offer the same level of stability and precision as external crystal oscillators. This variance can impact the timing accuracy critical for distance measurements with the HC-S04, which relies on precise timing to calculate distances based on ultrasonic wave reflections.

Factors that can influence the precision of this system include:

1. **Oscillator Stability**: The internal oscillator's frequency can vary with temperature and voltage fluctuations, affecting the timing measurements used for calculating distance.

2. **Sensor Variations**: Individual HC-S04 sensors might exhibit slight differences in performance or sensitivity, necessitating calibration to ensure consistent readings.

3. **Environmental Conditions**: Temperature, humidity, and air composition can affect the speed of sound, and consequently, the distance calculations based on ultrasonic waves.

4. **Electrical Noise**: Other components in the circuit or external electromagnetic interference can introduce noise, impacting the sensor's ability to accurately detect ultrasonic signals.

For these reasons, implementing a calibration routine in the software can significantly enhance measurement accuracy. This routine could involve comparing readings from the HC-S04 with known distance values under controlled conditions and adjusting the software algorithm accordingly. Additionally, using stable power supplies and incorporating noise-reduction techniques in the circuit design can further improve the system's reliability and precision."



## References

* [Ultrasonic sensor with Microchip's PIC - Part 14 Microcontroller Basics (PIC10F200)](https://youtu.be/_k5f_zpP2lg?si=B3KbHLU_tqzUIZ7E)
* [Ultrasonic Sensor HC-SR04 With PIC Microcontroller](https://www.trionprojects.org/2020/03/ultrasonic-sensor-hc-sr04-with-pic.html)
* [Ultrasonic Sensor HC-SR04 Code for PIC18F4550](https://www.electronicwings.com/pic/ultrasonic-module-hc-sr04-interfacing-with-pic18f4550)
* [Distance Measurement Using HC-SR04 Via NodeMCU](https://www.instructables.com/Distance-Measurement-Using-HC-SR04-Via-NodeMCU/)
* [Obstacle Avoidance Robot - Part 14 Microcontroller Basics (PIC10F200)](https://www.circuitbread.com/tutorials/obstacle-avoidance-robot-part-14-microcontroller-basics-pic10f200)