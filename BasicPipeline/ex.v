`include "defines.v"

module ex(
	input wire						rst,
	
	//�͵�ִ�н׶ε���Ϣ
	input wire[`AluOpBus]         	aluop_i,
	input wire[`AluSelBus]        	alusel_i,
	input wire[`RegBus]           	reg1_i,
	input wire[`RegBus]           	reg2_i,
	input wire[`RegAddrBus]      	wd_i,
	input wire                    	wreg_i,
	input wire 						mem_ce_i,			//ADD
	input wire[`RegBus]				mem_sdata_i,		//ADD data of Store
	input wire[`RegBus]				branch_addr_i,      //ADD
	input wire[`RegBus]				branch_link_addr_i,

	output reg[`AluOpBus]         	aluop_o,  //NEW
	output reg[`RegAddrBus]    	   	wd_o,
	output reg                  	wreg_o,
	output reg[`RegBus]				wdata_o,
	//Store operation only
	output reg[`RegBus]				mem_addr_o, 		//ADD
	output reg[`RegBus]				mem_data_o,			//ADD
	output reg                      mem_ce_o,    		//TO-BE-DONE

	output reg[`RegBus]				branch_addr_o, 		//ADD
	output reg						branch_flag_o,      //ADD
	output reg 						if_branch,          //change! represent if it is a branch inst
	output reg 						stallreq
);

	reg[`RegBus] logicout;
	reg[`RegBus] shiftres;
	reg[`RegBus] arithmeticres;
	reg[`RegBus] Branch_arithmeticres;
	wire[`RegBus] reg2_i_mux;
	wire[`RegBus] result_sum;
	wire ov_sum;
	wire reg1_eq_reg2;
	wire reg1_lt_reg2;

	always@(*)begin
		stallreq = 1'b0;
		mem_ce_o = mem_ce_i;
		aluop_o = aluop_i;
	end

	always @ (*) begin
		if(rst == `RstEnable) begin
			logicout <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_OR,`EXE_ORI:begin
					logicout <= reg1_i | reg2_i;
				end
				`EXE_AND,`EXE_ANDI:begin
					logicout <= reg1_i & reg2_i;
				end
				`EXE_XOR,`EXE_XORI:begin
					logicout <= reg1_i ^ reg2_i;
				end
				default:  begin
					logicout <= `ZeroWord;
				end
			endcase
		end    
	end      

	always @ (*) begin
		if(rst == `RstEnable) begin
			shiftres <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_SLL,`EXE_SLLI:		begin
					shiftres <= reg1_i << reg2_i[4:0] ;
				end
				`EXE_SRL,`EXE_SRLI:		begin
					shiftres <= reg1_i >> reg2_i[4:0];
				end
				`EXE_SRA,`EXE_SRAI:		begin
					shiftres <= ({32{reg1_i[31]}} << (6'd32-{1'b0, reg2_i[4:0]})) 
												| reg1_i >> reg2_i[4:0];
				end
				default:		begin
					shiftres <= `ZeroWord;
				end
			endcase
		end    
	end      


// 		//----------------------REG-REG------------------------------------------------------------
	assign reg2_i_mux =   ((aluop_i == `EXE_SUB) || (aluop_i == `EXE_SLT) 
					    || (aluop_i == `EXE_BLT) || (aluop_i == `EXE_BLTU) 
					    || (aluop_i == `EXE_SLTI) || (aluop_i == `EXE_SLTIU)) 
											 ? (~reg2_i)+1 : reg2_i;

	assign result_sum = reg1_i + reg2_i_mux;										 

	assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) ||
									((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));  

	assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT) || (aluop_i == `EXE_SLTI) || (aluop_i == `EXE_BLT) || (aluop_i == `EXE_BGE)) ?
								((reg1_i[31] && !reg2_i[31]) || 
								(!reg1_i[31] && !reg2_i[31] && result_sum[31])||
			                   	(reg1_i[31] && reg2_i[31] && result_sum[31]))
			                   		:(reg1_i < reg2_i);
	assign reg1_eq_reg2 = (reg1_i == reg2_i);
		//------------------------END--------------------------------------------------------------
		//------------------------END---------------------------------------------------------------- 
							
	always @ (*) begin
		if(rst == `RstEnable) begin
			arithmeticres <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_LUI, `EXE_AUIPC: begin
					arithmeticres <= branch_link_addr_i;
				end
			//---------------Less Than-----------------------
				`EXE_SLT,  `EXE_SLTU, `EXE_SLTI, `EXE_SLTIU:		begin
					arithmeticres <= reg1_lt_reg2 ;
				end
			//---------------Load Store----------------------
				`EXE_LW,`EXE_LB,`EXE_LH,`EXE_LBU,`EXE_LHU:	begin
					arithmeticres <= result_sum;
				end
				`EXE_SW:begin
					arithmeticres <= result_sum;
					mem_data_o <= mem_sdata_i;
				end
				`EXE_SH:begin
					arithmeticres <= result_sum;
					mem_data_o <= {16'b0, mem_sdata_i[15:0]};
				end
				`EXE_SB:begin
					arithmeticres <= result_sum;
					mem_data_o <= {24'b0, mem_sdata_i[7:0]};
				end
			//---------------Arithmatic Operation-------------
				`EXE_ADD,  `EXE_SUB, `EXE_ADDI:		begin
					arithmeticres <= result_sum; 
				end
			//---------------Branch----------------------------
				`EXE_BLT, `EXE_BLTU:		begin
					arithmeticres <= `ZeroWord;
					Branch_arithmeticres <= reg1_lt_reg2;
				end
				`EXE_BGE, `EXE_BGEU:		begin
					arithmeticres <= `ZeroWord;
					Branch_arithmeticres <= ~reg1_lt_reg2;
				end
				`EXE_BEQ: 					begin
					arithmeticres <= `ZeroWord;
					Branch_arithmeticres <= reg1_eq_reg2;
				end
				`EXE_BNE: 					begin
					arithmeticres <= `ZeroWord;
					Branch_arithmeticres <= ~reg1_eq_reg2;
				end
			//--------------JUMP---------------------------------
				`EXE_JAL, `EXE_JALR:		begin
					Branch_arithmeticres <= `Branch;
					arithmeticres <= branch_link_addr_i;
				end
				default:					begin
					Branch_arithmeticres <= `ZeroWord;
					arithmeticres <= `ZeroWord;
				end
			endcase
		end
	end 

 always @ (*) begin
	wd_o 		<= wd_i;
	wreg_o 		<= wreg_i;	 
	if(	alusel_i == `EXE_RES_BRANCH)begin
		if_branch 		<= `Branch;
		branch_flag_o   <= Branch_arithmeticres;
		branch_addr_o 	<= branch_addr_i; 
		wdata_o 		<= arithmeticres;     
	end else begin
		if_branch 	<= `NotBranch;
		branch_flag_o 	<= `NotBranch;
		branch_addr_o 	<= `ZeroWord;
	case ( alusel_i ) 
	 	`EXE_RES_LOGIC:		begin
	 		wdata_o 		<= logicout;
	 	end
	 	`EXE_RES_SHIFT:		begin
	 		wdata_o 		<= shiftres;
	 	end		
	 	`EXE_RES_ARITHMETIC:begin
	 		wdata_o 		<= arithmeticres;
	 	end 	
		`EXE_RES_LDST:begin
			mem_ce_o 		<= 1'b1;
			mem_addr_o 		<= arithmeticres;
		end
	 	default:begin
	 		wdata_o 		<= `ZeroWord;
			mem_addr_o 		<= `ZeroWord;
	 	end
	 	endcase
 	end		
end




endmodule