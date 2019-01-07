/*
mux_NoteOnOff by Jonathan Kayne, December 2018
This module handles the MIDI command data, specifically the Note On and Off commands.
When the 4 most significant bits [23:20] are 1000, it is Note OFF, so output a zero,
otherwise pass through the note data [15:0] (pitch and velocity)
*/
module mux_NoteOnOff(MIDI_data_in, MIDI_data_out);

	input [23:0] MIDI_data_in; //24 bit MIDI Data
	output reg [15:0] MIDI_data_out; //16 bit Note and Velocity Data
	reg Invalid = 1'b0; //holder for the invalid data
	
	//If the control bits are 1000, the command is MIDI Note OFF, set output to 0
	//If the control bits are 1001, the command is MIDI Note ON, pass through pitch and velocity
	always @ (MIDI_data_in) 
	begin
		case(MIDI_data_in[23:20])
			4'b1000: MIDI_data_out <= 16'b0;
			4'b1001: MIDI_data_out <= MIDI_data_in[15:0];
			default MIDI_data_out <= 16'b0; //ignore any other signal
		endcase
	end
	
endmodule 