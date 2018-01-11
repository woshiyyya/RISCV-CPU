`include "defines.v"
`include "ctrl.v"
`include "regfile.v"
`include "id.v"
`include "ex.v"
`include "mem.v"
`include "if_id.v"
`include "id_ex.v"
`include "mem_wb.v"
`include "pc_reg.v"
`include "ex_mem.v"
`include "data_ram.v"

module openmips(

	input wire  					clk,
	input wire						rst,
	
	input wire [`RegBus]           rom_data_i,
	output wire[`RegBus]           rom_addr_o,
	output wire                    rom_ce_o
);

	wire[`InstAddrBus] 	pc;
	wire[`InstAddrBus] 	id_pc_i;
	wire[`InstBus] 		id_inst_i;
	
	wire[`AluOpBus] id_aluop_o;
	wire[`AluSelBus] id_alusel_o;
	wire[`RegBus] id_reg1_o;
	wire[`RegBus] id_reg2_o;
	wire id_wreg_o;
	wire[`RegAddrBus] id_wd_o;
	wire id_mem_ce_o;
	wire[`RegBus] id_mem_sdata_o;
	wire[`InstAddrBus] id_branch_addr_o;
	wire[`RegBus]	id_branch_link_addr_o;
	
	wire[`RegBus]	ex_branch_link_addr_i;
	wire[`AluOpBus] ex_aluop_i;
	wire[`AluSelBus] ex_alusel_i;
	wire[`RegBus] ex_reg1_i;
	wire[`RegBus] ex_reg2_i;
	wire ex_wreg_i;
	wire[`RegAddrBus] ex_wd_i;
	wire[`RegBus] ex_mem_sdata_i;
	wire	ex_mem_ce_i;
	wire[`RegBus] ex_branch_addr_i;
	wire[`RegBus] ex_mem_data_o;
	wire	ex_if_branch_o;
	wire ex_wreg_o;
	wire[`RegAddrBus] ex_wd_o;
	wire[`RegBus] ex_wdata_o;

	//  EX/MEMģ    ô�׶�MEMģ   �?
	wire mem_wreg_i;
	wire[`RegAddrBus] mem_wd_i;
	wire[`RegBus] mem_wdata_i;
	

	// �ӷô�׶�MEMģ    MEM/WBģ   �?
	wire mem_wreg_o;
	wire[`RegAddrBus] mem_wd_o;
	wire[`RegBus] mem_wdata_o;
	
	
	//  MEM/WBģ    �д�׶ε  �?	
	wire wb_wreg_i;
	wire[`RegAddrBus] wb_wd_i;
	wire[`RegBus] wb_wdata_i;
	
	//    ׶�IDģ  ͨ�üĴ� Regfileģ 
  	wire reg1_read;
  	wire reg2_read;
  	wire[`RegBus] reg1_data;
  	wire[`RegBus] reg2_data;
  	wire[`RegAddrBus] reg1_addr;
  	wire[`RegAddrBus] reg2_addr;

	//  ִ�н׶� hiloģ     ȡHI LO�Ĵ� 
	
	wire 			id_stallreq;
	wire 			ex_stallreq;
	wire [5:0]      stall;

	wire [`RegBus] 	ex_branch_addr_o;
	wire 			ex_branch_flag_o;
	wire [`RegBus] 	ctrl_branch_addr_o;
	wire 			ctrl_branch_flag_o;
	wire flush;


	wire [`RegBus] 	ex_mem_addr_o;
	wire [`RegBus] 	mem_mem_addr_i;
	wire [`RegBus]	mem_mem_data_i;
	wire 			ex_mem_ce_o;
	wire 			mem_mem_ce_i;
	wire[`AluOpBus] ex_aluop_o;
	wire[`AluOpBus] mem_aluop_i;
	
	wire[`RegBus]  	memory_addr_i;
	wire		    memory_we_i;
	wire[3:0]       memory_sel_i;
	wire[`RegBus]   memory_data_i;
	wire            memory_ce_i;
	wire[`RegBus]	memory_data_o;	





	ctrl ctrl0( //ok
		.rst(rst),
		.stallreq_from_id(id_stallreq),
		.stallreq_from_ex(ex_stallreq),

		.if_branch_i(ex_if_branch_o),
		.branch_flag_i(ex_branch_flag_o),
		.branch_target_addr_i(ex_branch_addr_o),
		.pc(pc),

		.stall(stall),
		.branch_flag_o(ctrl_branch_flag_o),
		.branch_target_addr_o(ctrl_branch_addr_o),

		.flush(flush)
	);

	pc_reg pc_reg0(
		.clk(clk),
		.rst(rst),
		.stall(stall),
		.branch_flag_i(ctrl_branch_flag_o),
		.branch_target_addr_i(ctrl_branch_addr_o),
		.pc(pc),
		.ce(rom_ce_o)		
	);
	
  assign rom_addr_o = pc;
  
	if_id if_id0(//ok
		.clk(clk),
		.rst(rst),
		.flush(flush),
		.stall(stall),
		.if_pc(pc),
		.if_inst(rom_data_i),
		.id_pc(id_pc_i),
		.id_inst(id_inst_i)      	
	);
	


	id id0(//ok
		.rst(rst),
		.pc_i(id_pc_i),
		.inst_i(id_inst_i),

		.ex_aluop_i(ex_aluop_o),
		.ex_wreg_i(ex_wreg_o),
		.ex_wdata_i(ex_wdata_o),
		.ex_wd_i(ex_wd_o),

		.mem_wreg_i(mem_wreg_o),
		.mem_wdata_i(mem_wdata_o),
		.mem_wd_i(mem_wd_o),
		
		.reg1_data_i(reg1_data),
		.reg2_data_i(reg2_data),

		.reg1_read_o(reg1_read),
		.reg2_read_o(reg2_read), 	  
		.reg1_addr_o(reg1_addr),
		.reg2_addr_o(reg2_addr), 
	  
		.aluop_o(id_aluop_o),
		.alusel_o(id_alusel_o),
		.reg1_o(id_reg1_o),
		.reg2_o(id_reg2_o),
		.wd_o(id_wd_o),
		.wreg_o(id_wreg_o),

		.mem_ce_o(id_mem_ce_o),
		.mem_sdata_o(id_mem_sdata_o),
		.branch_addr_o(id_branch_addr_o),
		.branch_link_addr_o(id_branch_link_addr_o),
		.stallreq(id_stallreq)
	);

	regfile regfile1(
		.clk (clk),
		.rst (rst),
		.we	(wb_wreg_i),
		.waddr (wb_wd_i),
		.wdata (wb_wdata_i),
		.re1 (reg1_read),
		.raddr1 (reg1_addr),
		.rdata1 (reg1_data),
		.re2 (reg2_read),
		.raddr2 (reg2_addr),
		.rdata2 (reg2_data)
	);

	//ID/EXģ 
	id_ex id_ex0( //ok
		.clk(clk),
		.rst(rst),
		.stall(stall),
		.flush(flush),

		.id_aluop(id_aluop_o),
		.id_alusel(id_alusel_o),
		.id_reg1(id_reg1_o),
		.id_reg2(id_reg2_o),
		.id_wd(id_wd_o),
		.id_wreg(id_wreg_o),

		.id_mem_ce(id_mem_ce_o),
		.id_mem_sdata(id_mem_sdata_o),
		.id_branch_addr(id_branch_addr_o),
		.id_branch_link_addr(id_branch_link_addr_o),

		.ex_aluop(ex_aluop_i),
		.ex_alusel(ex_alusel_i),
		.ex_reg1(ex_reg1_i),
		.ex_reg2(ex_reg2_i),
		.ex_wd(ex_wd_i),
		.ex_wreg(ex_wreg_i),

		.ex_mem_ce(ex_mem_ce_i),
		.ex_mem_sdata(ex_mem_sdata_i),
		.ex_branch_addr(ex_branch_addr_i),
		.ex_branch_link_addr(ex_branch_link_addr_i)
	);		
	
	//EXģ 
	

	ex ex0( //ok
		.rst(rst),
	
		.aluop_i(ex_aluop_i),
		.alusel_i(ex_alusel_i),
		.reg1_i(ex_reg1_i),
		.reg2_i(ex_reg2_i),
		.wd_i(ex_wd_i),
		.wreg_i(ex_wreg_i),
		.mem_ce_i(ex_mem_ce_i),
		.mem_sdata_i(ex_mem_sdata_i),
		.branch_addr_i(ex_branch_addr_i),
		.branch_link_addr_i(ex_branch_link_addr_i),

		.aluop_o(ex_aluop_o),
		.wd_o(ex_wd_o),
		.wreg_o(ex_wreg_o),
		.wdata_o(ex_wdata_o),

		.mem_addr_o(ex_mem_addr_o),
		.mem_data_o(ex_mem_data_o),
		.mem_ce_o(ex_mem_ce_o),

		.branch_addr_o(ex_branch_addr_o),
		.branch_flag_o(ex_branch_flag_o),
		.if_branch(ex_if_branch_o),
		.stallreq(ex_stallreq)
	);

  ex_mem ex_mem0(
		.clk(clk),
		.rst(rst),
	  	.stall(stall),
		
		.ex_aluop(ex_aluop_o),
		.ex_wd(ex_wd_o),
		.ex_wreg(ex_wreg_o),
		.ex_wdata(ex_wdata_o),

		.ex_mem_ce(ex_mem_ce_o),
		.ex_mem_addr(ex_mem_addr_o),	
		.ex_mem_data(ex_mem_data_o),

		.mem_aluop(mem_aluop_i),
		.mem_wd(mem_wd_i),
		.mem_wreg(mem_wreg_i),
		.mem_wdata(mem_wdata_i),
			
		.mem_mem_ce(mem_mem_ce_i),
		.mem_mem_addr(mem_mem_addr_i),
		.mem_mem_data(mem_mem_data_i)				       	
	);
	
  //MEMģ   
	mem mem0(
		.rst(rst),
		
		.aluop_i(mem_aluop_i),
		.wd_i(mem_wd_i),
		.wreg_i(mem_wreg_i),
		.wdata_i(mem_wdata_i),

		.mem_ce_i(mem_mem_ce_i),
		.mem_addr_i(mem_mem_addr_i),	
	  	.mem_sdata_i(mem_mem_data_i),
		.mem_data_i(memory_data_o),


		.wd_o(mem_wd_o),
		.wreg_o(mem_wreg_o),
		.wdata_o(mem_wdata_o),
//		.stallreq(),	

		.mem_addr_o(memory_addr_i),
		.mem_we_o(memory_we_i),
		.mem_data_o(memory_data_i),
		.mem_sel_o(memory_sel_i),
		.mem_ce_o(memory_ce_i)
	);

  //MEM/WBģ 
	mem_wb mem_wb0(
		.clk(clk),
		.rst(rst),
		.stall(stall),
		
		.mem_wd(mem_wd_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),
				
		.wb_wd(wb_wd_i),
		.wb_wreg(wb_wreg_i),
		.wb_wdata(wb_wdata_i)	       	
	);

	data_ram data_ram0(
		.clk(clk),
		.ce(memory_ce_i),
		.we(memory_we_i),
		.addr(memory_addr_i),
		.sel(memory_sel_i),
		.data_i(memory_data_i),
		.data_o(memory_data_o)
	);

endmodule