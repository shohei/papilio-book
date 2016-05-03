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
module stopwatch (
 clk, rstb,
 start_stop,
 clear,
 t_10ms,
 t_100ms,
 t_1s,
 t_10s
);

input clk;
input rstb;
input start_stop;
input clear;
output[3:0] t_10ms;
output[3:0] t_100ms;
output[3:0] t_1s;
output[3:0] t_10s;
//parameter
parameter p_cnt_10ms = 319999  ; //32MHzで10ms
parameter p_init = 0;
parameter p_stop = 1;
parameter p_count = 2;
reg start_stop_d1;  
reg start_stop_d2;  
reg clear_d1;  
reg clear_d2;  
reg [18:0]base_cnt_10ms;  
wire t_10ms_en_o;
wire t_100ms_en_o;
wire t_1s_en_o;
reg [1:0]state;  
reg tmg_10ms;  
	
//start_stop立下りり検出
always @ (posedge clk )
  if (rstb==1'b0) 
    begin
      start_stop_d1 <= 1'b1;
      start_stop_d2 <= 1'b1;
	end
  else
    begin
      start_stop_d1 <= start_stop;    //1クロック遅延
      start_stop_d2 <= start_stop_d1; //2クロック遅延
	end
	
//立下り条件
assign start_stop_f = ((start_stop_d1==1'b0)&&(start_stop_d2==1'b1))?1'b1:1'b0;

//clear立下りり検出
	always @ (posedge clk )
  if (rstb==1'b0) 
    begin
      clear_d1 <= 1'b1;
      clear_d2 <= 1'b1;
	end
  else
    begin
      clear_d1 <= clear;
      clear_d2 <= clear_d1;
	end

//立下り条件
assign clear_f = ((clear_d1==1'b0)&&(clear_d2==1'b1))?1'b1:1'b0;

//ステートマシン
always @ (posedge clk )
  if (rstb==1'b0)
    state <= p_init;
  else
    case (state)
	//状態 init ---------------------
	   p_init:
         state <= p_stop;
	//状態 stop ---------------------
	   p_stop:
	     if (start_stop_f==1'b1)
           state <= p_count;
		 else if (clear_f==1'b1)
           state <= p_init;
		 else
           state <= p_stop;
	//状態 count ---------------------
	   p_count:
	     if (start_stop_f==1'b1)
           state <= p_stop;
		 else
           state <= p_count;
	   default:
         state <= p_init;
	 endcase    ;

//ベースカウンタ	 
always @ (posedge clk )
  if (state==p_init)
      base_cnt_10ms <= 19'd0;
  else
    if (state==p_count)
      if (base_cnt_10ms==p_cnt_10ms)//10msで0になる
        base_cnt_10ms <= 15'd0;
      else
        base_cnt_10ms <= base_cnt_10ms + 15'd1;
	else
      base_cnt_10ms <= base_cnt_10ms ;

//10msのイネーブ
always @ (posedge clk )
  if (rstb==1'b0)
    tmg_10ms <= 1'b0;
  else
    //状態がcountでベースカウンタが10msの場合
	if ((state==p_count)&&(base_cnt_10ms==p_cnt_10ms))
      tmg_10ms <= 1'b1;
	else
      tmg_10ms <= 1'b0;
	  
//初期化信号
assign init = (state==p_init)?1'b1:1'b0;

//10ms単位のカウンタ	  
dec_count count_10ms(
 .clk(   clk),
 .init(  init),
 .en_i(  tmg_10ms),
 .count( t_10ms),
 .en_o(  t_10ms_en_o)
);
	  
//100ms単位のカウンタ	  
dec_count count_100ms(
 .clk(   clk), 
 .init(  init),
 .en_i(  t_10ms_en_o),
 .count( t_100ms),
 .en_o(  t_100ms_en_o)
);

//1s単位のカウンタ	  
dec_count count_1s(
 .clk(   clk), 
 .init(  init),
 .en_i(  t_100ms_en_o),
 .count( t_1s),
 .en_o(  t_1s_en_o)
);

//10s単位のカウンタ	  
dec_count count_10s(
 .clk(   clk), 
 .init(  init),
 .en_i(  t_1s_en_o),
 .count( t_10s),
 .en_o( )
);

endmodule

