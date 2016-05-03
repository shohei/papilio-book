`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:37:02 05/20/2014
// Design Name:   chattering_cut
// Module Name:   E:/cq/papilio/ise/stopwatch_top/test_chattering_cut.v
// Project Name:  stopwatch_top
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: chattering_cut
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_chattering_cut;

     parameter p_clk_period = 31.25;
	// Inputs
	reg clk;
	reg sw_in;

	// Outputs
	wire sw_out;

	// Instantiate the Unit Under Test (UUT)
	chattering_cut uut (
		.clk(clk), 
		.sw_in(sw_in), 
		.sw_out(sw_out)
	);

        initial begin
                // Initialize Inputs
                repeat(10000000)begin
                clk = 0;
                #(p_clk_period/2);
                clk = 1;
                #(p_clk_period/2);
                end
        end
		
	initial begin
		// Initialize Inputs
		sw_in = 0;
		sw_in = 1;
		// Wait 100 ns for global reset to finish
		 #(p_clk_period*31999);
		sw_in = 0;
		 #(p_clk_period*6000);
		sw_in = 1;
		 #(p_clk_period*6000);
		sw_in = 0;
		 #(p_clk_period*6000);
		sw_in = 1;
		 #(p_clk_period*6000);
		sw_in = 0;
		 #(p_clk_period*100000);
		sw_in = 1;
		 #(p_clk_period*6000);
		sw_in = 0;
		 #(p_clk_period*6000);
		sw_in = 1;
		 #(p_clk_period*6000);
		sw_in = 0;
		 #(p_clk_period*6000);
		sw_in = 1;
		 #(p_clk_period*100000);
         $stop;		 
		// Add stimulus here

	end
      
endmodule

