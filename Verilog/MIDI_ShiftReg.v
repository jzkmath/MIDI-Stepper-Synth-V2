module MIDI_ShiftReg(Clk, Rst_n, Rx, RxData);

/////////////////////////////////////////////////////////////////////////////////////////
input           Clk             ; // Clock
input           Rst_n           ; // Reset
input           Rx              ; // RS232 RX line.
output reg [23:0]   RxData      ; // Received data
/////////////////////////////////////////////////////////////////////////////////////////
wire          	RxDone; // Reception completed. Data is valid.
wire           tick; // Baud rate clock
wire 				RxEn;
wire [6:0]      NBits;
wire [15:0]    	BaudRate; //328; 162 etc... (Read comment in baud rate generator file)
wire [7:0] Rx_in; //Rx Data from MIDI_rx
wire is_receiving, recv_error;
/////////////////////////////////////////////////////////////////////////////////////////
assign 		RxEn = 1'b1	;
assign 		BaudRate = 16'd50; 	//baud rate set to 31250 for MIDI. Why 100? (Read comment in baud rate generator file)
assign 		NBits = 4'b1000	;	//We receive 8 bits 
/////////////////////////////////////////////////////////////////////////////////////////

//byte shift register
always @ (negedge RxDone)
begin
	RxData <= {RxData[15:0], Rx_in};
end 


//Make connections between Rx module and TOP inputs and outputs and the other modules
MIDI_rx I_RS232RX(
    	.Clk(Clk)             	,
   	.Rst_n(Rst_n)         	,
    	.RxEn(RxEn)           	,
    	.RxData(Rx_in)       	,
    	.read_enable(RxDone)    ,
    	.Rx(Rx)               	,
    	.Tick(tick)           	,
    	.NBits(NBits),
    );

//Make connections between tick generator module and TOP inputs and outputs and the other modules
MIDI_BaudRate_generator I_BAUDGEN(
    	.Clk(Clk)               ,
    	.Rst_n(Rst_n)           ,
    	.Tick(tick)             ,
    	.BaudRate(BaudRate)
    ); 



endmodule
