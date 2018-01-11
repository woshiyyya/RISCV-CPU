`include "dcache_one_line.v"
module dcache_two_way_group(
	input wire 			enable,
	input wire			clk,
	input wire			rst,
	input wire			compare,
	input wire			read,
	input wire[31:0] 	address_in,
	input wire[31:0] 	data_in,
	input wire[3:0]		byte_w_en,
	input wire[255:0]	data_line_in,

	output wire			hit,
	output wire 		dirty,
	output wire  		valid,
	output wire[31:0]   data_out,
	output wire[31:0]	address_out,
	output wire[255:0]	data_line_out
);

	wire   			enable0, enable1;
	wire			hit0, hit1, dirty0, dirty1, valid0, valid1;
	wire[31:0]		data_out0, data_out1, address_out0, address_out1;
	wire[255:0]		data_line_out0, data_line_out1;

	reg  sel;
	initial begin
		sel = 1'b0;
	end
    assign hit = hit0 | hit1;
    assign dirty = hit0 ? dirty0 : (hit1 ? dirty1 : (sel ? dirty1 : dirty0));
    assign valid = hit0 ? valid0 : (hit1 ? valid1 : (sel ? valid1 : valid0));
    assign address_out = enable0 ? address_out0: (enable1 ? address_out1: (sel ? address_out1 : address_out0));
    assign data_line_out = hit0 ? data_line_out0 : (hit1 ? data_line_out1 : (sel ? data_line_out1 : data_line_out0));
    assign data_out = hit0 ? data_out0 : (hit1 ? data_out1 : 0);
    assign enable0 = enable & (compare | !read & (!valid0 & valid1 | !sel));
    assign enable1 = enable & (compare | !read & (!valid1 & valid0 |  sel));
	
	dcache_one_line		dcache_one_line0(
							.enable(enable0),
							.clk(clk),
							.rst(rst),
							.compare(compare),
							.read(read),
							.address_in(address_in),
							.byte_w_en(byte_w_en),
							.data_in(data_in),
							.data_line_in(data_line_in),
							.hit(hit0),
							.dirty(dirty0),
							.valid(valid0),
							.data_out(data_out0),
							.data_line_out(data_line_out0),
							.address_out(address_out0)
						);

	dcache_one_line		dcache_one_line1(
							.enable(enable1),
							.clk(clk),
							.rst(rst),
							.compare(compare),
							.read(read),
							.address_in(address_in),
							.byte_w_en(byte_w_en),
							.data_in(data_in),
							.data_line_in(data_line_in),
							.hit(hit1),
							.dirty(dirty1),
							.valid(valid1),
							.data_out(data_out1),
							.data_line_out(data_line_out1),
							.address_out(address_out1)
						);


    always@(enable or read or compare) begin
       if(enable == 1'b1) begin
          if(read == 1'b1) begin
              if(compare == 1'b0) begin
                 sel = ~sel;
              end
           end
       end
   end


endmodule