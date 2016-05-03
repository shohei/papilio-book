`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:51:44 06/05/2014
// Design Name:   mb_mcs_top
// Module Name:   E:/cq/papilio/mb_mcs_top/test_mb_mcs_top.v
// Project Name:  mb_mcs_top
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mb_mcs_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_mb_mcs_top;

	// Inputs
	reg clk;
	reg resetb;
	reg rxd;
	reg [7:0] gpio_i;

	// Outputs
	wire txd;
	wire led;
	wire [7:0] gpio_o;

	// Instantiate the Unit Under Test (UUT)
	mb_mcs_top uut (
		.clk(clk), 
		.resetb(resetb), 
		.txd(txd), 
		.rxd(rxd), 
		.led(led), 
		.gpio_o(gpio_o), 
		.gpio_i(gpio_i)
	);
   //ÉNÉçÉbÉNî≠ê∂
	initial begin
		// Initialize Inputs
		repeat(100000) begin
		  clk = 0;
		  #15.625;
		  clk = 1;
		  #15.625;
		end
		$stop;
        
		// Add stimulus her15.625

	end
	
	initial begin
		// Initialize Inputs
		resetb = 0;
		rxd = 0;
		gpio_i = 0;
		// Wait 100 ns for global reset to finish
		#100;
		resetb = 1;
        
		// Add stimulus here

	end
      
endmodule

