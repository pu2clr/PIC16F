# PIC10F200 and DHT11 example

This folder presents some applications using PIC microcontrolers with DHT11 device. 

# About the DHT11

The DHT11 is a popular digital temperature and humidity sensor known for its simplicity and cost-effectiveness. It's widely used in hobbyist projects and consumer electronics for basic environmental monitoring. Here are the key features, protocol, interface with PIC microcontrollers, and technical specifications of the DHT11 device:

### Features:
- **Integrated Temperature and Humidity Sensor**: Measures ambient temperature and humidity with a single device.
- **Digital Output**: Provides temperature and humidity readings directly as digital data, eliminating the need for analog-to-digital conversion.
- **Low Cost**: Affordable for hobbyists and mass-production applications.
- **Easy to Interface**: Requires only one digital pin for communication.

### Protocol:
The DHT11 uses a proprietary one-wire protocol (not to be confused with the Dallas/Maxim 1-Wire protocol) for communication, which requires precise timing to interpret the data:
- **Start Signal**: The microcontroller sends a start signal by pulling the data line low for at least 18 milliseconds and then high for 20-40 microseconds.
- **Response Signal**: The DHT11 responds with a low signal for 80 microseconds followed by a high signal for 80 microseconds.
- **Data Transmission**: The sensor sends 40 bits of data, including humidity integer and decimal parts, temperature integer and decimal parts, and a checksum. Each bit's duration is determined by the length of the high signal following a common low signal.

### Interface with PIC Microcontrollers:
- **Single Digital Pin**: Connect the DHT11 data pin to a digital I/O pin on the PIC microcontroller. A pull-up resistor (typically 4.7kΩ to 10kΩ) is recommended on the data line.
- **Timing Critical**: Since the DHT11's protocol is timing-sensitive, it's important to disable interrupts on the PIC microcontroller during data transmission to ensure accurate timing.
- **Software Implementation**: Write or use existing libraries that implement the DHT11 protocol, managing the precise timing and data decoding.

### Technical Specifications:
- **Humidity Range**: 20-80% RH with 5% RH accuracy.
- **Temperature Range**: 0-50°C with ±2°C accuracy.
- **Sampling Rate**: Not more than 1 Hz (once every second).
- **Power Supply**: 3 to 5.5V, making it compatible with most microcontrollers, including 3.3V and 5V systems.
- **Physical Size**: Small form factor, though larger than some more advanced sensors like the DHT22 or SHT series.

Overall, the DHT11 is a suitable choice for applications where moderate accuracy and low cost are more critical than precision or advanced features. Its simple interface with PIC and other microcontrollers makes it a popular choice for educational purposes, DIY projects, and simple climate control systems.



## About Humidity Levels and Their Effects on Humans:

**Relative Humidity Ranges:**

* **Very Low (below 20%)**:
    * **Effects:** Dry skin, mucosae and eyes, respiratory irritation, increased static electricity, fatigue and difficulty concentrating.
    * **Recommendations:** Humidify the environment with humidifiers, use nasal and eye saline, drink plenty of water and avoid intense physical activity.
* **Low (20% to 30%)**:
    * **Effects:** Increased risk of respiratory diseases, dry mucosae, eye and throat irritation.
    * **Recommendations:** Humidify the environment, drink plenty of water and wash your hands frequently.
* **Moderate (30% to 60%)**:
    * **Effects:** Ideal level for human comfort and health.
    * **Recommendations:** Keep the environment clean and properly ventilated.
* **Desirable (50% to 60%)**:
    * **Effects:** Ideal level for well-being and respiratory health.
    * **Recommendations:** Keep the humidity within this range, especially in environments with air conditioning or heating.
* **High (60% to 70%)**:
    * **Effects:** Discomfort, excessive sweating, fungal and bacterial growth, condensation on walls and furniture.
    * **Recommendations:** Dehumidify the environment with dehumidifiers, ventilate the environment frequently and prevent fungal growth.
* **Very High (above 70%)**:
    * **Effects:** Risk of respiratory diseases, fungal and bacterial growth, deterioration of materials and structures.
    * **Recommendations:** Dehumidify the environment urgently, ventilate the environment frequently and prevent fungal growth.

**Notes:**

* Ideal humidity levels may vary slightly depending on the ambient temperature and individual health.
* It is important to monitor the humidity of the environment with a hygrometer to ensure that it is within the desired levels.
* People with respiratory problems or other health conditions may be more sensitive to humidity levels.



