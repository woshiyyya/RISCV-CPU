`include "cache_top.v"
`timescale 1ns / 1ps

module cache_manage_unit #(
    parameter OFFSET_WIDTH = 3,                                         // Block address(offset) width
    parameter INDEX_WIDTH  = 6,                                         // Cache line(group) index width
    parameter ADDR_WIDTH   = 30,                                        // Total address width
    parameter DATA_WIDTH   = 32,                                        // Word size in bit
    // Local parameters
    parameter BLOCK_SIZE   = 1 << OFFSET_WIDTH,                         // Block size in word
    parameter CACHE_DEPTH  = 1 << INDEX_WIDTH,                          // Cache line(group) size
    parameter BLOCK_WIDTH  = DATA_WIDTH * BLOCK_SIZE,                   // A block width is the block size in bit
    parameter TAG_WIDTH    = ADDR_WIDTH - OFFSET_WIDTH - INDEX_WIDTH    // The remaining are tag width
) (
    // From CPU
    input                        clk,//
    input                        rst,//
    input                        dc_read_in,//
    input                        dc_write_in,//
    input [3 : 0]                dc_byte_w_en_in,//
    input [ADDR_WIDTH - 1 : 0]   dc_addr,//
    input [DATA_WIDTH - 1 : 0]   data_from_reg,//

    // From RAM
    input                        ram_ready,  //         // Inform control unit to go on
    input [BLOCK_WIDTH - 1 : 0]  block_from_ram,//      // Total block loaded when cache misses

    // To CPU
    output                       mem_stall,
    output [DATA_WIDTH - 1 : 0]  dc_data_out,//
    // debug
    output reg  [2:0] status,
    // Cache 当前状态，表明 cache 是否*已经*发生缺失以及缺失类型，具体取值参见 status.vh.
    output reg  [2:0] counter,
    // 块内偏移指针/迭代器，用于载入块时逐字写入。

    // To RAM
    output                       ram_en_out,          // Asserted when we need ram to work (load or writeback)
    output                       ram_write_out,       // RAM write enable
    output [ADDR_WIDTH - 1  : 0] ram_addr_out,
    output [BLOCK_WIDTH - 1 : 0] dc_data_wb           // Write back block, _wb for `write back'
);
  
  wire [31:0]   dc_addr_t;
  wire [31:0]   ram_addr_out_t;
  wire          response_data_cache_to_core;
  assign        dc_addr_t =  {dc_addr, 2'b0};
  assign        ram_addr_out = ram_addr_out_t[31:2];
  cache_top  cache_top(
                .rst                    (rst),
                .clk                    (clk),
                .d_cache_read           (dc_read_in),
                .d_cache_write          (dc_write_in),
                .response_ram_to_cache  (ram_ready),
                .byte_w_en              (dc_byte_w_en_in),
                .data_core_to_dcache_i  (data_from_reg),
                .address_core_to_dcache (dc_addr_t),
                .data_ram_to_cache_i    (block_from_ram),
                
                .response_data_cache_to_core    (response_data_cache_to_core),
                .enable_cache_to_ram            (ram_en_out),
                .write_cache_to_ram             (ram_write_out),
                .data_cache_to_core_o           (dc_data_out),
                .address_cache_to_ram           (ram_addr_out_t),
                .data_cache_to_ram_o            (dc_data_wb)
            );

  assign    mem_stall = ((dc_read_in  == 1'b1 | dc_write_in == 1'b1) ? (response_data_cache_to_core == 'b1 ? 0 : 1) : 0); 

endmodule
