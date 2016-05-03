//*****************************************************************************
// File Name            : sevenseg_ctrl.v
//-----------------------------------------------------------------------------
// Function             : sevenseg_ctrl
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2014/04/19
//*****************************************************************************
module sevenseg_ctrl (
 clk, rstb,
 t_10ms,
 t_100ms,
 t_1s,
 t_10s,
 com,
 seg_data
);

input clk;
input rstb;
input[3:0] t_10ms;
input[3:0] t_100ms;
input[3:0] t_1s;
input[3:0] t_10s;
output[3:0] com;
output[7:0] seg_data;
//parameter
parameter p_cnt_chg = 31999  ;
//reg
reg[3:0] com;
reg[3:0] seg_data_dec;
reg[7:0] seg_data;
reg seg_dp;
reg [14:0]base_cnt;   
reg [1:0]cnt_segsel;  

//10進数から7セグメントLEDデータへ変換function
function [6:0] dec2seg_data;
  input [3:0]data;
  begin
    case (data)
	  4'h0: dec2seg_data=7'b1000000;
	  4'h1: dec2seg_data=7'b1111001;
	  4'h2: dec2seg_data=7'b0100100;
	  4'h3: dec2seg_data=7'b0110000;
	  4'h4: dec2seg_data=7'b0011001;
	  4'h5: dec2seg_data=7'b0010010;
	  4'h6: dec2seg_data=7'b0000010;
	  4'h7: dec2seg_data=7'b1111000;
	  4'h8: dec2seg_data=7'b0000000;
	  4'h9: dec2seg_data=7'b0010000;
	  default: dec2seg_data=7'b1111111;
	endcase
	end
endfunction

//ダイナミック点灯切替タイミング用カウンタ	  
always @ (posedge clk )
  if (rstb==1'b0)
    base_cnt <= 15'd0;
  else
	if (base_cnt==p_cnt_chg)
      base_cnt <= 15'd0;
	else
      base_cnt <= base_cnt + 15'd1;

//表示位置の決定
always @ (posedge clk )	   
  if (rstb==1'b0)
    cnt_segsel <= 2'd0;
  else
	if (base_cnt==p_cnt_chg)
      cnt_segsel <= cnt_segsel + 2'd1;
	else
      cnt_segsel <= cnt_segsel;

//common端子の制御
always @ (posedge clk )
  if (rstb==1'b0)
    com <= 4'b111;
  else
    case(cnt_segsel)
	  2'b00:com<=4'b1110;
	  2'b01:com<=4'b1101;
	  2'b10:com<=4'b1011;
	  2'b11:com<=4'b0111;
	  default:com<=4'b1111;
	endcase
	
//表示データの選択		
always @ (posedge clk  )
  if (rstb==1'b0)
    begin
      seg_data_dec <= 4'd0;
	  seg_dp <= 1'b1;
	end
  else
    case(cnt_segsel)
	  2'b00:begin
	    seg_data_dec<=t_10ms;
	    seg_dp <= 1'b1;
	  end
	  2'b01:begin
	    seg_data_dec<=t_100ms;
	    seg_dp <= 1'b1;
	  end
	  2'b10:begin
	    seg_data_dec<=t_1s;
	    seg_dp <= 1'b0;
	  end
	  2'b11:begin
	    seg_data_dec<=t_10s;
	    seg_dp <= 1'b1;
	  end
	  default:begin
	    seg_data_dec<=4'd0;
	    seg_dp <= 1'b1;
	  end
	endcase
	
//10進から7セグメントLEDのセグメントデータに変換	
always @ (posedge clk )
  if (rstb==1'b0)
    seg_data <= 8'b11111111;
  else
	seg_data <= {seg_dp,dec2seg_data( seg_data_dec)};
	
endmodule

