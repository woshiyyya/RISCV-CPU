module cache_control(
	//Input
	clk, rst, d_cache_read, d_cache_write, response_ram_to_cache,
	d_cache_miss, d_cache_dirty, d_cache_hit,

	//Output
	d_cache_enable, d_cache_compare, d_cache_read_o,
	enable_cache_to_ram, write_cache_to_ram, response_data_cache_to_core
	);
	input	clk;
	input	rst;
	input	d_cache_read;
	input	d_cache_write;
	input	response_ram_to_cache;

	input	d_cache_miss;
	input	d_cache_dirty;
	input	d_cache_hit;

	output reg	d_cache_enable;
	output reg	d_cache_compare;
	output reg	d_cache_read_o;

	output reg	enable_cache_to_ram;
	output reg	write_cache_to_ram;
	output reg	response_data_cache_to_core;

	reg[3:0] state0;

	initial begin
		state0 = 0;
	end

	always@(posedge clk) begin
		case(state0)
			0: begin
				if(d_cache_read == 1'b1)
					state0	<=	1;
				else if(d_cache_write == 1'b1)
					state0 	<= 	2;
			end
			1: begin
				if(d_cache_hit == 1'b1)
					state0	<=	3;
				else if(d_cache_miss == 1'b1 && d_cache_dirty == 1'b0)
					state0	<=	5;
				else if(d_cache_miss == 1'b1 && d_cache_dirty == 1'b1)
					state0	<=	4;
				else
				    state0	<=	1;
			end
			2: begin
				if(d_cache_hit == 1'b1)
					state0	<=	3;
				else if(d_cache_miss == 1'b1 && d_cache_dirty == 1'b0)
					state0 	<=	5;
				else if(d_cache_miss == 1'b1 && d_cache_dirty == 1'b1)
					state0 	<=	4;
			end
			3: begin
				state0	<=	0;
			end
			4: begin
				if(response_ram_to_cache == 1'b1)
					state0 	<=	5;
			end
			5: begin
				if(response_ram_to_cache == 1'b1)
					state0 	<=	6;
			end
			6: begin
				if(d_cache_read == 1'b1)
					state0	<=	1;
				else if(d_cache_write == 1'b1)
					state0	<=	2;
			end
		endcase
	end

	always@(state0) begin
		case(state0)
			0: begin
				d_cache_enable				<=	0;
				d_cache_compare				<=	0;
				d_cache_read_o				<=	0;
				enable_cache_to_ram			<=	0;
				write_cache_to_ram			<=	0;
				response_data_cache_to_core	<=	0;
			end
			1: begin
				d_cache_enable				<=	1;
				d_cache_compare				<=	1;
				d_cache_read_o				<=	1;
				enable_cache_to_ram			<=	0;
				write_cache_to_ram			<=	0;
				response_data_cache_to_core	<=	0;
			end
			2: begin
				d_cache_enable				<=	1;
				d_cache_compare				<=	1;
				d_cache_read_o				<=	0;
				enable_cache_to_ram			<=	0;
				write_cache_to_ram			<=	0;
				response_data_cache_to_core	<=	0;
			end
			3: begin
				d_cache_enable				<=	0;
				d_cache_compare				<=	1;
				d_cache_read_o				<=	0;
				enable_cache_to_ram			<=	0;
				write_cache_to_ram			<=	0;
				response_data_cache_to_core	<=	1;
			end
			4: begin
				d_cache_enable				<=	0;
				d_cache_compare				<=	0;
				d_cache_read_o				<=	0;
				enable_cache_to_ram			<=	1;
				write_cache_to_ram			<=	1;
				response_data_cache_to_core	<=	0;
			end
			5: begin
				d_cache_enable				<=	1;
				d_cache_compare				<=	0;
				d_cache_read_o				<=	0;
				enable_cache_to_ram			<=	1;
				write_cache_to_ram			<=	0;
				response_data_cache_to_core	<=	0;
			end
			6: begin
				d_cache_enable				<=	1;
				d_cache_compare				<=	0;
				d_cache_read_o				<=	0;
				enable_cache_to_ram			<=	0;
				write_cache_to_ram			<=	0;
				response_data_cache_to_core	<=	0;
			end
	    endcase
	end

endmodule