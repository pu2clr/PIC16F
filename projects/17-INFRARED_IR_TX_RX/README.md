# IR with PIC microcontrollers


This folder contains several concepts about the main IR protocols and provides examples of implementations using the PIC10F200 and PIC16F628A with various approaches. I believe that these examples will enable you to easily port the source codes to other microcontrollers from Microchip's PIC line.


![UNDER CONSTRUCTION...](../../images/under_construction.png)


## Content

1. [About Infrared protocol](#about-infrared-protocol)
2. [Implementing the NEC protocol](#implementing-the-nec-protocol)
3. [Implementing the Sony SIRC protocol](#implementing-the-sony-sirc-protocol)
4. [Implementing the RC5 IR protocol](#implementing-the-rc5-ir-protocol)
5. [PIC10F200 implementation](./PIC10F200/)
5. [PIC16F628A implematation](./PIC16F628A/)
6. [References](#references)

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

### Summarizing

- **Usage in Market**: NEC seems to be the most universally adopted due to its robustness and reliability, making it a default choice for many manufacturers. RC5 follows, with its wide applicability across brands. SIRC is more niche, primarily found in Sony products.
- **Pros and Cons**: NEC's strength lies in its error checking, making it reliable but slightly slower. SIRC offers scalability and efficiency within Sony's ecosystem. RC5's bi-phase encoding provides good error resilience and versatility across brands but has a limited data payload.

In conclusion, the choice of protocol largely depends on the application's specific needs, including compatibility requirements, data complexity, and the desired balance between speed and reliability. NEC offers broad compatibility and robustness, making it a safe bet for general consumer electronics. RC5 is a good choice for applications requiring cross-brand compatibility, while SIRC is suitable for Sony-specific projects where efficiency and scalability are priorities.


## Implementing the NEC protocol

Implementing the NEC communication protocol on a microcontroller requires understanding the NEC protocol's timing and data format. The NEC protocol uses pulse distance encoding of the bits. Each pulse burst (mark – logic high) is of a fixed duration (560 µs), followed by a space (logic low) of variable length to denote a logical "1" or "0".

* Logical '0' is represented by a 560 µs pulse burst followed by a 560 µs space.
* Logical '1' is represented by a 560 µs pulse burst followed by a 1,690 µs space.
* A leading pulse burst (9 ms) and a space (4.5 ms) denote the start of a transmission.
* A command is followed by its inverse as error detection.

### Sending an NEC Code

To send a command using the NEC protocol, you will first send the leading pulse, then the data byte, its inverse, the address byte, and its inverse, followed by a final pulse to denote the end of transmission.

Implementation Details

* Timing Accuracy: The timing of the pulses and spaces is crucial. You need to be as accurate as possible, which might require calibrating your delay functions (delay_us and IR_delay) based on the actual clock speed of your PIC microcontroller.
* Carrier Frequency: The IR LED should be modulated at a 38 kHz carrier frequency. This is not explicitly shown in the snippets above, but in practice, you turn the IR LED on and off at 38 kHz during the "on" periods of the pulses. This requires setting up a timer or employing precise delays.
* The code snippets provided offer a simplified view of the process. They need to be adjusted and expanded based on your specific hardware setup

#### Example

```cpp

#include <xc.h>

// Configuration bits (may need to adjust based on your setup)
#pragma config FOSC = HS // Oscillator Selection bits (HS oscillator)
#pragma config WDTE = OFF // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = OFF // Power-up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = ON // RA5/MCLR pin function select
#pragma config BOREN = ON // Brown-out Reset Enable bit (BOR enabled)
#pragma config LVP = OFF // Low-Voltage (Single-Supply) In-Circuit Serial Programming Enable bit (RB3 is digital I/O, HV on MCLR must be used for programming)
#pragma config CPD = OFF // Data EEPROM Memory Code Protection bit (Data EEPROM code protection off)
#pragma config WRT = OFF // Flash Program Memory Write Enable bits (Write protection off)
#pragma config CP = OFF // Flash Program Memory Code Protection bit (Code protection off)

#define _XTAL_FREQ 20000000 // Define your clock frequency, adjust to your oscillator

void init() {
    TRISB = 0x00; // Set PORTB as output
    PORTB = 0x00; // Clear PORTB
}

void delay_us(unsigned int us) {
    // Implement a microsecond delay function
}

void IR_sendBit(int bit) {
    // Implement the function to send a single bit
}

void IR_sendByte(unsigned char data) {
    // Implement the function to send a byte (8 bits)
}

void IR_sendNEC(unsigned long data) {
    // Leading pulse
    IR_sendPulse(9000); // 9ms pulse
    IR_delay(4500); // 4.5ms space
    
    // Data: Address + Command (each 8 bits and their inverse)
    for (int i = 0; i < 32; i++) {
        if (data & 0x80000000) {
            // Send logical '1'
            IR_sendPulse(560);
            IR_delay(1690);
        } else {
            // Send logical '0'
            IR_sendPulse(560);
            IR_delay(560);
        }
        data <<= 1; // Shift to the next bit
    }

    // Final pulse to end
    IR_sendPulse(560);
    IR_delay(560); // Delay after the final bit; adjust as needed
}

void IR_sendPulse(unsigned int us) {
    // Pulse function
    PORTBbits.RB0 = 1; // Assuming IR LED is connected to RB0
    delay_us(us); // Pulse duration
    PORTBbits.RB0 = 0; // Turn off the LED
}

void IR_delay(unsigned int ms) {
    // Space function
    __delay_ms(ms); // Wait for the duration of the space
}

```



## Implementing the Sony SIRC protocol 

Implementing the Sony SIRC protocol  with a microcontroller involves sending and receiving infrared signals with a specific modulation and format. Sony's protocol typically uses a 12-bit, 15-bit, or 20-bit data format consisting of a 7-bit command and a 5-bit device address (for the 12-bit version) and may include extended versions for more devices or commands.

### Sony Protocol Basics

* Carrier Frequency: 40 kHz
* Bit Encoding:
    * '0' bit: ~600μs pulse followed by ~600μs space
    * '1' bit: ~1200μs pulse followed by ~600μs space
    * Start Bit: There is no explicit start bit in the Sony protocol; the transmission starts with the first bit of the message.
    * Message Frame: Consists of a 7-bit command followed by a 5-bit device address for the 12-bit version, with longer versions adding additional command or address bits.

#### Implementing Sony Protocol Transmission

To transmit a Sony protocol signal, you need to modulate the IR LED at a 40 kHz carrier frequency and follow the timing for '0' and '1' bits as specified.

Function to Send a Sony IR Command

Here is a simplified example function for sending a 12-bit Sony command. This example assumes you're familiar with setting up your microcontroller and configuring the necessary pins for output.

```cpp 

#define IR_LED PORTBbits.RB0  // Assuming the IR LED is connected to port RB0

void delay_us(unsigned int us) {
    // Implement a microsecond delay function based on your system clock
    // This function is highly dependent on the clock frequency of your PIC
}

void sendSonyCommand(unsigned int command, unsigned char device) {
    unsigned long data = (device << 7) | command;  // Construct the 12-bit message
    data &= 0xFFF;  // Ensure it's only 12 bits

    for(int bit = 0; bit < 12; bit++) {
        IR_LED = 1; // Turn on the IR LED
        delay_us(600);  // Basic pulse duration for both '1' and '0'

        if(data & (1 << (11 - bit))) {  // Check if the current bit is 1
            delay_us(600);  // Extend the pulse for a '1' bit
        }

        IR_LED = 0; // Turn off the IR LED
        delay_us(600);  // Inter-bit space
    }
}

```

#### Implementing Sony Protocol Reception

Receiving and decoding the Sony IR protocol involves measuring the duration of incoming pulses and spaces to determine whether each bit is '0' or '1'. This can be more complex due to the need for precise timing and the handling of interrupts or polling to detect IR signal changes.

##### Steps for Receiving

* **Set Up an Interrupt**: Configure an interrupt on the pin connected to the IR receiver that triggers on both rising and falling edges.
* **Measure Pulse and Space Durations**: In the interrupt service routine, measure the time between edges to determine if the pulse or space corresponds to a '0' or '1' bit.
* **Decode the Message**: Once you have captured the entire message, decode it into command and device parts based on the Sony protocol specifications.

Implementing the reception and decoding part requires careful timing and might involve more advanced programming concepts like interrupts and timers.


## Implementing the RC5 IR protocol 

Implementing the RC5 IR protocol on a PIC microcontroller involves understanding the RC5 protocol's unique features, such as its Manchester encoding, bi-phase modulation, and the fixed bit length of the messages.

### Understanding RC5 Protocol

* **Bit Format**: RC5 transmits data bits using Manchester encoding, where each logical "1" is represented by a transition from low to high in the middle of the bit period, and a logical "0" is represented by a transition from high to low.
* **Frame Format**: Each RC5 code is 14 bits long, consisting of two start bits (both logical "1"), one toggle bit (changes state with each button press to indicate a new command), 5 address bits (to identify the device), and 6 command bits.
* **Carrier Frequency**: 36 kHz.

### Hardware Setup

The hardware setup remains similar to the basic IR setup described previously, with an IR LED connected to a PIC  output pin for transmission and an IR receiver module connected to an input pin for reception.

### Software Implementation

#### 1. Initialize the System
Initialize the system clock, configure I/O pins, and set up any necessary peripherals. Ensure your IR LED output pin is set for digital output and your IR receiver input pin is set for digital input.

#### 2. Transmitting RC5 Signals
To transmit RC5 signals, you need to generate Manchester encoded signals at the correct frequency. A simple way to do this is by using a timer to toggle the output pin at the correct intervals.

```c
// Define the carrier and half-bit durations
#define CARRIER_FREQ 36e3
#define HALF_BIT_DURATION 889 // microseconds (1/36kHz * 32 cycles for RC5)

// Toggle the IR LED to generate the carrier frequency
void toggleIRCarrier(uint16_t duration) {
    while (duration > 0) {
        // Toggle IR LED on
        IR_LED_PIN = 1;
        __delay_us(13); // Duration for a 36kHz carrier
        
        // Toggle IR LED off
        IR_LED_PIN = 0;
        __delay_us(13); // Complete the cycle
        
        duration -= 26; // Adjust based on delay accuracy
    }
}

// Send a single bit using Manchester encoding
void sendRC5Bit(bool bit) {
    if (bit) {
        // Logical "1": Low to High transition
        toggleIRCarrier(HALF_BIT_DURATION);
        __delay_us(HALF_BIT_DURATION); // Delay without carrier for the second half
    } else {
        // Logical "0": High to Low transition
        __delay_us(HALF_BIT_DURATION); // Delay without carrier for the first half
        toggleIRCarrier(HALF_BIT_DURATION);
    }
}

// Send an RC5 command
void sendRC5Command(uint8_t address, uint8_t command, bool toggle) {
    uint16_t rc5Code = 0x3000 | (toggle << 11) | (address << 6) | command; // Start bits: "11", toggle bit, address, and command

    for (int i = 13; i >= 0; i--) {
        sendRC5Bit((rc5Code >> i) & 0x01); // Send each bit, starting from the MSB
    }
}
```

#### 3. Receiving RC5 Signals

Receiving and decoding RC5 signals involves measuring the time between transitions to decode the Manchester encoded bits. This can be more complex due to the need for precise timing and the handling of Manchester encoding.

You would typically use an interrupt to detect changes on the IR receiver input pin, measure the time between transitions, and then decode this into logical "0"s and "1"s according to the RC5 protocol's Manchester encoding rules.

#### Key Points

* **Timing is crucial**: Ensure your timing for the carrier frequency and bit durations are accurate.
* **Manchester decoding**: Implementing a state machine can be helpful for decoding Manchester encoded signals, especially for detecting the transitions that represent "0"s and "1"s.
* **Practice and Patience**: Debugging IR communication can be challenging. Start with simple commands and use tools like an oscilloscope or logic analyzer to help debug issues.


## Contribution

If you've found value in this repository, please consider contributing. Your support will assist me in acquiring new components and equipment, as well as maintaining the essential infrastructure for the development of future projects. [Click here](https://www.paypal.com/donate/?business=LLV4PHKTXC4JW&no_recurring=0&item_name=Your+support+will+assist+me+in++maintaining+the+essential+infrastructure+for+the+development+of+future+projects.+&currency_code=BRL) to make a donation or scan the QR code provided below. 

![QR CODE](../../../PIC16F/images/PIC_JOURNEY_QR_CODE.png)


## References

* [AN-1184 - Remote Control IR Receiver / Decoder ](https://www.renesas.com/us/en/document/apn/1184-remote-control-ir-receiver-decoder)
* [IR Remote Control Tool (NEC)](http://www.technoblogy.com/show?UVE)
* [Understanding IR Sensors and IR LEDs: Functions, Differences, and Applications](https://www.electronicsforu.com/technology-trends/learn-electronics/ir-led-infrared-sensor-basics)
* [NEC Infrared Transmission Protocol](https://techdocs.altium.com/display/FPGA/NEC+Infrared+Transmission+Protocol)
* [Infrared Transmit and Receive on Circuit Playground Express in C++](https://www.digikey.com/en/maker/projects/infrared-transmit-and-receive-on-circuit-playground-express-in-c/0cdcbf1a087949adbb912f81fa1bcccc)
* [NEC IR Remote Control Interface with 8051](https://exploreembedded.com/wiki/NEC_IR_Remote_Control_Interface_with_8051)
* [Sony SIRC Protocol](https://www.sbprojects.net/knowledge/ir/sirc.php)
* [Sony SIRC infrared protocol](https://physika.info/site/downloads/sirc.pdf)
* [Understanding Sony IR remote codes, LIRC files, and the Arduino library](http://www.righto.com/2010/03/understanding-sony-ir-remote-codes-lirc.html)
* [Philips RC5 Infrared Transmission Protocol](https://techdocs.altium.com/display/FPGA/Philips+RC5+Infrared+Transmission+Protocol)
* [The Philips RC5 IR Remote Control Protocol](http://www.pcbheaven.com/userpages/The_Philips_RC5_Protocol/)
* [How does the remote control work? Explained](https://lookin-home.medium.com/how-does-the-remote-control-work-explained-564bc7cd0291)
* [Codes for IR Remotes](https://tasmota.github.io/docs/Codes-for-IR-Remotes/)
* [RC5 remote control with PIC12F629](https://www.picbasic.nl/frameload_uk.htm?https://www.picbasic.nl/rc5_remote_uk.htm)
* [NEC Protocol IR (Infrared) Remote Control With a Microcontroller](https://pic-microcontroller.com/nec-protocol-ir-infrared-remote-control-with-a-microcontroller/)
