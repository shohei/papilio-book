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

reg sw_sync1 =1; //���^�X�e�[�u���΍�DFF  
reg sw_sync2 =1; //���^�X�e�[�u���΍�DFF  
reg sw_d = 1;   // sw_sync2��1�N���b�N�x��
reg sw_out =1 ; //
reg [14:0]sw_hogo_cnt=0; //���͕ω�����̃N���b�N��  

always @ (posedge clk )
  begin
    sw_sync1 <= sw_in;    //�X�e�[�u���΍�1�i��
    sw_sync2 <= sw_sync1; //���^�X�e�[�u���΍�2�i��
  end

//sw_sync2��1�N���b�N�x��
always @ (posedge clk )
  sw_d <= sw_sync2; 

//�`���^�����O�h�~��H		
always @ (posedge clk  )
  //���͐M���̕ω������o
  if (sw_sync2!=sw_d)
    sw_hogo_cnt <= 15'd0;  //�N���b�N�̃J�E���g����0����
  //�J�E���g���� p_cnt_hogo_stop�ɂȂ����ꍇ
  else if (sw_hogo_cnt == p_cnt_hogo_stop)
    sw_hogo_cnt <= p_cnt_hogo_stop;  //�J�E���^����ێ�
  //�J�E���g���� p_cnt_hogo_stop�ɂȂ��ĂȂ��ꍇ
  else
    sw_hogo_cnt <=  sw_hogo_cnt +15'd1; //�J�E���g�A�b�v

always @ (posedge clk  )
  //�J�E���g���� p_cnt_hogo_stop�ɂȂ����ꍇ
  if (sw_hogo_cnt == p_cnt_hogo_stop)
    sw_out <= sw_d; //�o�͒l��ύX
  else
	sw_out <= sw_out; //�o�͒l��ێ�		
endmodule

