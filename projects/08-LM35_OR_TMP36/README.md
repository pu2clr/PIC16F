# Termometer with LM35 or TMP36 sensor and PIC12F and PIC16F with ADC support

In this folder, you will find some projects with the PIC12F and PIC16F series for processing analog signals, particularly for reading voltage outputs produced by temperature sensors like the LM35 or TMP36

## Fever indicator with the small PIC12F675

The PIC12F675 is a compact and versatile 8-bit microcontroller from Microchip Technology, belonging to the popular PIC12F series. It's known for its small size and low power consumption, making it ideal for space-constrained and power-sensitive applications. The PIC12F675 features 1 KB of flash memory, 64 bytes of EEPROM, and 128 bytes of RAM, along with an onboard 10-bit Analog-to-Digital Converter (ADC), which is quite impressive for its size.



## Simplifying Complex Calculations in Temperature Sensing with PIC12F675 projects

Some projects utilize either an LM35 or TMP36 temperature sensor to determine if a body's temperature is below, equal to, or above 37 degrees Celsius. The approach is streamlined to improve efficiency: there's no conversion of the sensor's analog signal to a Celsius temperature reading, as the actual temperature value isn't displayed.

The key lies in understanding the digital equivalent of 37 degrees Celsius in the sensor's readings. For instance, an analog reading of 77, when converted to digital through the Analog-to-Digital Converter (ADC), corresponds precisely to 37 degrees Celsius. This can be calculated as follows:

\[ \text{ADC Value} \times \frac{5}{1024} \times 100 = \text{Temperature in Degrees Celsius} \]
\[ 77 \times \frac{5}{1024} \times 100 \approx 37.59^\circ\text{C} \]

Therefore, the process involves simply reading the analog value and comparing it with 77. This method significantly conserves memory and processing power, optimizing the project's overall efficiency.




## References

* [PIC12F629/675 Data Sheet](https://ww1.microchip.com/downloads/en/devicedoc/41190c.pdf)
