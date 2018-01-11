module ctrl(

	input wire					 rst,
	input wire                   stallreq_from_id,
	input wire                   stallreq_from_ex,

	input wire 					 branch_flag_i,
	input wire[`RegBus]			 branch_target_addr_i,	
	input wire[`RegBus]			 pc,

	output reg[5:0]              stall,
	output reg					 branch_flag_o,
	output reg[`InstAddrBus]	 branch_target_addr_o	
);
module pc_reg(

	input wire					clk,
	input wire					rst,
	
	input wire[5:0] 			stall,
	input wire[`InstAddrBus]    ctrl_addr_i,

	input wire 					branch_flag_i,
	input wire[`RegBus]			branch_target_addr_i,

	output reg[`InstAddrBus]	pc,
	output reg                  ce,
);
module inst_rom(
	//input wire						clk,
	input wire							ce,
	input wire[`InstAddrBus]			addr,
	output reg[`InstBus]				inst
);
module regfile(

	input	wire					clk,
	input wire						rst,
	
	input wire						we,
	input wire[`RegAddrBus]			waddr,
	input wire[`RegBus]				wdata,
	
	input wire						re1,
	input wire[`RegAddrBus]			raddr1,
	output reg[`RegBus]             rdata1,
	
	input wire						re2,
	input wire[`RegAddrBus]			raddr2,
	output reg[`RegBus]             rdata2
	
);
module if_id(

	input	wire				  	clk,
	input wire					  	rst,
	input wire[5:0]					stall,
	input wire[`InstAddrBus]	  	if_pc,
	input wire[`InstBus]          	if_inst,
	output reg[`InstAddrBus]      	id_pc,
	output reg[`InstBus]          	id_inst  
	
);
module id(

	input wire						rst,
	input wire[`InstAddrBus]		pc_i,
	input wire[`InstBus]        	inst_i,
	//处于执行阶段的指令要写入的目的寄存器信息
	input wire						ex_wreg_i,
	input wire[`RegBus]				ex_wdata_i,
	input wire[`RegAddrBus]       	ex_wd_i,
	
	//处于访存阶段的指令要写入的目的寄存器信息
	input wire						mem_wreg_i,
	input wire[`RegBus]				mem_wdata_i,
	input wire[`RegAddrBus]       	mem_wd_i,
	
	input wire[`RegBus]           reg1_data_i,
	input wire[`RegBus]           reg2_data_i,

	//送到regfile的信息
	output reg                    reg1_read_o,
	output reg                    reg2_read_o,     
	output reg[`RegAddrBus]       reg1_addr_o,
	output reg[`RegAddrBus]       reg2_addr_o, 	      
	
	//送到执行阶段的信息
	output reg[`AluOpBus]         aluop_o,
	output reg[`AluSelBus]        alusel_o,
	output reg[`RegBus]           reg1_o,
	output reg[`RegBus]           reg2_o,
	output reg[`RegAddrBus]       wd_o,
	output reg                    wreg_o
);
module id_ex(

	input wire  					clk,
	input wire						rst,
	input wire[5:0]					stall,
	//From ID
	input wire[`AluOpBus]         id_aluop,
	input wire[`AluSelBus]        id_alusel,
	input wire[`RegBus]           id_reg1,
	input wire[`RegBus]           id_reg2,
	input wire[`RegAddrBus]       id_wd,
	input wire                    id_wreg,	
	
	//TO EX
	output reg[`AluOpBus]         ex_aluop,
	output reg[`AluSelBus]        ex_alusel,
	output reg[`RegBus]           ex_reg1,
	output reg[`RegBus]           ex_reg2,
	output reg[`RegAddrBus]       ex_wd,
	output reg                    ex_wreg
);
module ex(
	input wire						rst,
	
	//送到执行阶段的信息
	input wire[`AluOpBus]         	aluop_i,
	input wire[`AluSelBus]        	alusel_i,
	input wire[`RegBus]           	reg1_i,
	input wire[`RegBus]           	reg2_i,
	input wire[`RegAddrBus]      	wd_i,
	input wire                    	wreg_i,
	
	output reg[`RegAddrBus]    	   	wd_o,
	output reg                  	wreg_o,
	output reg[`RegBus]				wdata_o,
	output reg['RegBus]				mem_addr_o 		//ADD
	output reg                      mem_ce_o,    	//TO-BE-DONE
	output reg['RegBus]				branch_addr_o, 	//ADD
	output reg 						if_branch,
	output reg 						stallreq
);
module ex_mem(

	input wire						clk,
	input wire						rst,
	input wire[5:0] 			 	stall,

	input wire[`RegAddrBus]       	ex_wd,
	input wire                    	ex_wreg,
	input wire[`RegBus]			  	ex_wdata,

	input wire						ex_mem_ce, 	
	input wire[`RegBus]				ex_mem_addr,
	
	output reg[`RegAddrBus]      	mem_wd,
	output reg                   	mem_wreg,
	output reg[`RegBus]			 	mem_wdata,

	output reg 						mem_mem_ce,
	output reg[`RegBus]				mem_mem_addr,
);
module mem(

	input wire					  	rst,
	
	input wire[`RegAddrBus]       	wd_i,
	input wire                    	wreg_i,
	input wire[`RegBus]			  	wdata_i,
	input wire 						mem_ce_i,
	input wire[`RegBus]				mem_addr_i,

	output reg[`RegAddrBus]      	wd_o,
	output reg                   	wreg_o,
	output reg[`RegBus]			 	wdata_o,	
	output reg 						stallreq
);
module mem_wb(

	input wire						clk,
	input wire	 					rst,
	input wire[5:0]					stall,

	input wire[`RegAddrBus]       	mem_wd,
	input wire                    	mem_wreg,
	input wire[`RegBus]			  	mem_wdata,

	output reg[`RegAddrBus]      	wb_wd,
	output reg                   	wb_wreg,
	output reg[`RegBus]			 	wb_wdata
);