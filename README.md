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

## Credits
The basic UART decoding Verilog code is based off code provided by Electronoobs, modified to be more stable and work with MIDI.

Special Thanks to Robert Perkel and Bob Lineberry for helping with this project and providing assistance with this.
