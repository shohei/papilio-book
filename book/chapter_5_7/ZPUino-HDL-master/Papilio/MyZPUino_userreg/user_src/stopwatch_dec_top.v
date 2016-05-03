//*****************************************************************************
// File Name            : stopwatch.v
//-----------------------------------------------------------------------------
// Function             : stopwatch
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2014/04/06 
//*****************************************************************************
module stopwatch_dec_top (
 clk, sw_0, sw_1, sw_2,
 t_10ms,t_100ms,t_1s,t_10s
);

input clk;
input sw_0;
input sw_1;
input sw_2;
output[3:0] t_10ms;
output[3:0] t_100ms;
output[3:0] t_1s;
output[3:0] t_10s;

wire start_stop;
wire clear;
wire rstb;

//SW_0 start_stop
chattering_cut chattering_cut_0(
  .clk(clk),
  .sw_in(sw_0),
  .sw_out(start_stop));  

//SW_1 clear
chattering_cut chattering_cut_1(
  .clk(clk),
  .sw_in(sw_1),
  .sw_out(clear));  

//SW_2 rstb
chattering_cut chattering_cut_2(
  .clk(clk),
  .sw_in(sw_2),
  .sw_out(rstb));  

//計測用カウンタ
stopwatch stopwatch (
  .clk(clk),
  .rstb(rstb),
  .start_stop(start_stop),
  .clear(clear),
  //.rstb(sw_2),
  //.start_stop(sw_0),
  //.clear(sw_1),
  . t_10ms(t_10ms),
  . t_100ms(t_100ms),
  . t_1s(t_1s),
  . t_10s(t_10s)
);

		
endmodule

