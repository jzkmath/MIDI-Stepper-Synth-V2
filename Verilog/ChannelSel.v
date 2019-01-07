/*
ChannelSel by Jonathan Kayne, December 2018
This module acts as a demultiplexer. It routes the MIDI data [15:0] (pitch and velocity) to 
their appropriate channel. The Select bit is split up in this module, but it is [19:16] of the MIDI message.
*/
module ChannelSel(MIDI_data_in, Sel, Ch0, Ch1, Ch2, Ch3, Ch4, Ch5, Ch6, Ch7, Clk);
	input [15:0] MIDI_data_in;
	input [3:0] Sel;
	input Clk;
	output reg [15:0] Ch0, Ch1, Ch2, Ch3, Ch4, Ch5, Ch6, Ch7;
	reg Invalid = 1'b0; //error register in case it doesn't go to the correct location.
	
	always @ (posedge Clk) 
	begin
		case (Sel)
			4'b0000: Ch0 <= MIDI_data_in;
			4'b0001: Ch1 <= MIDI_data_in;
			4'b0010: Ch2 <= MIDI_data_in;
			4'b0011: Ch3 <= MIDI_data_in;
			4'b0100: Ch4 <= MIDI_data_in;
			4'b0101: Ch5 <= MIDI_data_in;
			4'b0110: Ch6 <= MIDI_data_in;
			4'b0111: Ch7 <= MIDI_data_in;
			default Invalid <= 1'bx;
		endcase
	end
	
endmodule 