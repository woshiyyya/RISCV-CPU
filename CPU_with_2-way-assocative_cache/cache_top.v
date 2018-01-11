module cache_top(
	//Input
	rst, clk, 
	byte_w_en, d_cache_read, d_cache_write, 
	data_core_to_dcache_i, 
	address_core_to_dcache,
	response_ram_to_cache, 
	data_ram_to_cache_i,
	//Output
	response_data_cache_to_core, 
	data_cache_to_core_o,
	enable_cache_to_ram,
	write_cache_to_ram,
	data_cache_to_ram_o, 
	address_cache_to_ram
	);
	input 		rst, clk, d_cache_read, d_cache_write, response_ram_to_cache;
	input[3:0]	byte_w_en;
	input[31:0]	data_core_to_dcache_i, address_core_to_dcache;
	input[255:0]data_ram_to_cache_i;

	output 			response_data_cache_to_core, enable_cache_to_ram, write_cache_to_ram;
	output[31:0]	data_cache_to_core_o, address_cache_to_ram;
	output[255:0]	data_cache_to_ram_o;

	wire 	d_cache_miss, d_cache_dirty, d_cache_hit;
	wire 	d_cache_enable, d_cache_compare, d_cache_read_o, d_cache_addr_ctr;
	wire 	addr_cache_to_ram_ctr, enable_cache_to_ram;
	cache_control	cache_control0(
						//input
						.clk					(clk),
						.rst					(rst),
						.d_cache_read			(d_cache_read),
						.d_cache_write			(d_cache_write),
						.response_ram_to_cache	(response_ram_to_cache),
						.d_cache_miss			(d_cache_miss),
						.d_cache_dirty			(d_cache_dirty),
						.d_cache_hit			(d_cache_hit),
						//output
						.d_cache_enable			(d_cache_enable),
						.d_cache_compare		(d_cache_compare),
						.d_cache_read_o			(d_cache_read_o), 
						.enable_cache_to_ram	(enable_cache_to_ram), 
						.write_cache_to_ram		(write_cache_to_ram),
						.response_data_cache_to_core(response_data_cache_to_core)
					);

	wire[31:0]	d_cache_addr_in;
	wire[31:0]	d_cache_address_out;
	wire 		d_cache_valid;
	assign 		d_cache_addr_in = address_core_to_dcache;
	assign 		d_cache_miss 	= ~d_cache_hit;

	dcache_two_way_group	dcache_two_way_group0(
								.enable			(d_cache_enable),
								.clk			(clk),
								.rst			(rst),
								.compare		(d_cache_compare),
								.read			(d_cache_read_o),
								.address_in		(d_cache_addr_in),
								.byte_w_en		(byte_w_en),
								.data_in		(data_core_to_dcache_i),
								.data_line_in	(data_ram_to_cache_i),
								.hit			(d_cache_hit),
								.dirty			(d_cache_dirty),
								.valid			(d_cache_valid),
								.data_out		(data_cache_to_core_o),
								.data_line_out	(data_cache_to_ram_o),
								.address_out	(d_cache_address_out)
							);

	assign address_cache_to_ram = d_cache_address_out; 
	
endmodule