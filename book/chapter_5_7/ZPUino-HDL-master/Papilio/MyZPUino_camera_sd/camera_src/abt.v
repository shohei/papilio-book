//*****************************************************************************
// File Name            : abt.v
//-----------------------------------------------------------------------------
// Function             : data arbitartor
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2010/11/5
//*****************************************************************************
module abt
( CLK,
  RESET_N,
  A_REQ,
  A_REDAY,
  A_DAT_EN,
  A_DAT,
  B_REQ,
  B_REDAY,
  B_DAT_EN,
  B_DAT,
  O_REQ,
  O_REDAY,
  O_DAT,
  O_DAT_EN
); 

parameter data_width = 8   ;
parameter data_no = data_width -1;
   
parameter s_idle =   4'd0   ;
parameter s_a_req =  4'd1   ;
parameter s_a_send = 4'd2   ;
parameter s_b_req =  4'd5   ;
parameter s_b_send = 4'd6   ;
   
input                   CLK;
input                   RESET_N;
input                   A_REQ;
output                  A_REDAY;
input                   A_DAT_EN;
input     [data_no:0]   A_DAT;
input                   B_REQ;
output                  B_REDAY;
input                   B_DAT_EN;
input     [data_no:0]   B_DAT;
output                   O_REQ;
input                  O_REDAY;
output                   O_DAT_EN;
output     [data_no:0]   O_DAT;

reg  [3:0]              abt_state;
    
 
  
always @( posedge CLK or negedge RESET_N )
  begin
    if (RESET_N==1'b0)
      abt_state <= s_idle;
    else
      case (abt_state)
        s_idle:begin
          if (A_REQ==1'b1)
            abt_state <=s_a_req;
          else if (B_REQ==1'b1)
            abt_state <= s_b_req;
          else
            abt_state <= s_idle;
          end
        s_a_req:begin
          if (O_REDAY==1'b1)
            abt_state <= s_a_send;
          else
            abt_state <= s_a_req;             
          end
        s_a_send:begin
          if ((A_REQ==1'b0)||(O_REDAY==1'b0))
            abt_state <= s_idle;
          else
            abt_state <= s_a_send;             
          end
        s_b_req:begin
          if (O_REDAY==1'b1)
            abt_state <= s_b_send;
          else
            abt_state <= s_b_req;             
          end
        s_b_send:begin
          if ((B_REQ==1'b0)||(O_REDAY==1'b0))
            abt_state <= s_idle;
          else
            abt_state <= s_b_send;             
          end
        default:begin
           abt_state <= s_idle;
          end
        endcase
end 

assign A_REDAY = ((abt_state==s_a_send)&&(O_REDAY==1'b1))?1'b1:1'b0;
assign B_REDAY = ((abt_state==s_b_send)&&(O_REDAY==1'b1))?1'b1:1'b0;
assign O_REQ = ((A_REQ==1'b1)||(B_REQ==1'b1))?1'b1:1'b0;

assign O_DAT_EN =(abt_state==s_a_send)? A_DAT_EN:
                 (abt_state==s_b_send)? B_DAT_EN:1'b0;

assign O_DAT  =(abt_state==s_a_send)? A_DAT:
               (abt_state==s_b_send)? B_DAT:0;

endmodule
