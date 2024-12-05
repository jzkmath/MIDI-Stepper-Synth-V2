# MIDI Stepper Synth V2

## By: Jonathan Kayne, Virginia Tech Class of 2021

![image1](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image1.jpg)

![image6](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image6.jpg)

## Project Overview

This will be a continuation of a project I designed in the spring of 2018 on my own. The stepper synth uses MIDI data to "Play" stepper motors. Stepper motors often create a hum that is dependent on the speed that the motor is spinning at. By writing music and sending it to the stepper synth, you get a song. The original stepper synth used 4 NEMA-17 Bipolar stepper motors, an Arduino Uno, and a CNC shield to drive the steppers.

This design works, but can be improved by adding more steppers and other instruments. Furthermore, use of an FPGA will allow for a faster processing time and more stable MIDI processing.

Optionally, an array of LEDs could be used with some filtering to light up depending on the frequency being played at any time.

## Tasks

* Choose appropriate FPGA

* Come up with a plan for the program.

## Educational Value Added

I have very little experience in FPGAs and verilog. Doing this project will allow me to learn procedural verilog as well as get a more in depth view of the MIDI protocol.

## Design Decisions

The MIDI stepper Synth will use an array of 8x4 Bipolar stepper motors (likely NEMA 17). These will be broken into 8 MIDI channels with 4 motors per channel. Use of 4 stepper motors will allow for variation in volume level, by changing the number of motors running.

## Design Misc.

Other information about the design, parts used, etc.

* The stepper motors are driven by the Allegro A4988 Stepper Motor driver module. These drivers contain two main control pins; Step and Direction. Direction controls whether the motor spin clockwise or counterclockwise, and Step advances the motor forward by 1 step upon the rising edge of a pulse signal. The frequency of the pulses sent to the step pin control the speed at which the motor turns. It just so happens that the frequency also corresponds to the audio tone that the motor produces. For example, if I were to put a 440 Hz square wave into the step pin, the stepper would produce an A4 note (440 Hz is a common frequency used for instrument tuning!).
* Musical Instrument Data Interface (MIDI) is essentially a version of serial (RS232) at a specific baud rate. Within the protocol, there are two messages that we are concerned with; "note on" and "note off". These messages are 3 bytes long, and contain the control signal, the channel, the note value (frequency) and the velocity (volume).
* The general idea for what the FPGA needs to do is to take the midi data and produce a clock signal whose frequency is dependent on the note value. These signals need to be independent of each other and only get changed when another MIDI message overwrites it, so a note will stay the same until either a new note value is given or the note off message is received.

## Parts

* 32x NEMA 17 Stepper Motors
* 32x A4988 Stepper Motor drivers
* FPGA
* 3.3v to 5v level shifter (for communication between the FPGA and A4988)

## Steps documenting your design process

### Thing 1

The general idea of what this device does is takes MIDI data and converts that into a pulse whose frequency matches that of the stepper motor. To do this, the MIDI must first be interpreted and acted on accordingly.

MIDI is a special version of serial communication (RS232). It runs at 31250 baud.

MIDI will hold the signal high until a message needs to be sent. When this occurs, the line is dropped low for a single bit. This is called the start bit.

The MIDI messages we are interested in are 3 bytes in length. The Message is as follows: "CCCCNNNN 0KKKKKKK 0VVVVVVV" where

* C = Command; 1000 = Note OFF, 1001 = Note ON
* N = Channel; ranging from 0-15, for channels 1-16
* K = Note Value; the value 60 corresponds to C4 (middle C)
* V = Note Velocity; how loud the note is

The note value will drive the frequency of the pulses for a respective channel. The velocity will control how many stepper motors receive that pulse, where 0 = none, 1-31 = 1 motor, 32-63 = 2 motors, 64-95 = 3 motors, 96-127 = 4 motors. This might be changed if the range is too broad. It should be such that the motors respond to certain dynamic levels; from pianissimo (pp) to fortissimo (ff)

A midi channel does not change its value until another message overwrites it. So if a note on message is sent, that note stays on until either a new note on changes the value (creating a slur) or a note off message is sent.

The FPGA will have registers that hold the current note and velocity values for each channel. The data will come from a multiplexer that is controlled by the N bits. This is so the data that is loaded in can be routed to the appropriate register.

In the event of a note off message, the multiplexer will output a zero for both note and velocity.

If at all possible, an enable timeout feature should be implemented for the stepper motor control. The A4988 has an enable line that can be used to enable/disable the steppers. When enabled, the steppers have current supplied to them, which causes them to heat up (and waste energy!). When the device has been inactive for a certain amount of time, pull the enable line high.

### Thing 2

Information on the A4988 Stepper Driver. Here is a picture of the pinout for the A4988:

![image32](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image32.jpg)

The ENABLE line enables the driver when it is set to a logic low.

MS1-3 are the Microstepping mode controls. You can increase the resolution by changing the state of these pins (full step, half, quarter, eighth, and 16th). This doesn't matter for this project so they will be all driven low (full step mode). 

### (Preliminary Schematic)

**12/7/18:**  The schematic and board were created in Autodesk Eagle. The schematic and board are as follows:

![image35](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image35.jpg)

The 47uF capacitor is there to prevent large voltage spikes from damaging the motor drivers. Looking at the Arduino CNC shield showed that each driver got its own capacitor.

![image34](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image34.jpg)

The 6N138 is an optoisolator IC chip. MIDI uses a 5V communication method while the DE0 nano uses 3.3V. It is common to use an optoisolator to isolate the MIDI signal between the devices. It should also be noted that the ground connection on the DIN connector is left floating to prevent ground loops from occurring along the shield of the MIDI cable. The diode is for reverse polarity protection. The 4.7k resistor acts as a bleed resistor. This is due to the fact that stray charges can build up on the phototransistor, which can increase the propagation delay. The resistor fixes this. 

This is based off a tutorial by ["Notes and Volts" on YouTube.](https://www.youtube.com/watch?v=0L7WAMFWSgY)

![image39](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image39.jpg)

