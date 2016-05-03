`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:16:46 05/15/2014
// Design Name:   blink_led
// Module Name:   E:/cq/papilio/ise/blink_led/test_blink_led.v
// Project Name:  blink_led
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: blink_led
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_blink_led;
	// Inputs
	reg clk;
	reg resetb;
	// Outputs
	wire led;
	// Instantiate the Unit Under Test (UUT)
	blink_led uut (
		.clk(clk), 
		.resetb(resetb), 
		.led(led)
	);
   //resetbîgå`
	initial begin
		// Initialize Inputs
		resetb = 0;

		// Wait 100 ns for global reset to finish
		#100;
		resetb = 1;  
	end
   //clkîgå`		  
	initial begin
		repeat(40000000) begin
		  clk = 0;
		  #5;
		  clk = 1;
		  #5;
		end
		$stop;		  

	end
      
endmodule

