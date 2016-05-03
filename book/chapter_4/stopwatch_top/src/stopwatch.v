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
parameter p_cnt_10ms = 319999  ; //32MHz��10ms
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
	
//start_stop������茟�o
always @ (posedge clk )
  if (rstb==1'b0) 
    begin
      start_stop_d1 <= 1'b1;
      start_stop_d2 <= 1'b1;
	end
  else
    begin
      start_stop_d1 <= start_stop;    //1�N���b�N�x��
      start_stop_d2 <= start_stop_d1; //2�N���b�N�x��
	end
	
//���������
assign start_stop_f = ((start_stop_d1==1'b0)&&(start_stop_d2==1'b1))?1'b1:1'b0;

//clear������茟�o
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

//���������
assign clear_f = ((clear_d1==1'b0)&&(clear_d2==1'b1))?1'b1:1'b0;

//�X�e�[�g�}�V��
always @ (posedge clk )
  if (rstb==1'b0)
    state <= p_init;
  else
    case (state)
	//��� init ---------------------
	   p_init:
         state <= p_stop;
	//��� stop ---------------------
	   p_stop:
	     if (start_stop_f==1'b1)
           state <= p_count;
		 else if (clear_f==1'b1)
           state <= p_init;
		 else
           state <= p_stop;
	//��� count ---------------------
	   p_count:
	     if (start_stop_f==1'b1)
           state <= p_stop;
		 else
           state <= p_count;
	   default:
         state <= p_init;
	 endcase    ;

//�x�[�X�J�E���^	 
always @ (posedge clk )
  if (state==p_init)
      base_cnt_10ms <= 19'd0;
  else
    if (state==p_count)
      if (base_cnt_10ms==p_cnt_10ms)//10ms��0�ɂȂ�
        base_cnt_10ms <= 15'd0;
      else
        base_cnt_10ms <= base_cnt_10ms + 15'd1;
	else
      base_cnt_10ms <= base_cnt_10ms ;

//10ms�̃C�l�[�u
always @ (posedge clk )
  if (rstb==1'b0)
    tmg_10ms <= 1'b0;
  else
    //��Ԃ�count�Ńx�[�X�J�E���^��10ms�̏ꍇ
	if ((state==p_count)&&(base_cnt_10ms==p_cnt_10ms))
      tmg_10ms <= 1'b1;
	else
      tmg_10ms <= 1'b0;
	  
//�������M��
assign init = (state==p_init)?1'b1:1'b0;

//10ms�P�ʂ̃J�E���^	  
dec_count count_10ms(
 .clk(   clk),
 .init(  init),
 .en_i(  tmg_10ms),
 .count( t_10ms),
 .en_o(  t_10ms_en_o)
);
	  
//100ms�P�ʂ̃J�E���^	  
dec_count count_100ms(
 .clk(   clk), 
 .init(  init),
 .en_i(  t_10ms_en_o),
 .count( t_100ms),
 .en_o(  t_100ms_en_o)
);

//1s�P�ʂ̃J�E���^	  
dec_count count_1s(
 .clk(   clk), 
 .init(  init),
 .en_i(  t_100ms_en_o),
 .count( t_1s),
 .en_o(  t_1s_en_o)
);

//10s�P�ʂ̃J�E���^	  
dec_count count_10s(
 .clk(   clk), 
 .init(  init),
 .en_i(  t_1s_en_o),
 .count( t_10s),
 .en_o( )
);

endmodule

