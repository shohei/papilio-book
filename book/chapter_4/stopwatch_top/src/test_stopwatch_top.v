`timescale 1ns / 1ps
module test_stopwatch_top ;
  //parameter
  parameter p_clk_period = 31.25;
  // Inputs
  reg clk;
  reg sw_0;
  reg sw_1;
  reg sw_2;
  // Output
  wire[3:0] com;
  wire[7:0] seg_data;
  wire led;

stopwatch_top uut (
  .clk(clk),
  .sw_0(sw_0),
  .sw_1(sw_1),
  .sw_2(sw_2),
  .com(com),
  .seg_data(seg_data),
  .led(led)
);

initial begin
  repeat(200000000)begin
    clk = 0;
    #(p_clk_period/2);
    clk = 1;
    #(p_clk_period/2);
  end
end
   
initial begin
  sw_2 = 0;
  sw_0 = 1;
  sw_1 = 1;
  #(p_clk_period*400000);
  sw_2 = 1;
  #(p_clk_period*500000);
  sw_0 = 0;
  #(p_clk_period*500000);
  sw_0 = 1;  
  #(p_clk_period*7000000);
  sw_0 = 0;
  #(p_clk_period*500000);
  sw_0 = 1;
  #(p_clk_period*1000000);
  sw_1 = 0;
  #(p_clk_period*500000);
  sw_1 = 1;
  #(p_clk_period*500000);
  $stop;
end
   
endmodule

