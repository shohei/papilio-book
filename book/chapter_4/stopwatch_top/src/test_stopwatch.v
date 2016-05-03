`timescale 1ns / 1ps

module test_stopwatch ;
        //parameter
        parameter p_clk_period = 31.25;

        // Inputs
        reg clk;
        reg rstb;
        reg start_stop;
        reg clear;
		
        wire[3:0] t_10ms;
        wire[3:0] t_100ms;
        wire[3:0] t_1s;
        wire[3:0] t_10s;

        // Instantiate the Unit Under Test (UUT)
        stopwatch uut (
                .clk(clk),
                .rstb(rstb),
				.start_stop(start_stop),
				.clear(clear),
                . t_10ms(t_10ms),
                . t_100ms(t_100ms),
                . t_1s(t_1s),
                . t_10s(t_10s)
        );

        initial begin
                // Initialize Inputs
                repeat(1000000000)begin
                clk = 0;
                #(p_clk_period/2);
                clk = 1;
                #(p_clk_period/2);
                end
        end
   
        initial begin
                // Initialize Inputs
                rstb = 0;
                start_stop = 1;
                clear = 1;
                #(p_clk_period*2);
                rstb = 1;
                #(p_clk_period*500000);
                start_stop = 0;
                #(p_clk_period*500000);
                start_stop = 1;
                #(p_clk_period*100000000);
                start_stop = 0;
                #(p_clk_period*500000);
                start_stop = 1;
                #(p_clk_period*300000);
                clear = 0;
                #(p_clk_period*500000);
                clear = 1;
                #(p_clk_period*500000);
                $stop;
                // Add stimulus here

        end
      
   
endmodule

