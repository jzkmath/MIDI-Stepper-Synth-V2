# MIDI-Stepper-Synth-V2
This is the Version 2 of my MIDI Stepper Synth. The key differences between this and Version 1 is
that this version uses the Terasic DE0-nano (Cyclone IV) FPGA as the controller instead of Arduino.
The key advantage to doing so is that an FPGA can execute commands at the same time instead of sequentially.
This also allows for a better understanding of how MIDI actually works, because the MIDI has to be decoded manually
instead of using a MIDI library.

This project is being performed at the Virginia Tech AMP Lab, and the project can be seen [HERE](https://sites.google.com/a/vt.edu/amp_lab/projects/stepper-synth-v2).

**Please use the project page to see the BOM and all information on this project!!!**

Since MIDI uses a specific type of UART, the FPGA will take the serial data and convert it to parallel, as a 3 byte register.
Once this is done, the message is decoded such that the stepper motors react accordingly. 

## Basic MIDI Layout
The 3 byte MIDI Message is as Follows:
**1XXXCCCC 0NNNNNNN 0VVVVVVV**
- **X** - MIDI Command. This is 1000 for Note OFF, and 1001 for Note ON.
- **C** - MIDI Channel. 
- **N** - MIDI Note. This is the pitch that is specified. 60 for example is Middle C or C4.
- **V** - MIDI Velocity. This is similar to volume.

The general idea is that we want to turn the MIDI value into a stepper speed. To do this, we use a
similar method to how version 1 handles this, except this time we use clock cycles instead of time.
The DE0-nano has a 50 MHz clock, so we can generate a square wave at a specific frequency by counting
a certain number of clock cycles and toggling the state of a pin. 
The code simply takes the MIDI note value and converts it to the corresponding number of clock cycles
needed to do so.

In addition to the functions of version 1, version 2 also uses the velocity information to control 
how many steppers turn. The higher the velocity, the more stepper motors turn on (ranging from 0-4)
This is how the array of floppy drives work on the popular "Floppotron" on YouTube.

## Block Diagram
![Block Diagram](https://sites.google.com/a/vt.edu/amp_lab/projects/stepper-synth-v2/Stepper%20Synth%20Block%20Diagram.jpg?attredirects=0)

## Principle of Operation
![FSM](https://sites.google.com/a/vt.edu/amp_lab/projects/stepper-synth-v2/FSM.png?attredirects=0)

The first thing that must be done to convert MIDI into stepper music is that we need to decode the MIDI signal. MIDI uses 31250 baud UART (Universal Asynchronous Recieve Transmit) to send an recieve data. This is a form of serial, so we need to load this into a register to act upon with combinational logic. To do this, we use a Finite State Machine, or FSM with two states; Idle and Read. 
In the Idle state, the Rx line is high. When a device wants to send a message, the Rx line is dropped low. This is known as the start bit and the actual data is the 8 bits that follow, then the line goes high again (called the stop bit).

Knowing this, we can use the start bit as a means to change to the read state. 

In the read state, we want to look at the Rx line in the middle of each bit and shift that bit into our register. To do this, we count a certain number of clock cycles to get to the center of the bit. Given that the DE0-nano has a 50MHz clock and MIDI is 31250 baud, that means that it takes 800 clock cycles to get to the center of a bit, and 1600 clock cycles to go from center to center.

When the start bit is detected the read process is as follows:
1. count 800 clock cycles to get to the center of the start bit
2. count 1600 clock cycles to get to the center of the data bit
3. shift in the value of the Rx line
4. repeat steps 2 and 3 a total of 8 times
5. output the shifted value
6. wait for the Rx line to go high (stop bit detected) and go back to the Idle state.

Once we do that, we have our byte of data. Knowing that MIDI is 3 bytes of data, we take the byte and shift it into a larger, 3 byte register. After that, we can use combinational logic to control the stepper motors.

MIDI has a byte of control information (Command and Channel) and two bytes of data (Pitch and Velocity). We want to use the first byte to properly route the last two bytes appropriately. To do this, we have a single data router module and register modules for each channel. The registers have an enable and clear control signal and will either load or clear their contents depending on which input is pulled high. The second and third bytes are connected to the inputs of all the registers via a common bus and the first byte is used by the router module to control which register gets enable or clear pulled high. Note on (1001) or Note Off (1000) determines whether the register is enabled or cleared, and the channel determines which channel this happens to.

Once the register has the data, we need to convert the pitch into clock cycles. We look at the pitch value and corresponding frequency. We then figure out how many clock cycles elapse in half the period of the note. We do half because we want to create a square wave, which has a 50% duty cycle.

Using the converted value, we have a module count up to that value and then toggle the state of the pin. This is the equivalent to the "Blink without delay" sketch that is used in Arduinos (except for FPGAs).

Finally, we use the velocity value to determine how many stepper motors get that signal, which can be anywhere between 0 and 4.

## Credits
The basic UART decoding Verilog code is based off code provided by Electronoobs, modified to be more stable and work with MIDI.

Special Thanks to Robert Perkel and Bob Lineberry for helping with this project and providing assistance with this.
