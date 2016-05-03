//*****************************************************************************
// File Name            : ov7670_cmd_gen.v
//-----------------------------------------------------------------------------
// Function             : ov7670 generator
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2010/8/27
// -.-- 2010/11/17
//*****************************************************************************
module ov7670_cmd_gen(
RESETB, 
CLK,
RX_DATA,
RX_DATA_EN,
CMD_WR,      
CMD_RD,
CMD_ADR,
CMD_DATA,
RGB_SEL
);
//            PIN NAME         description        
input         RESETB;        // power on reset    
input         CLK;           // main clk          
//                                      
input   [7:0]RX_DATA;        //rx data 8bit
input        RX_DATA_EN;     //rx data enable
output   CMD_WR;
output   CMD_RD;
output  [7:0] CMD_ADR;
output  [7:0] CMD_DATA;
output  [8:0] RGB_SEL;
   
//
        
parameter       p_bit_end_count    =12'd346; // 115.2Kbps clk=40.0MHz
//parameter     p_bit_end_count    =12'd136; // 460.8Kbps clk=62.5MHz
//   
reg   CMD_WR;
reg   CMD_RD;
reg  [7:0] CMD_ADR;
reg  [7:0] CMD_DATA;
reg  [8:0] RGB_SEL;
wire [11:0] rgb_sel_tmp;
//
reg [7:0]     rx_data_d1;   
reg [7:0]     rx_data_d2;   
reg [7:0]     rx_data_d3;
reg [7:0]     rx_data_d4;
reg [7:0]     rx_data_d5;
reg [7:0]     rx_data_d6;
reg [7:0]     rx_data_d7;
reg           rx_data_en_d1;   

function [3:0] ascii2hex;
  input [7:0] ascii;
  begin
    if((ascii>=8'h30)&&(ascii<=8'h39))
      ascii2hex = ascii - 8'h30;
    else if((ascii>=8'h41)&&(ascii<=8'h46)) 
      ascii2hex = ascii - 8'h37;
    else
      ascii2hex = 4'h0;
  end
endfunction
   
//
//  コマンド受信
//
//format [W/R],ADR[7:4],ADR[3:0],DATA[7:4],DATA[3:0],CR,LF
//       d7   ,d6      ,d5      ,d4       ,d3       ,d2,d1
always @(posedge CLK or negedge RESETB) begin
  if (RESETB==1'b0)
    begin
      rx_data_d1 <= 8'h00;
      rx_data_d2 <= 8'h00;
      rx_data_d3 <= 8'h00;
      rx_data_d4 <= 8'h00;
      rx_data_d5 <= 8'h00;
      rx_data_d6 <= 8'h00;
      rx_data_d7 <= 8'h00;
      rx_data_en_d1 <= 1'b0;
    end
  else
    if (RX_DATA_EN==1'b1)
      begin
        rx_data_d1 <= RX_DATA;
        rx_data_d2 <= rx_data_d1;
        rx_data_d3 <= rx_data_d2;
        rx_data_d4 <= rx_data_d3;
        rx_data_d5 <= rx_data_d4;
        rx_data_d6 <= rx_data_d5;
        rx_data_d7 <= rx_data_d6;
        rx_data_en_d1 <= 1'b1;
      end
    else
      begin
        rx_data_d1 <= rx_data_d1;
        rx_data_d2 <= rx_data_d2;
        rx_data_d3 <= rx_data_d3;
        rx_data_d4 <= rx_data_d4;
        rx_data_d5 <= rx_data_d5;
        rx_data_d6 <= rx_data_d6;
        rx_data_d7 <= rx_data_d7;
        rx_data_en_d1 <= 1'b0;
      end 
end 
   
//i2cコマンド生成    
always @(posedge CLK or negedge RESETB) begin
  if (RESETB==1'b0)
    begin
       CMD_WR <= 1'b0;
       CMD_RD <= 1'b0;
       CMD_ADR <= 8'h00;
       CMD_DATA <= 8'h00;
    end
  else
    if ((rx_data_en_d1==1'b1)&&(rx_data_d1==8'h0a)) //data=LF
      begin
        if (rx_data_d7==8'h57) //"W"
          CMD_WR <= 1'b1;
        else
          CMD_WR <= 1'b0;
        if (rx_data_d7==8'h52) //R"
          CMD_RD <= 1'b1;
        else
         CMD_RD <= 1'b0;
        CMD_ADR <= {ascii2hex(rx_data_d6),ascii2hex(rx_data_d5)};
        CMD_DATA <= {ascii2hex(rx_data_d4),ascii2hex(rx_data_d3)};
      end
    else
      begin
       CMD_WR <= 1'b0;
       CMD_RD <= 1'b0;
       CMD_ADR <= CMD_ADR;
       CMD_DATA <= CMD_DATA;
      end 
end 

//データ出力順序選択   
assign rgb_sel_tmp = {ascii2hex(rx_data_d6),ascii2hex(rx_data_d5),ascii2hex(rx_data_d4)};
   
always @(posedge CLK or negedge RESETB) begin
  if (RESETB==1'b0)
    begin
       RGB_SEL <= 9'b011010001; //3_2_1
    end
  else
    if ((rx_data_en_d1==1'b1)&&(rx_data_d1==8'h0a)) //data=LF
      if (rx_data_d7==8'h53) //"S"
        RGB_SEL <= {rgb_sel_tmp[10:8],rgb_sel_tmp[6:4],rgb_sel_tmp[2:0]};
      else
        RGB_SEL <= RGB_SEL;
    else
      RGB_SEL <= RGB_SEL;
end 

       
endmodule
