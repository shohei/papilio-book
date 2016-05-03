`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:53:41 05/16/2014
// Design Name:   rtl_verilog
// Module Name:   E:/cq/papilio/ise/rtl_verilog/test_rtl_verilog.v
// Project Name:  rtl_verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: rtl_verilog
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_rtl_verilog;

	// Inputs
	reg clk;
	reg reset;
	reg d;
	reg a;
	reg b;
	reg s;

	// Outputs
	wire q;
	wire sel_o;
	wire x;
	wire y;

	// Instantiate the Unit Under Test (UUT)
	rtl_verilog uut (
		.clk(clk), 
		.reset(reset), 
		.d(d), 
		.q(q), 
		.a(a), 
		.b(b), 
		.s(s), 
		.sel_o(sel_o), 
		.x(x), 
		.y(y)
	);

	initial begin
		// Initialize Inputs
		reset = 1;
		d = 0;
		a = 0;
		b = 0;
		s = 0;

		// Wait 100 ns for global reset to finish
		#100;
		reset = 0;
		#100;
		d = 0;
		#100;
		d = 1;
		#100;
		d = 0;
		#100;
		a = 0;
		b = 0;
		#100;
		a = 1;
		b = 0;
		#100;
		a = 0;
		b = 1;
		#100;
		a = 1;
		b = 1;
		#100;
		a = 1;
		b = 0;
		#100;
		s = 1;
		#100;
		a = 0;
		b = 0;
		#100;
		a = 1;
		b = 0;
		#100;
		a = 0;
		b = 1;
		#100;
		a = 1;
		b = 1;
		#100;
		$stop;		
		
		// Add stimulus here

	end
	
   //clkîgå`		  
	initial begin
		repeat(500) begin
		  clk = 0;
		  #5;
		  clk = 1;
		  #5;
		end
   end		
      
endmodule

