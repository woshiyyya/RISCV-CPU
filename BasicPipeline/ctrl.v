`include "defines.v"

module ctrl(

	input wire					 rst,
	input wire                   stallreq_from_id,
	input wire                   stallreq_from_ex,
	input wire 					 stallreq_from_mem, //to be done

	input wire                   if_branch_i,
	input wire 					 branch_flag_i,
	input wire[`RegBus]			 branch_target_addr_i,	
	input wire[`RegBus]			 pc,

	output reg[5:0]              stall,
	output reg					 branch_flag_o,
	output reg[`InstAddrBus]	 branch_target_addr_o,

	output reg                   flush	
);


	always @ (*) begin
		if(rst == `RstEnable) begin
			stall <= 6'b000000;
		end else if(stallreq_from_ex == `Stop) begin
			stall <= 6'b001111;
		end else if(stallreq_from_id == `Stop) begin
			stall <= 6'b000111;	
//		end else if(stallreq_from_mem == `Stop) begin
//			stall <= 6'b011111;		
		end else begin
			stall <= 6'b000000;
		end    
	end      
			
	always@(*)begin
		if(if_branch_i != `Branch)begin
			flush <= 1'b0;
			branch_target_addr_o <= `ZeroWord;
			branch_flag_o <= 1'b0;
		end else if(branch_flag_i == `Branch)begin
			flush <= 1'b1;
			branch_target_addr_o <= branch_target_addr_i;
			branch_flag_o <= branch_flag_i;
		end else begin
			flush <= 1'b0;
			branch_target_addr_o <= `ZeroWord;
			branch_flag_o <= 1'b0;
		end
	end

endmodule