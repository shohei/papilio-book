//*****************************************************************************
// File Name            : dec_count.v
//-----------------------------------------------------------------------------
// Function             : dec_count
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2014/05/20 
//*****************************************************************************
module dec_count (
 clk,init,en_i,count,en_o
);
input clk;
input init;
input en_i;
output[3:0] count;
output en_o;

parameter p_cnt_max = 9  ;//9までカウント
reg [3:0] count;
	  
always @ (posedge clk)
  if (init==1'b1) //初期化
    count <= 4'd0;
  else
    if (en_i==1'b1) //イネーブル
      //カウントアップ
      if (count== p_cnt_max)//最大値の次は0
        count <= 4'd0;
      else
        count <= count + 4'd1;
    //保持
    else
      count <= count ;		  
//上位カウンタへのイネーブル
assign en_o = ((en_i==1'b1)&&(count== p_cnt_max))?1'b1:1'b0;
		
endmodule

