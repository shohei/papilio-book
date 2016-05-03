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

parameter p_cnt_max = 9  ;//9�܂ŃJ�E���g
reg [3:0] count;
	  
always @ (posedge clk)
  if (init==1'b1) //������
    count <= 4'd0;
  else
    if (en_i==1'b1) //�C�l�[�u��
      //�J�E���g�A�b�v
      if (count== p_cnt_max)//�ő�l�̎���0
        count <= 4'd0;
      else
        count <= count + 4'd1;
    //�ێ�
    else
      count <= count ;		  
//��ʃJ�E���^�ւ̃C�l�[�u��
assign en_o = ((en_i==1'b1)&&(count== p_cnt_max))?1'b1:1'b0;
		
endmodule

