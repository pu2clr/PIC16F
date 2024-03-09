# IR with PIC microcontrollers

UNDER CONSTRUCTION...


## About Infrared protocol

When choosing an infrared (IR) communication protocol for applications like remote controls, three popular options often considered are NEC, Sony, and RC5. Each has its characteristics, applications, and market presence. Let's delve into the details of each protocol, including their pros and cons, to understand which might be most suitable for various applications.

### NEC Protocol

**Description**: The NEC protocol is widely used in remote control systems. It sends data packets that include a leader code (to mark the beginning of data transmission), custom code (to identify the device or manufacturer), and the data code (which includes the command and its inverse for error checking).

**Applications**: Primarily used in consumer electronics like TVs, DVD players, and other household appliances.

**Pros**:
- **Robust Error Checking**: The inclusion of the command and its inverse offers reliable error detection.
- **Widespread Use**: Due to its reliability, it's extensively adopted in various consumer electronics.

**Cons**:
- **Longer Transmission Time**: Compared to some protocols, the NEC can have a longer transmission time due to its detailed error checking.

**Market Usage**: NEC is among the most commonly used IR protocols in the consumer electronics industry due to its reliability and straightforward implementation.

### Sony Protocol (SIRC)

**Description**: Sony's IR protocol, known as SIRC, varies in bit lengths (12, 15, or 20 bits) depending on the complexity of the command set. It consists of a start pulse followed by command and address bits.

**Applications**: Utilized in Sony's range of products, including TVs, audio equipment, and cameras.

**Pros**:
- **Scalability**: The varying bit lengths allow for a wide range of devices and functions.
- **Efficiency**: Shorter bit lengths can make transmissions quicker for simple commands.

**Cons**:
- **Limited Use Outside Sony Products**: Its adoption is mostly limited to Sony's ecosystem, making it less versatile for broader applications.

**Market Usage**: SIRC sees limited, brand-specific use within Sony's product range, making it less common in the broader market compared to NEC.

### RC5 Protocol

**Description**: Developed by Philips, the RC5 protocol uses Manchester encoding for data transmission, ensuring a balanced number of highs and lows for easier synchronization. It's known for its simplicity and effectiveness in a wide range of applications.

**Applications**: Widely used in home entertainment devices, such as TV sets, DVD players, and DVRs from various manufacturers.

**Pros**:
- **Bi-Phase Encoding**: Offers inherent synchronization and error resilience.
- **Versatility**: Supported by numerous devices across different manufacturers.

**Cons**:
- **Limited Data Payload**: With a fixed format of 14 bits, it can be restrictive for complex command sets.

**Market Usage**: RC5 is commonly used across various brands and devices, making it a popular choice for universal remotes and multi-brand environments.

### Comparison and Conclusion

- **Usage in Market**: NEC is the most universally adopted due to its robustness and reliability, making it a default choice for many manufacturers. RC5 follows, with its wide applicability across brands. SIRC is more niche, primarily found in Sony products.
- **Pros and Cons**: NEC's strength lies in its error checking, making it reliable but slightly slower. SIRC offers scalability and efficiency within Sony's ecosystem. RC5's bi-phase encoding provides good error resilience and versatility across brands but has a limited data payload.

In conclusion, the choice of protocol largely depends on the application's specific needs, including compatibility requirements, data complexity, and the desired balance between speed and reliability. NEC offers broad compatibility and robustness, making it a safe bet for general consumer electronics. RC5 is a good choice for applications requiring cross-brand compatibility, while SIRC is suitable for Sony-specific projects where efficiency and scalability are priorities.



## References

* [NEC Infrared Transmission Protocol](https://techdocs.altium.com/display/FPGA/NEC+Infrared+Transmission+Protocol)
* [Infrared Transmit and Receive on Circuit Playground Express in C++](https://www.digikey.com/en/maker/projects/infrared-transmit-and-receive-on-circuit-playground-express-in-c/0cdcbf1a087949adbb912f81fa1bcccc)
* [NEC IR Remote Control Interface with 8051](https://exploreembedded.com/wiki/NEC_IR_Remote_Control_Interface_with_8051)
* [Sony SIRC Protocol](https://www.sbprojects.net/knowledge/ir/sirc.php)
* [Sony SIRC infrared protocol](https://physika.info/site/downloads/sirc.pdf)
* [Understanding Sony IR remote codes, LIRC files, and the Arduino library](http://www.righto.com/2010/03/understanding-sony-ir-remote-codes-lirc.html)
* [Philips RC5 Infrared Transmission Protocol](https://techdocs.altium.com/display/FPGA/Philips+RC5+Infrared+Transmission+Protocol)
* [The Philips RC5 IR Remote Control Protocol](http://www.pcbheaven.com/userpages/The_Philips_RC5_Protocol/)
