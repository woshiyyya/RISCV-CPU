`include "defines.v"

module id(

	input wire						rst,
	input wire[`InstAddrBus]		pc_i,
	input wire[`InstBus]        	inst_i,
	//����ִ�н׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
	input wire[`AluOpBus]			ex_aluop_i,
	input wire						ex_wreg_i,
	input wire[`RegBus]				ex_wdata_i,
	input wire[`RegAddrBus]       	ex_wd_i,
	
	//���ڷô�׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
	input wire						mem_wreg_i,
	input wire[`RegBus]				mem_wdata_i,
	input wire[`RegAddrBus]       	mem_wd_i,
	
	input wire[`RegBus]           reg1_data_i,
	input wire[`RegBus]           reg2_data_i,

	//�͵�regfile����Ϣ
	output reg                    reg1_read_o,
	output reg                    reg2_read_o,     
	output reg[`RegAddrBus]       reg1_addr_o,
	output reg[`RegAddrBus]       reg2_addr_o, 	      
	
	//�͵�ִ�н׶ε���Ϣ
	output reg[`AluOpBus]         aluop_o,
	output reg[`AluSelBus]        alusel_o,
	output reg[`RegBus]           reg1_o,
	output reg[`RegBus]           reg2_o,
	output reg[`RegAddrBus]       wd_o,
	output reg                    wreg_o,

	output reg                    mem_ce_o,				//ADD
	output reg[`RegBus]			  mem_sdata_o,          //ADD			
	output reg[`InstAddrBus]	  branch_addr_o, 		//ADD  
	output reg[`RegBus]			  branch_link_addr_o,	
	output wire 				  stallreq
);

	reg 			instvalid;
	wire[6:0] 		op;
	wire[9:0] 		aluopT; 
	wire[10:0]  	aluop;
	reg	[`RegBus]	imm;
	reg stallreq_for_reg1_loadrelate;
	reg stallreq_for_reg2_loadrelate;
	wire pre_inst_is_load;

	assign op  = 	inst_i[6:0];
	assign aluopT = {inst_i[14:12], inst_i[6:0]};
	assign aluop =  {{`SPECIAL ? inst_i[30] : 1'b0},inst_i[14:12], inst_i[6:0]};
	assign pre_inst_is_load = ((ex_aluop_i == `EXE_LB)||(ex_aluop_i == `EXE_LH)||(ex_aluop_i == `EXE_LW)
			||(ex_aluop_i == `EXE_LBU)||(ex_aluop_i == `EXE_LHU)) ? 1'b1 : 1'b0;

	assign stallreq = stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;

	always @ (*) begin	
		if (rst == `RstEnable) begin
			aluop_o 	<= `EXE_NOP;
			alusel_o 	<= `EXE_RES_NOP;
			wd_o 		<= `NOPRegAddr;
			wreg_o 		<= `WriteDisable;
			instvalid 	<= `InstValid;
			mem_ce_o    <= 1'b0;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= `NOPRegAddr;
			reg2_addr_o <= `NOPRegAddr;
			imm 		<= `ZeroWord;			
	  	end else begin
			aluop_o 	<= `EXE_NOP;
			alusel_o 	<= `EXE_RES_NOP;
			wd_o 		<=  inst_i[11:7];
			wreg_o 		<= `WriteDisable;
			instvalid 	<= `InstInvalid;	
			mem_ce_o    <= 1'b0;   
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= inst_i[19:15];
			reg2_addr_o <= inst_i[24:20];	
		  	case (op)
		    	`OP_LUI:	begin
					instvalid <= `InstValid;
					wreg_o 	<= `WriteEnable;
					aluop_o <= 	`EXE_LUI;      alusel_o <= `EXE_RES_ARITHMETIC;
					reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
					imm <= {inst_i[31:12],12'b0};				
				end
				`OP_AUIPC:	begin
					instvalid <= `InstValid;
					wreg_o 	<= `WriteEnable;
					aluop_o <= 	`EXE_AUIPC;      alusel_o <= `EXE_RES_ARITHMETIC;
					reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
					imm <= {inst_i[31:12],12'b0};				
				end
				`OP_JAL: begin
					instvalid <= `InstValid;
					wreg_o 	<= `WriteEnable;
					aluop_o <= 	`EXE_JAL;      alusel_o <= `EXE_RES_BRANCH;
					reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
					imm <= {{12{inst_i[31]}},inst_i[19:12],
							inst_i[20],inst_i[30:21],1'b0};	
				end
				`OP_JALR:	begin
					instvalid <= `InstValid;
					wreg_o 	<= `WriteEnable;
					aluop_o <= 	aluop;      alusel_o <= `EXE_RES_BRANCH;
					reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
					imm <= {{21{inst_i[31]}},inst_i[30:20]};				
				end
				`OP_BRANCH: begin
					instvalid <= `InstValid;
					wreg_o 	<= `WriteDisable;
					aluop_o <= 	aluop;      alusel_o <= `EXE_RES_BRANCH;
					reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
					imm <= {{20{inst_i[31]}}, inst_i[7], inst_i[30:25],
								 inst_i[11:8], 1'b0};	
				end
				`OP_LOAD: begin
					instvalid <= `InstValid;
					wreg_o 	<= `WriteEnable;
					mem_ce_o <= 1'b1;
					aluop_o <= 	aluop;      alusel_o <= `EXE_RES_LDST;
					reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
					imm <= {{21{inst_i[31]}},inst_i[30:20]};
				end
				`OP_STORE: begin
					instvalid <= `InstValid;
					wreg_o 	<= `WriteDisable;
					mem_ce_o <= 1'b1;
					aluop_o <= 	aluop;      alusel_o <= `EXE_RES_LDST;
					reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
					imm <= {{21{inst_i[31]}},inst_i[30:25],inst_i[11:8],inst_i[7]};
				end
				`OP_ALUI: begin
					instvalid <= `InstValid;
					wreg_o 	<= `WriteEnable;
					aluop_o <= 	aluop;
					reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
					imm <= {{21{inst_i[31]}},inst_i[30:20]};
					case(aluop)
						`EXE_ADDI,`EXE_SLTI,`EXE_SLTIU:	begin
							alusel_o <= `EXE_RES_ARITHMETIC;	
						end
						`EXE_XORI,`EXE_ORI,`EXE_ANDI: begin
							alusel_o <= `EXE_RES_LOGIC;
						end
						`EXE_SLLI,`EXE_SRLI,`EXE_SRAI: begin
							alusel_o <= `EXE_RES_SHIFT;
						end
						default: begin
							alusel_o <= `EXE_RES_NOP;
						end
					endcase
				end
				`OP_ALU:begin
					instvalid <= `InstValid;
					wreg_o 	<= `WriteEnable;
					aluop_o <= 	aluop;
					reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
					imm <= `ZeroWord;
					case(aluop)
						`EXE_ADD,`EXE_SUB,`EXE_SLT,`EXE_SLTU:	begin
							alusel_o <= `EXE_RES_ARITHMETIC;	
						end
						`EXE_XOR,`EXE_OR,`EXE_AND: begin
							alusel_o <= `EXE_RES_LOGIC;
						end
						`EXE_SLL,`EXE_SRL,`EXE_SRA: begin
							alusel_o <= `EXE_RES_SHIFT;
						end
						default : begin
							alusel_o <= `EXE_RES_NOP;
						end
					endcase	
				end
				`OP_NOP,`OP_FENCE:begin
					instvalid <= `InstValid;
					wreg_o 	<= `WriteDisable;
					aluop_o <= 	aluop;      alusel_o <= `EXE_RES_NOP;
					reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
					imm <= `ZeroWord;	
				end
				default:begin
					instvalid <= `InstValid;
					wreg_o 	<= `WriteDisable;
					aluop_o <= 	aluop;      alusel_o <= `EXE_RES_NOP;
					reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
					imm <= `ZeroWord;
				end
		    endcase
		end       //if
	end         //always
	

	always @ (*) begin
		stallreq_for_reg1_loadrelate <= `NoStop;
		if(rst == `RstEnable) begin
			reg1_o <= `ZeroWord;		
		end else if(pre_inst_is_load == 1'b1 && ex_wd_i == reg1_addr_o && reg1_read_o == 1'b1)begin
			stallreq_for_reg1_loadrelate <= `Stop;
		end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o)) begin
			reg1_o <= ex_wdata_i; 
		end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1)&& (mem_wd_i == reg1_addr_o)) begin
			reg1_o <= mem_wdata_i; 			
		end else if(reg1_read_o == 1'b1) begin
			reg1_o <= reg1_data_i;
		end else begin
			reg1_o <= `ZeroWord;
		end
		//$display("%d %d %d %d %d %d %d %d %d %d %d ex2",reg1_o,rst,reg1_data_i,reg1_read_o,ex_wreg_i,ex_wd_i,mem_wreg_i,mem_wd_i,ex_wdata_i,reg1_addr_o,mem_wdata_i);
		//$display("ex2");
	end
	
	always @ (*) begin
		stallreq_for_reg2_loadrelate <= `NoStop;
		if(rst == `RstEnable) begin
			reg2_o <= `ZeroWord;
		end else if(pre_inst_is_load == 1'b1 && ex_wd_i == reg2_addr_o && reg2_read_o == 1'b1)begin
			stallreq_for_reg2_loadrelate <= `Stop;
		end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
								&& (ex_wd_i == reg2_addr_o)) begin
			if(op == `OP_STORE) begin
				reg2_o <= imm;
				mem_sdata_o <= ex_wdata_i; 
			end else begin
				reg2_o <= ex_wdata_i;
			end
		end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
								&& (mem_wd_i == reg2_addr_o)) begin
			if(op == `OP_STORE) begin
				reg2_o <= imm;
				mem_sdata_o <= mem_wdata_i; 
			end else begin
				reg2_o <= mem_wdata_i;
			end	
		end else if((reg2_read_o == 1'b0) && (op == `OP_AUIPC))begin   
			reg2_o <= imm + pc_i;
		end else if((reg2_read_o == 1'b0) && ((op == `OP_LOAD)||(op == `OP_LUI)||(op == `OP_ALUI)))begin
			reg2_o <= imm;
		end else if((reg2_read_o == 1'b1) && (op == `OP_STORE))begin
			reg2_o <= imm;    				//STORE ADRESS
			mem_sdata_o <= reg2_data_i;    				
		end else if((reg2_read_o == 1'b1) && ((op == `OP_ALU)||(op == `OP_BRANCH)))begin
			reg2_o <= reg2_data_i;
		end else begin
			reg2_o <= `ZeroWord;
		end
//		$display("ex3");
	end

//	Instruction Address Computation
	always@(*) begin
		if(op == `OP_JALR)				begin
			branch_link_addr_o <= pc_i + 4;
			branch_addr_o <= reg1_data_i + imm;
		end else if(op == `OP_JAL)		begin
			branch_link_addr_o <= pc_i + 4;
			branch_addr_o <= imm + pc_i;
		end else if(op == `OP_BRANCH)	begin
			branch_link_addr_o <= `ZeroWord;
			branch_addr_o <= imm + pc_i;
		end else if(op == `OP_AUIPC) begin
			branch_link_addr_o <= imm + pc_i;
			branch_addr_o <= `ZeroWord;
		end else if(op == `OP_LUI) begin
			branch_link_addr_o <= imm;
			branch_addr_o <= `ZeroWord;
		end else begin
			branch_link_addr_o <= `ZeroWord;
			branch_addr_o <= `ZeroWord;
		end
	end


endmodule