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

This uses the LT1076 as a buck converter for converting the 12V to 5V to power the DE0 nano FPGA.

![image37](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image37.jpg)

## Verilog Works!
**12/13/18** - The Verilog code has been created and tested and now successfully works!

The main challenge to getting this to work was in the MIDI Shift Register, as MIDI uses a form of UART (Universal Asynchronous Receive Transmit). This means that there is no clock to keep things in sync. The solution is to use what is known as a Finite State Machine (FSM). The way the shift register pulls in data is done by creating a clock that is 16x faster than the specified baud rate (in this case 31250 bps) and then having two states: Idle and Read. The module sits in the Idle state until the serial line falls low, indicating the start bit. This puts the module into the read state. 

In the read state, the module counts 8 ticks (the clock that's 16x faster than our baud rate). At this point we are in the middle of the start bit. After this, we count another 16 ticks and record the value of the serial line. This is repeated for all the 8 bits, where the bits are shifted into a register. Afterwards, the module goes back into the idle state. 

Since there are 3 bytes of MIDI data, there is another shift register that shifts each byte in as it is received.  

After the bits are properly shifted in, the values are processed and sent where they need to be. The first thing that is analyzed is the command, which is either a note on (1001) or a note off (1000). The is a 2x1 multiplexer that either passes the pitch and velocity through if the value is a note on, and passes a zero through if the value is note off or anything else.

After that, the pitch and velocity go into a demultiplexer that sends the pitch and velocity to their intended MIDI channel. The specified channel is located in the last 4 bits of the first byte.

For each channel there are 3 modules: a pitch value converter, a frequency modulator, and a velocity controller. The pitch value converter takes the MIDI note value and converts it to a number that equates to the number of clock cycles needed for half the period of the intended frequency, since we want to produce a square wave. Since the clock is 50 MHz, you can calculate the number of clock cycles needed by 50 MHz / (2 * pitchFrequency). 

The converted value is then sent to the frequency modulator, which simply counts up to the specified number of clock cycles and toggles the state of a register. (essentially this is the same code used to blink an LED on an FPGA)

This signal is then sent to the velocity controller, which passes the signal to 0, 1, 2, 3, or 4 stepper motors depending on the velocity value given, where 0 is none, 1 - 31 is one motor, 32 - 63 is two, 64 - 95 is three, and 96 - 127 is four (all).

The block diagram is as follows. I have also added the verilog code, which is in the "files" section!

![image41](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image41.jpg)

![image40](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image40.jpg)

![image45](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image45.jpg)

I also plan on redoing the PCB design to make it more modular and so that it can handle the high current that running 32 steppers causes. There will be two modules: a Stepper Channel Module and the Controller Module. The Stepper Channel module will drive 1 channel of 4 stepper motors. There will be 8 of these. The Controller module will hold the MIDI interface and the DE0-nano interface with the buck converter.   

## Schematics 2.2 

**12/21/18** - created new schematics and PCBs to be used in the stepper synth, as well as updated the BOM. I used an online software called EasyEDA to design the boards. It has a much simpler user interface and integrated libraries that make it much easier to use than Eagle. Also, it has a built in export to Gerber option that makes sending to board houses easier. I will be using SeeedStudio to make the boards by recommendation of peers and the fact that the AMP lab has prior experience with them. Here are some pictures of the new schematics and PCB layouts:

![image43](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image43.jpg)

![image13](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image13.jpg)

![image21](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image21.jpg)

![image50](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image50.jpg)

## Schematics 2.3

**1/13/19** - There were some issues with the design of the two PCBs, so they were redesigned in Eagle. The main issue was the fact that the buck converter used an odd IC chip. In the redesign a chip made by TI was used, and the parts were selected using TI's web-bench. This also gave me a chance to learn how to make my own libraries in Eagle, as importing some of the components from Digikey can look odd in schematic view. Furthermore, the motor ground and digital ground are isolated in the new Motor PCB, being connected via a ferrite bead. Also, the boards have a uniform size in millimeters, so layout is simpler.

![image31](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image31.jpg)

![image51](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image51.jpg)

![image42](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image42.jpg)

![image11](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image11.jpg)

## BOM Update and MIDI Creation Workflow

**1/16/19** - The mechanical BOM was created and I have also made a few MIDI files for the synth. I thought I would go over my procedure for creating MIDI files and parsing them to the stepper synth. The two programs I use for this is MuseScore 3 and Ableton Live 9. MuseScore is a free, open-source music notation software that I have been using for about 8 years for both music composition and band sheet music creation. 

The general idea is that I want to create 8 staves each with a monophonic track. For those who don't read music, stave is the plural of a staff. The staff consists of 5 horizontal lines and is where we place notes in music. The head of the note lies either on a line or between the lines and tells you the pitch depending on the clef (treble, bass, alto or tenor) and the duration depending on the shape (whole, half, quarter, eighth, etc). The term monophonic means one note at a time. Examples of monophonic instruments include most wind instruments like a saxophone (which is the best instrument ever and is why I play it ;) ). The opposite of monophonic would be polyphonic, which would be like a piano, which can play multiple notes simultaneously (referred to as chords). 

The way I normally get the songs is by going to MuseScore.com and finding a song premade and then modifying it to work for my synth. Often there will be chords in the music, so what I often do is move the chord to an empty staff and use the explode command (Tools > Explode) and the chord will be split across the empty staves below. After creating the song, I export the song as a MIDI file (.mid) and then move onto Ableton. Note that I could just use the jack plugin that is built into MuseScore to play the MIDI file to the synth, but I find that it doesn't send the Note Off command if you press pause which Ableton does.

Ableton Live is what is known as a Digital Audio Workstation (DAW), and is one of the popular DAWs used in the music production industry along with FL Studio and Pro-Tools. In Ableton, I created a template called "StepperV2.als" that contains 16 MIDI tracks. The first 8 hold the MIDI data and send the MIDI to the stepper synth. The other 8 have a simple saw-tooth instrument attached and simply play what is in the first 8 tracks. These are only used for testing and are muted when the synth is playing. Channels 1-8 will have the "MIDI To" set to the USB MIDI controller and their respective channels set. When I want to create a song, I simply drag the MIDI file created in MuseScore into the timeline and I am good to go! I should also point out that I have been putting the converted MIDI files onto the GitHub for this project. Below is a screenshot of playback of "Enter Sandman" on Ableton. Why "Enter Sandman"? Because this is Virginia Tech!

![image19](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image19.jpg)

## Mechanical Assemblies

**1/28/19** - It seems that most of the components are in to assemble the Stepper Synth, except for the PCBs and the stepper Motors. I decided that I want to discuss some of the mechanical build for the instrument.

I designed the assembly in SolidWorks Student Edition 2017, as I have a lot of experience with this CAD software (and a CSWA in it too). Being that this is meant to show off the stepper motors, I wanted to ensure that the motors and circuitry is visible to the public. This was achieved by using clear acrylic sheet and aluminum extrusions. By using 2020 aluminum extrusions, I can maximize rigidity while minimizing the overall weight. I should point out that Stepper Motors are heavy items, so 32 of them makes for a rather heavy instrument (about 40 pounds!). Because of this, I decided to put horizontal braces between the motors to improve rigidity. I just didn't feel comfortable having 40 pounds of weight on a single panel. Also, adding these braces adds contact area to the motors which helps with acoustic performance!

On the other side, I put another acrylic panel with holes and standoffs for the PCBs. Honestly I like circuit boards and simply wanted to show off my soldering and PCBs that I designed! Also, I think it adds to the vibe I am trying to create with the whole aesthetic of the instrument. Plus, the LED's on the DE0-nano FPGA would be visible.

In the center of the assembly between the boards and motors is two cross-braces that are meant to be mounting points for the 9 power supplies that are needed to power each PCB. It also adds points for creating wiring harnesses. I really want the wiring to look neat and professional. (Did you know I have the nickname "Ziptie"?)

![image2](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image2.jpg)

![image14](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image14.jpg)

![image20](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image20.jpg)

## Begin Assembly!
    
**2/1/2019** - The PCBs and electrical components came in, so I was finally able to start assembly of the Synth. To make sure that the power supplies would work with the board, we only purchased two and I assembled one of each board. After building the PCBs, we hooked up the power supplies, installed the A4988 stepper driver modules, and attempted to adjust the current on the board, which was much more difficult with these cheap boards than expected. Normally, you can check the current limit by adjusting the potentiometer and connecting a multimeter to your screwdriver as you adjust the voltage. There are two sense resistors on the module, and the voltage you want to see is as follows:

![image5](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image5.jpg)

We weren't able to get the multimeter to give us an accurate voltage measurement, but fortunately it is not very important, because these stepper motors don't draw a lot of current unless they are put under a load, which they won't. Therefore we just set the current limit to the max.

Once we set up the connections, I found that it wasn't working in a coherent manner. After looking at the MIDI line through an oscilloscope, I found that Ableton was the culprit, not the stepper synth. The FPGA expects only note on or note off messages, so anything else could make the system unstable. I found that it was sending a MIDI clock message, which was covering up the important information. When using Ableton, in the device configuration menu, only the output "Track" should be on. "Sync" and "Remote" should be off and the Input disabled. Doing this fixed it and I managed to get the synth to play "Flight of the Bumblebee" and a little of the "Imperial March" to test.

Now that we know that the power supplies work, and that a single channel works, the rest of the power supplies can be purchased and the boards assembled. I forsee this machine being fully functional in the upcoming weeks, once the mechanical parts come in!

![image36](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image36.jpg)

![image8](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image8.jpg)

![image25](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image25.jpg)

![image10](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image10.jpg)

![image15](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image15.jpg)

## More Soldering and Assembly Difficulties

**2/2/2019** - Work was really slow today so I got to leave a little bit early. I used the extra time to solder up the 7 remaining Stepper PCBs. I managed to get into a groove and all of them assembled well. The only real hiccup was that one of the 47uF capacitors ended up having a lead get pulled out. It was probably my fault, but when removing electrolytic capacitors from the tape real, don't pull on them like I did, or the leads might get pulled out. For that one capacitor, I had to use one of the capacitors from the component cabinets as a substitute. I put that capacitor in channel D so that it would be used the least (channel A gets used for all notes, and D is used only for notes with a velocity of 96-127). 

One other thing that I (and Dr. Lineberry) should point out is that I should have ordered header pins with the zigzag bend at their base so that they stay in the board when you flip it over to solder. It made assembly much more difficult. I would use my brush to keep the PCB flat as I soldered a single pin, and then use my finger to readjust the header so that its flat against the board. 

Another thing I wanted to mention was that I attempted to figure out the cable length for the ribbon cables used between the boards. SolidWorks has this nifty tool called routing, where you can route wires in the assembly and then "flatten" the cable to get cable lengths. Unfortunately my computer was having a hard time doing this and the connectors weren't behaving as expected. The videos showing the process make it look super easy, but it just wouldn't work. Therefore, I think it would be better for me to just wait until my mechanical parts come in and figure out cable lengths the old fashioned way. If I really wanted to, I could print out the DXF of the back panel layout as a mockup and figure out the lengths that way.

Either way, I have all the boards soldered, so now I can get to the mechanical build.

![image9](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image9.jpg)

## All 8 Channels Fixed!

**2/8/2019** - I finally managed to get all 8 channels working! Originally, the FPGA could only handle a single channel, and running any more channels would cause it to miss notes and eventually freeze/glitch out. Ultimately, the problem had to do with my baud-rate generator. I simplified the design, which by doing so greatly improved the accuracy of the Serial to Parallel shifter used to decode the MIDI. The original design used a clock rate 16 times faster than the baud and would count 8 "ticks" to get centered in the message. Since that was driven by the clock anyways, I skipped a step and just had it count an equivalent number of clock cycles (800 clock cycles is half the period of a 31250 baud UART message). This completely fixed the decode issue!

Another thing I did was redesign the combinational logic the went on in the rest of the system. The reason was so that it would be easier to convert to a polyphonic setup in the future. Instead of using multiplexers and demultiplexers for controlling signal direction and note on/off control, I have a Data Router module and Channel Registers. Each note can be stored in a register that has an enable and reset control built in. The note and velocity data is put on a common bus and the Data Router sets the specific enable or reset line high to transfer (or clear) the intended register. The reason for doing this is that for polyphony (playing more than one note at a time on a single channel) I will need to assign a note to a single vacant register. By adding a little bit more logic to the data registers, we can ensure that each note gets sent to the first vacant register. You can ensure this by checking the data bus and the contents of the register. If they match, then the note has been added. This logic can be fed into an AND Gate with the clear signal to do the same for a note off command. The white board drawing below shows the basic block diagram for this.

The other reason for implementing the new combinational logic was to ensure that the Pitch and Velocity propagate through the FPGA equally, and stay in sync. Most of the time, the velocity goes straight through the module, but now it has to pass through a bit slower so that it triggers at the same time as the note is being played.

![image49](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image49.jpg)

![image22](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image22.jpg)

![image29](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image29.jpg)

## Multicolor 3D Printed Flags

**2/9/2019** - Something that I did for the original Stepper Synth V1 was that I added "Flags" to the shafts of the motors. The purpose was to highlight the motion of the motors. They were 3D printed on my Original Prusa i3 MK3 and had "JZK" (my initials) embossed into them. I now have the MMU2 (multi-material upgrade V2) installed on my machine, which allows me to print up to 5 colors per layer! Therefore, I redesigned the flags to have the VT (athletic) logo in maroon and orange to make the flags pop out! Also, the athletic logo looks cool and is easy to draw in CAD, unlike the other VT logo...

I also put in a split so that they can fit on the shaft easier with a press-fit, which was the challenge with the old version. Since they are small, a set of 32 only takes about an hour or two to print (which for multi color 3D prints is extremely fast) Essentially I drew in a sketch of the motor shaft and general contour and extruded it 5mm. After that, I used the "Sketch Picture" tool to place an image of the VT logo and traced over it. Then, I did a cut-extrude 0.4mm (about two layers on a 3D print). Finally I used the "convert entities" tool to copy the sketch of the logo in the recess, then extruded it back up again, but I disabled the "Merge Bodies" option. By keeping the extrude body separate, I could export the two as separate STL files and bring them into Slic3r Prusa Edition as a multi-material model. The logo will print face-down, so that the surface is smooth. Also, that surface will often create what is known as "elephant's foot", where the first layer creates a small lip due to it being squished against the print bed. I prefer having this over the print not sticking.

The picture shown might have the wrong colors, as I wasn't going for accuracy here (and I am colorblind) but I think this is close enough for you to get the idea. A great thing about filament is that they write the color on the spool so I can get my colors right!

![image12](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image12.jpg)

![image27](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image27.jpg)


## Full Test 1

**2/12/2019** - I decided to do a test with all 32 motors connected. The test went great and I can confirm that the system works as intended. The aluminum extrusions came in, but unfortunately the M3 screws I chose for mounting the stepper motors to the acrylic were just barely too long. This means that I have to order some shorter screws to mount the motors to the acrylic. The order should come in on Thursday, so I should be able to assemble on Friday!

Something Bob Lineberry and I discussed was the acoustic properties of my mechanical build. Bob was concerned that the acrylic might dampen the sound, but luckily I planned ahead with this. Most of the vibrations come off the side of the motors, and aluminum is an excellent material to amplify vibrations! It just happens that there are aluminum extrusions between every row of motors that transfers the vibrations to the chassis. I confirmed that the extrusion will work well by using a piece of scrap extrusion I found (left by the RoboGrinders likely). 

I also had one of the channels with the drivers upside down, so I accidentally fried a set of A4988 modules. Luckily, I has some spares and they are really cheap to replace. Nothing else was damaged luckily!

![image47](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image47.jpg)

![image28](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image28.jpg)

## Prototype Final Assembly

**2/15/2019** - The final assembly of the MIDI Stepper Synth V2 took place today (and a little bit of yesterday). Now that I had replaced the screws, which I found originally too long for the acrylic panels, I could begin the long and tedious process of attaching all 32 stepper motors to the acrylic panel with the 128 M3 screws needed. 

As noted in the last entree, there are aluminum extrusions between every row of the motors, to amplify sound, and because I was concerned about the weight of the stepper motors on the panel. It appears that my suspicions were correct about this, because the weight combined with me likely over-tightening the screws seemed to cause the panel to crack in some of the screw holes. I am not sure if the cracks will continue to spread or if this is a major concern, aside from cosmetic, but if it is, I can easily replace it with a panel of a different material such as Poly-carbonate (Lexan) or PETG, or similar clear material (if possible). Fortunately the way that the synth is built is such that removing the front panel can be done without the motors moving around too much. 

Prior to the mounting of the stepper motors, I screwed the aluminum extrusions together. I had thought I had gotten standard 2020 V-slot, such that I could use standard V-slot/T-slot nuts, but something was wrong with the nuts, or the extrusions, such that I couldn't just slide them in and twist. Instead, I would have to push the nuts in from the end of the extrusions and slide them into place and secure. It was more of a pain, but doable.

![image26](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image26.jpg)

Once the panel was attached to the frame, I went through and created a harness for each channel and labeled all the connectors with the label maker. Since there are 32 connectors, it would be easier to get the motors mixed up, so a nice label helps for serviceability in the future if that becomes necessary.

![image3](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image3.jpg)

After that, I mounted the 9 power supply bricks using zip-ties. There are two horizontal extrusions just behind the motors that allow for each end of the power supply to be secured. Having the power supplies like this also creates a "layer" that the motors can sit against should the front panel need to be replaced.

![image23](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image23.jpg)

Now onto the back panel. All the standoffs were installed on the acrylic. The interface board and FPGA were both mounted to the panel. Because I wanted users to see the PCBs, I had to install the boards upside down. The process for doing this was to plug in the motor cables, then the ribbon cable. I did this for channels 1, 3, 5 and 7 first, because those boards needed the power supply cable routed under the even channels (2, 4, 6 and 8), I plugged in the power supplies, then repeated for channels 2, 4, 6 and 8.  This was then followed by the ribbon cables and channel pairs being zip-tied. With all this wiring, good cable management is a must!

![image24](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image24.jpg)

After this, I did a test to make sure that my wiring was good before closing the case up, and the test was successful. I know that if I hadn't done this, Murphy's law would have made sure that it wouldn't work!

Seeing that it worked, I secured the back panel to the frame and secured all the wire harnesses and bundled up all the DC power supply cables. And that concluded the assembly of the MIDI Stepper Synth V2!

![image4](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image4.jpg)

![image18](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image18.jpg)

Now for the moment of truth. The first test of the fully assembled machine. As a first song, I felt it would only be fitting to play "First Steps/Pointless Machines" by Lena Raine from the video game "Celeste". Poetic, isn't it? Well let's just say that the type of feeling I got from the test was satisfaction, the very type you get from creating something awesome. That's the reason I like to create things and like engineering as a field. 

I will be working with some Music Tech Students to compose some cool music for this machine, as well as professionally record the songs I made for the synth.

One last thing I wanted to think about was that this machine is incredibly heavy (about 40-50 lbs). I think it would be a good idea to get a case for transport of the synth, as I don't want to carry this by the extrusions long distances. Also, that would be just asking for it to be dropped or something break due to stress in an unintended area. It's a musical instrument after all, so it should have a case!

## Begin Final Revision Assembly (2.4)

**2/18/2019** - it seems that the MIDI Stepper Synth V2 is at the point where we can consider it a complete product. After a discussion with Dr. Lineberry, we should start that process of constructing the Stepper Synth that I keep. I will need to test and see how much power that the synth Actually draws so that I can use a single power supply. I can also use parts that won't break in place of the cracked acrylic to ensure that the build is more successful. This would include different 2020 extrusions so that the T-slot nuts actually fit in the extrusion!

We will also be getting a tablet to go with the first Stepper Synth to be used to play music in the amp lab. Something like this should work well. We will also need to get a USB to MIDI adapter to communicate with the synth.

## Better MIDI parsing Software

**2/19/2019** - in preparation for the Stepper Synth becoming a display piece for the Amp lab, I decided to look into software that could play the stepper synth, and not require too much processing power. Also, I was having the issue of certain notes being missed, which I was fairly certain was because of the DAW, not the synth. 

The first thing I tried was using the built-in MIDI out that MuseScore 3 has. This confirmed my suspicions about it being software related, as all the notes were being played perfectly. The only problem with this was that MuseScore doesn't handle pausing very well, as it does not send a MIDI Note Off command to every channel when you press pause.

After some digging, I found a piece of software called "Notation Player 3" which has the single purpose of playing back MIDI files. Testing showed that this program worked perfectly for the job! It also showed me that I had a problem with my MIDI files in MuseScore, as there isn't an option to configure the MIDI channels in Notation. The fix was to open the Mixer window in MuseScore and make sure the MIDI channel numbers were set properly and then re-export the MIDI files.

## Power Supply Considerations and PCB 2.4

**2/24/2019** - Over the past few days, I have been doing some testing for the final revision of the stepper synth. In regard to the power supply, I hooked a single channel up to a power supply and measured the current draw under various notes and full velocity. The most I could get on average was a current draw of 450mA, which is a long shot from the 5A I was giving it. However, there is often a current spike that occurs when the stepper motor starts up, to overcome the inertia that is needed in the motion transient. By setting the power supply to OCP (Over Current Protection), I could see how much the maximum current is approximately. This gave us around 600mA needed. To be safe, I assumed that each channel needed 1A, so the closest power supply was a 12V, 10A supply. Just to be extra safe, I did some research to make sure that the power supply could handle back-EMF that might be generated by the motors. According to the manufacturer, the power supplies have protection (so they won't get damaged) and can handle 10% above their rating before the protection kicks in. They recomended that I have a Zener Diode attached to the motors, which luckily is built into the A4988 IC chips. I believe that the extra head-room in current for this supply should give us a big enough safety margin for the extraneous current spikes. 

I should also note that the A4988 has a built in over-current protection potentiometer that you set depending on the maximum current draw, which would include the motion transient. In short, I should be fine.

On another note, I worked on a new PCB design for the stepper synth, named V2.4. It is mostly the same, with the connectors and revisions to make assembly easier.

One of the most difficult things about the soldering of the boards was the pin headers. The headers have no kink in them, so you had to secure them while soldering otherwise they would fall out when you flipped them over to solder. I had remembered that the Digilent PIC32 dev boards that the students had been using for senior design projects had a 90 degree header that you had to solder in. I had also remembered that when I would have to solder the header in for a student(s), this issue was gone! This was because the pads on the board were in a zig-zag pattern that held the pins in through friction. After doing some digging, I found a way to do this in eagle. Simply offset each pad by 5 mils so that the pads are 10 mils apart on the y axis. The coordinates will be something like this: (0, -5), (100, 5), (200, -5)...

I ended up using the Sparkfun eagle library as a basis for this and modified it to work with my pin headers. 

The only other revision was that I changed the barrel connectors for a 4-pin mini DIN for the 10A power supply and added screw terminals for the motor board power supplies. Everything else, including the board size and mounting scheme remained the same. 

The change in power supply actually had a significant cost offset to the design, as now the whole device, including assembly and case is now the price of what the electronics were (about $800 total now)

(Note that the below 3D renders were done in KiCAD, where I imported the Eagle files and assigned STEP models to the board parts. Eagle is rather terrible at 3D exporting, but KiCAD is awesome at it)

![image7](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image7.jpg)

![image48](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image48.jpg)

![image46](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image46.jpg)

![image16](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image16.jpg)

## AMP Lab Display Unit (Tablet Mount)

**2/16/2019** - Added a tablet to the Display Unit. It is a Chuwi Hi8 Tablet, and runs full Windows 10. For $110, I am more than impressed by the performance, as it has a good display and relatively fast performance. I measured the dimensions of the Tablet with my calipers and 3D printed a mounting stand for the Stepper Synth. The holder has 3 Pieces of double-sized tape to cushion the tablet and hold it in place. I installed Notation Player 3 and loaded on the MIDI files. Testing shows that the tablet will work for the job. 

I also put on a wallpaper with instructions on how to use the stepper synth, and changed the account photo to a stepper motor. Now all that is needed is a USB-C hub so that I can charge the tablet and run the USB-MIDI adapter.

![image17](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image17.jpg)

## Final Assembly Complete

**3/15/2019** - Assembly of the final MIDI Stepper Synth V2 has been completed. This process took significantly longer than expected, mainly because of a delay in getting the polycarbonate panels cut. (Special thanks to the Robogrinders for helping get the panel cut!) Polycarbonate can be a bit tricky to cut because you cannot use a laser to cut it (it will catch fire if you do) and it has a tendency to melt onto milling bits if you don't use correct feeds and speeds. You need to cut with a slow speed and a fast feed (meaning that the bit should spin slowly and the toolhead should move fast) to prevent this from happening. Once the panels arrived, there were burs and chunks of polycarbonate that needed to be removed. A countersink drill bit along with a sharp xacto knife made quick work of this.

As for the PCB Assembly, the new features added in the 2.4 boards worked flawlessly. The only issue was that I chose the wrong hole size for the 4-position terminal block on the interface board, so I couldn't use that. Instead, I soldered a heavy gauge wire to the terminals on the DIN connector. The wire connected to the 8 pairs of wires that connect to each motor board.

Wire management was made significantly easier by putting twists in wire sets. I did this to all the motor cables by releasing two of the 4 wires (Blue and Red specifically) and putting a twist then re-connecting the dupont pins to their socket. This is something that I saw on all the motors on my Prusa i3 MK3 3D Printer and it eliminates the need for any zipties. I also did this twist to the power cables. I foresee someone talking about this method only being for signaling but I don't see why that would mean that I can't use it elsewhere in the design.

The use of metal corner brackets and true 2020 V-slot extrusions made for a frame that was rock-solid and I could properly tighten the nuts without risk of damaging the bracket or any other part. For the motors, I used an M3 and M5 washer on all the M3 screws so that the pressure was distributed on the panel to lower risk of cracking and I opted to not use any threadlocker and instead simply perform regular checks on the screw tightness. The motors were a rather tight fit so the horizontal extrusions do an excellent job of holding the motors to the panel even without mounting screws. The only hitch on this part was that one of the motors had a bad thread on one of the corners so I could only mount 3 of the 4 points on that one. This shouldn't be a problem aside from cosmetically standing out.

Once all the motors were mounted, I put a twist in each channel to hold the cables together. This meant I only needed a total of 3 zipties per channel; one at the beginning, one to adjust the length, and one at the end. Plugging the cables in was an incredibly easy task because of this, and final cable management required very little effort.

The end result was a very robust machine that weighs less (I don't feel like I am gonna break my back if I lift the thing for two seconds), is more modular and slightly louder. I think at this point I can call this project complete after I update the PCBs to fix the small mistake I made. I will also add a link to the YouTube playlist once I start publishing videos on the subject.

![image1](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image1.jpg)

![image6](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image6.jpg)

![image52](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image52.jpg)

![image44](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image44.jpg)

![image38](https://github.com/jzkmath/MIDI-Stepper-Synth-V2/blob/master/Project%20Documentation/image38.jpg)

## MIDI Stepper Synth V2 YouTube Playlist

I have started posting YouTube Videos of the MIDI Stepper Synth in action. The songs can be seen [HERE.](https://www.youtube.com/playlist?list=PL4FFrmT3l_b1w0-UKtJ3XjHV_M55FEpmH)
