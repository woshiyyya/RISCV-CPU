`include "defines.v"

module inst_rom(
	//input wire						clk,
	input wire							ce,
	input wire[`InstAddrBus]			addr,
	output reg[`InstBus]				inst
);

	reg[`InstBus]  inst_mem[0:1000];

	initial $readmemh ( "E:/Study/Codes/DATA/ls.data", inst_mem);

	always @ (*) begin
		if (ce == `ChipDisable) begin
			inst <= `ZeroWord;
	  	end else begin
		  	inst <= {inst_mem[addr>>2][7:0],inst_mem[addr>>2][15:8],
			  			inst_mem[addr>>2][23:16],inst_mem[addr>>2][31:24]};
		end
	end
endmodule