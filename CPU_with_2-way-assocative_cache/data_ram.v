`include "defines.v"

module data_ram(

	input wire							clk,
	input wire							enable,
	input wire							we,
	input wire [29:0]					addr,	
	input wire [255:0]					wb_data,

	output reg 							ready_o,
	output reg [255:0]					block_o
);
	reg[255:0]		memory[1000];

	always @ (posedge clk) begin
		if(enable == `ChipDisable) begin
			block_o <= 256'b0;
			ready_o <= 1'b1;
		end else if(we == 1'b0) begin   //read
			block_o <= memory[addr];
			ready_o <= 1'b0;
		end else if(we == 1'b1) begin   //write
			memory[addr] <= wb_data;
			block_o <= 256'b0;
			ready_o <= 1'b0;
		end
	end		

endmodule