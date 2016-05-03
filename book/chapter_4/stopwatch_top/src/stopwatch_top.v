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
module stopwatch_top (
 clk, sw_0, sw_1, sw_2,
 com, seg_data, led
);

input clk;
input sw_0;
input sw_1;
input sw_2;
output[3:0] com;
output[7:0] seg_data;
output led;

wire start_stop;
wire clear;
wire[3:0] t_10ms;
wire[3:0] t_100ms;
wire[3:0] t_1s;
wire[3:0] t_10s;
reg[23:0] cnt_led ;

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
  . t_10ms(t_10ms),
  . t_100ms(t_100ms),
  . t_1s(t_1s),
  . t_10s(t_10s)
);

//7セグメントLEDダイナミック点灯制御
sevenseg_ctrl sevenseg_ctrl (
  .clk(clk),
  .rstb(rstb),
  . t_10ms(t_10ms),
  . t_100ms(t_100ms),
  . t_1s(t_1s),
  . t_10s(t_10s),
  .com(com),
  .seg_data(seg_data)
);

//起動確認用LED
always @ (posedge clk )
if(rstb==1'b0)
  cnt_led <= 24'd0;
else
  cnt_led <= cnt_led + 24'd1;
	
assign led = cnt_led[23];
		
endmodule

