`timescale 1ns/1ps
`include "defines.v"
`include "openmips_min_sopc.v"

module openmips_min_sopc_tb();

  reg     CLOCK_50;
  reg     rst;
  
       
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,openmips_min_sopc0);
    CLOCK_50 = 1'b0;
    forever #50 CLOCK_50 = ~CLOCK_50;
  end
      
  initial begin
    rst = `RstEnable;
    #100 rst= `RstDisable;
    #9000 $stop;
  end
       
  openmips_min_sopc openmips_min_sopc0(
		.clk(CLOCK_50),
		.rst(rst)	
	);

endmodule