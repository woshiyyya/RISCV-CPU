`include "defines.v"

module mem(

	input wire					  	rst,
	input wire[`AluOpBus]			aluop_i,    //new
	input wire[`RegAddrBus]       	wd_i,
	input wire                    	wreg_i,
	input wire[`RegBus]			  	wdata_i,
	input wire 						mem_ce_i,
	input wire[`RegBus]				mem_addr_i,
	input wire[`RegBus]				mem_sdata_i,  //data to be stored
	input wire[`RegBus]          	mem_data_i,	  //data from memory unit

	input wire						fetching_data, //to be done!

	output reg[`RegAddrBus]      	wd_o,
	output reg                   	wreg_o,
	output reg[`RegBus]			 	wdata_o,	

	//Message to memory unit
	output reg[`RegBus]          	mem_addr_o,
	output wire[29:0]				mem_reduced_addr_o,
	output wire					 	mem_we_o,
	output wire 					mem_re_o,
	output reg[3:0]              	mem_sel_o,
	output reg[`RegBus]          	mem_data_o,
	output reg                   	mem_ce_o,

	output wire						stallreq
);

	wire[`RegBus] zero32;
	reg           mem_we;
	reg 		  mem_op_already;

	assign mem_we_o = mem_we ;
	assign zero32 = `ZeroWord;
	assign stallreq = (((aluop_i[6:0] == `OP_LOAD) || (aluop_i[6:0] == `OP_STORE))
												&& (fetching_data == 1'b1)) ? 1'b1 : 1'b0;
	assign mem_reduced_addr_o = {mem_addr_i[31:2]};

	always @ (*) begin
		if(rst == `RstEnable) begin
			wd_o 	<= `NOPRegAddr;
			wreg_o 	<= `WriteDisable;
			wdata_o <= `ZeroWord;	  
		end else begin
			wd_o 	<= wd_i;
			wreg_o 	<= wreg_i;
			wdata_o <= wdata_i;		
		end    //if
	end      //always

	always @ (*) begin
		if(rst == `RstEnable) begin
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
		  	wdata_o <= `ZeroWord;		
		  	mem_addr_o <= `ZeroWord;
		  	mem_we <= `WriteDisable;
		  	mem_sel_o <= 4'b0000;
		  	mem_data_o <= `ZeroWord;	
		  	mem_ce_o <= `ChipDisable;		      
		end else begin
		  	wd_o <= wd_i;
			wreg_o <= wreg_i;
			wdata_o <= wdata_i;		
			mem_we <= `WriteDisable;
			mem_addr_o <= `ZeroWord;
			mem_sel_o <= 4'b1111;
			mem_ce_o <= `ChipDisable;		
			case (aluop_i)
				`EXE_LB:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
							mem_sel_o <= 4'b0001;
						end
						2'b01:	begin
							wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
							mem_sel_o <= 4'b0010;
						end
						2'b10:	begin
							wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
							mem_sel_o <= 4'b0100;
						end
						2'b11:	begin
							wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
							mem_sel_o <= 4'b1000;
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase
				end
				`EXE_LBU:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[7:0]};
							mem_sel_o <= 4'b0001;
						end
						2'b01:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[15:8]};
							mem_sel_o <= 4'b0010;
						end
						2'b10:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[23:16]};
							mem_sel_o <= 4'b0100;
						end
						2'b11:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[31:24]};
							mem_sel_o <= 4'b1000;
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase				
				end
				`EXE_LH:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= {{16{mem_data_i[15]}},mem_data_i[15:0]};
							mem_sel_o <= 4'b0011;
						end
						2'b10:	begin
							wdata_o <= {{16{mem_data_i[31]}},mem_data_i[31:16]};
							mem_sel_o <= 4'b1100;
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase					
				end
				`EXE_LHU:		begin
					mem_addr_o <= mem_addr_i;
					mem_we <= `WriteDisable;
					mem_ce_o <= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							wdata_o <= {{16{1'b0}},mem_data_i[15:0]};
							mem_sel_o <= 4'b0011;
						end
						2'b10:	begin
							wdata_o <= {{16{1'b0}},mem_data_i[31:16]};
							mem_sel_o <= 4'b1100;
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase				
				end
				`EXE_LW:		begin
					mem_addr_o 	<= mem_addr_i;
					mem_we 		<= `WriteDisable;
					wdata_o 	<= mem_data_i;
					mem_sel_o 	<= 4'b1111;		
					mem_ce_o 	<= `ChipEnable;
				end			
				`EXE_SB:		begin
					mem_addr_o 	<= mem_addr_i;
					mem_we 		<= `WriteEnable;
					mem_data_o 	<= {mem_sdata_i[7:0],mem_sdata_i[7:0],mem_sdata_i[7:0],mem_sdata_i[7:0]};
					mem_ce_o 	<= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							mem_sel_o <= 4'b0001;
						end
						2'b01:	begin
							mem_sel_o <= 4'b0010;
						end
						2'b10:	begin
							mem_sel_o <= 4'b0100;
						end
						2'b11:	begin
							mem_sel_o <= 4'b1000;	
						end
						default:	begin
							mem_sel_o <= 4'b0000;
						end
					endcase				
				end
				`EXE_SH:		begin
					mem_addr_o 	<= mem_addr_i;
					mem_we 		<= `WriteEnable;
					mem_data_o 	<= {mem_sdata_i[15:0],mem_sdata_i[15:0]};
					mem_ce_o 	<= `ChipEnable;
					case (mem_addr_i[1:0])
						2'b00:	begin
							mem_sel_o <= 4'b0011;
						end
						2'b10:	begin
							mem_sel_o <= 4'b1100;
						end
						default:	begin
							mem_sel_o <= 4'b0000;
						end
					endcase						
				end
				`EXE_SW:		begin
					mem_addr_o 	<= mem_addr_i;
					mem_we 		<= `WriteEnable;
					mem_data_o 	<= mem_sdata_i;
					mem_sel_o 	<= 4'b1111;	
					mem_ce_o 	<= `ChipEnable;		
				end
				default:		begin
          			//do nothing
				end
			endcase							
		end    //if
	end      //always
			

endmodule