`include "defines.v"

module ex_mem(

	input wire						clk,
	input wire						rst,
	input wire[5:0] 			 	stall,
	input wire[`AluOpBus] 			ex_aluop, 	//new

	input wire[`RegAddrBus]       	ex_wd,
	input wire                    	ex_wreg,
	input wire[`RegBus]			  	ex_wdata,

	input wire						ex_mem_ce, 	
	input wire[`RegBus]				ex_mem_addr,
	input wire[`RegBus]				ex_mem_data,
	
	output reg[`AluOpBus] 			mem_aluop,   //new
	output reg[`RegAddrBus]      	mem_wd,
	output reg                   	mem_wreg,
	output reg[`RegBus]			 	mem_wdata,

	output reg 						mem_mem_ce,
	output reg[`RegBus]				mem_mem_addr,
	output reg[`RegBus]				mem_mem_data
);


	always @ (posedge clk) begin
		if(rst == `RstEnable) begin
			mem_wd 			<= `NOPRegAddr;
			mem_wreg 		<= `WriteDisable;
			mem_wdata 		<= `ZeroWord;		
			mem_mem_ce 		<= `ZeroWord;
			mem_mem_addr 	<= `ZeroWord;
			mem_mem_data	<= `ZeroWord;
			mem_aluop 		<= `ZeroWord;
		end else if((stall[3] == `Stop) && (stall[4] == `NoStop))begin
			mem_wd 			<= `NOPRegAddr;
			mem_wreg 		<= `WriteDisable;
			mem_wdata 		<= `ZeroWord;
			mem_mem_ce 		<= `ZeroWord;
			mem_mem_addr 	<= `ZeroWord;
			mem_mem_data	<= `ZeroWord;
			mem_aluop 		<= `ZeroWord;
		end else if(stall[3] == `NoStop)begin
			mem_wd 			<= ex_wd;
			mem_wreg 		<= ex_wreg;
			mem_wdata 		<= ex_wdata;		
			mem_mem_ce 		<= ex_mem_ce;
			mem_mem_addr 	<= ex_mem_addr;	
			mem_mem_data 	<= ex_mem_data;	
			mem_aluop 		<= ex_aluop;	
		end    //if
	end      //always
			

endmodule