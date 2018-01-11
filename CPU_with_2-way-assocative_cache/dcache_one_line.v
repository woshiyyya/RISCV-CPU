module dcache_one_line(
	input wire 			enable;
	input wire			clk;
	input wire			rst;
	input wire			compare;  //whether need comparation or load from lower memory
	input wire			read;
	input wire[31:0] 	address_in;
	input wire[31:0]	data_in;
	input wire[3:0]		byte_w_en;
	input wire[255:0]	data_line_in;

	output reg			hit;
	output reg 			dirty;
	output reg  		valid;
	output reg[31:0]	address_out;
	output reg[31:0]	data_out;
	output reg[255:0]	data_line_out;
	);
	/*
	+---+---+---+---+---+---+---+
	| 8 | 8 | 8 | 8 | t | v | d |
	+---+---+---+---+---+---+---+
	8 - 8 bytes, 64 bits, total 256 bit/a block
	t - tag
	v - valid
	d - dirty
	*/
	//addr(32) = tag(21) + index_in_block(6) + addr_in_block(5)
	//block size = 256
	//cache depth = 64

	reg[255:0]	mem	[63:0];
	reg[20:0]	tag	[63:0];
	reg         valid_bit	[63:0];
	reg			dirty_bit	[63:0];
	wire[20:0]	addr_tag;
	wire[5:0]	addr_index;
	wire[2:0]	addr_in_block;      //offset
	integer i;

	//mid var
	assign addr_tag 		= address_in[31:11];
	assign addr_index 		= address_in[10:5];
	assign addr_in_block 	= address_in[4:2];

	initial begin
	   for(i = 0; i < 64; i = i + 1) begin
	       valid_bit[i] = 1'b0;
           dirty_bit[i] = 1'b0;
           tag[i] = 21'h0;
	   end
	end

	//output assign
	assign hit 			= (compare == 1) ? (addr_tag == tag[addr_index]? 1'b1 : 1'b0) : 1'b0;
	assign dirty 		= dirty_bit[addr_index];
	assign valid 		= valid_bit[addr_index];
	assign address_out 	= {tag[addr_index], addr_index, 5'b0};

	always@(negedge clk) begin
		if(enable == 1'b1) begin
			if(rst == 1'b1) begin
			    data_out <= 32'h0;
				for(i = 0; i < 64; i = i + 1) begin
				    valid_bit[i] = 1'b0;
				end
			end
			else if(read == 1'b1) begin
				//Pay attention
				//big endian
				case(addr_in_block)
					0:	data_out	<=	mem[addr_index][31:0];
					1:	data_out	<=	mem[addr_index][63:32];
					2:	data_out	<=	mem[addr_index][95:64];
					3:	data_out	<=	mem[addr_index][127:96];
					4:	data_out	<=	mem[addr_index][159:128];
					5:	data_out	<=	mem[addr_index][191:160];
					6:	data_out	<=	mem[addr_index][223:192];
					7:	data_out	<=	mem[addr_index][255:224];
				endcase
				data_line_out <= mem[addr_index];
			end
			else if(read == 1'b0) begin 
				//write data
				if(compare == 1'b0) begin
				    dirty_bit[addr_index] 	<= 1'b0;
					mem[addr_index] 		<= data_line_in;   //LOAD FROM LOWER MEMORY
					tag[addr_index] 		<= addr_tag;
					valid_bit[addr_index] 	<= 1'b1;
				end
				else if(compare == 1'b1 && hit == 1'b1) begin
				    dirty_bit[addr_index] <= 1'b1;
				    case(addr_in_block)
                        0:begin
                            if(byte_w_en[0] == 1'b1) begin mem[addr_index][7:0]         <=  data_in[7:0]; end
                            if(byte_w_en[1] == 1'b1) begin mem[addr_index][15:8]        <=	data_in[15:8]; end
                            if(byte_w_en[2] == 1'b1) begin mem[addr_index][23:16]		<=	data_in[23:16];  end
                            if(byte_w_en[3] == 1'b1) begin mem[addr_index][31:24]		<=	data_in[31:24];   end
                        end
                        1:begin    
                            if(byte_w_en[0] == 1'b1) begin mem[addr_index][39:32]	    <=	data_in[7:0]; end
                            if(byte_w_en[1] == 1'b1) begin mem[addr_index][47:40]	    <=	data_in[15:8]; end
                            if(byte_w_en[2] == 1'b1) begin mem[addr_index][55:48]		<=	data_in[23:16];  end
                            if(byte_w_en[3] == 1'b1) begin mem[addr_index][63:56]		<=	data_in[31:24];   end
                        end
                        2:begin    
                            if(byte_w_en[0] == 1'b1) begin mem[addr_index][71:64]	    <=	data_in[7:0]; end
                            if(byte_w_en[1] == 1'b1) begin mem[addr_index][79:72]	    <=	data_in[15:8]; end
                            if(byte_w_en[2] == 1'b1) begin mem[addr_index][87:80]		<=	data_in[23:16];  end
                            if(byte_w_en[3] == 1'b1) begin mem[addr_index][95:88]		<=	data_in[31:24];   end
                        end
                        3:begin    
                            if(byte_w_en[0] == 1'b1) begin mem[addr_index][103:96]	    <=	data_in[7:0]; end
                            if(byte_w_en[1] == 1'b1) begin mem[addr_index][111:104]	    <=	data_in[15:8]; end
                            if(byte_w_en[2] == 1'b1) begin mem[addr_index][119:112]		<=	data_in[23:16];  end
                            if(byte_w_en[3] == 1'b1) begin mem[addr_index][127:120]		<=	data_in[31:24];   end
                        end
                        4:begin    
                            if(byte_w_en[0] == 1'b1) begin mem[addr_index][135:128]	   	<=	data_in[7:0]; end
                            if(byte_w_en[1] == 1'b1) begin mem[addr_index][143:136]	    <=	data_in[15:8]; end
                            if(byte_w_en[2] == 1'b1) begin mem[addr_index][151:144]  	<=	data_in[23:16];  end
                            if(byte_w_en[3] == 1'b1) begin mem[addr_index][159 :152]  	<=	data_in[31:24];   end
                        end                                                
                        5:begin    
                            if(byte_w_en[0] == 1'b1) begin mem[addr_index][167:160]	    <=	data_in[7:0]; end
                            if(byte_w_en[1] == 1'b1) begin mem[addr_index][175:168]	    <=	data_in[15:8]; end
                            if(byte_w_en[2] == 1'b1) begin mem[addr_index][183:176]  	<=	data_in[23:16];  end
                            if(byte_w_en[3] == 1'b1) begin mem[addr_index][191:184]  	<=	data_in[31:24];   end
                        end                                 
                        6:begin    
                            if(byte_w_en[0] == 1'b1) begin mem[addr_index][199:192]	    <=	data_in[7:0]; end
                            if(byte_w_en[1] == 1'b1) begin mem[addr_index][207:200]	    <=	data_in[15:8]; end
                            if(byte_w_en[2] == 1'b1) begin mem[addr_index][215:208]  	<=	data_in[23:16];  end
                            if(byte_w_en[3] == 1'b1) begin mem[addr_index][223:216]  	<=	data_in[31:24];   end
                        end                                 
                        7:begin    
                            if(byte_w_en[0] == 1'b1) begin mem[addr_index][231:224]	    <=	data_in[7:0]; end
                            if(byte_w_en[1] == 1'b1) begin mem[addr_index][239:232]	    <=	data_in[15:8]; end
                            if(byte_w_en[2] == 1'b1) begin mem[addr_index][247:240]  	<=	data_in[23:16];  end
                            if(byte_w_en[3] == 1'b1) begin mem[addr_index][255:248]  	<=	data_in[31:24];   end
                        end                                 
                         
                    endcase				    
					
				end
			end
		end
	end


endmodule