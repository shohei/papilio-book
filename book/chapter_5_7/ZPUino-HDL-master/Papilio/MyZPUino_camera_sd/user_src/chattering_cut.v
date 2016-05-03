//*****************************************************************************
// File Name            : chattering_cut.v
//-----------------------------------------------------------------------------
// Function             :  chattering_cut
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2014/04/19
//*****************************************************************************
module chattering_cut (
 clk,
 sw_in,
 sw_out
);
input clk;
input sw_in;
output sw_out;
parameter p_cnt_hogo_stop =  31999  ; //1ms

reg sw_sync1 =1; //メタステーブル対策DFF  
reg sw_sync2 =1; //メタステーブル対策DFF  
reg sw_d = 1;   // sw_sync2の1クロック遅れ
reg sw_out =1 ; //
reg [14:0]sw_hogo_cnt=0; //入力変化からのクロック数  

always @ (posedge clk )
  begin
    sw_sync1 <= sw_in;    //ステーブル対策1段目
    sw_sync2 <= sw_sync1; //メタステーブル対策2段目
  end

//sw_sync2の1クロック遅れ
always @ (posedge clk )
  sw_d <= sw_sync2; 

//チャタリング防止回路		
always @ (posedge clk  )
  //入力信号の変化を検出
  if (sw_sync2!=sw_d)
    sw_hogo_cnt <= 15'd0;  //クロックのカウント数を0する
  //カウント数が p_cnt_hogo_stopになった場合
  else if (sw_hogo_cnt == p_cnt_hogo_stop)
    sw_hogo_cnt <= p_cnt_hogo_stop;  //カウンタ数を保持
  //カウント数は p_cnt_hogo_stopになってない場合
  else
    sw_hogo_cnt <=  sw_hogo_cnt +15'd1; //カウントアップ

always @ (posedge clk  )
  //カウント数が p_cnt_hogo_stopになった場合
  if (sw_hogo_cnt == p_cnt_hogo_stop)
    sw_out <= sw_d; //出力値を変更
  else
	sw_out <= sw_out; //出力値を保持		
endmodule

