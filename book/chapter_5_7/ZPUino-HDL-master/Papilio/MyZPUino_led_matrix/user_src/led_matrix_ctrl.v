`timescale 1ns / 1ps
//*****************************************************************************
// File Name            : zpuino_userreg.v
//-----------------------------------------------------------------------------
// Function             : USER REG for ZPUINO
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2014/06/19
//*****************************************************************************
module led_matrix_ctrl(
    wb_clk_i,
	wb_rst_i,
    wb_dat_o,
    wb_dat_i,
    wb_adr_i,
    wb_we_i,
    wb_cyc_i,
    wb_stb_i,
    wb_ack_o,
    wb_inta_o,
    led_a_com,
    led_r,
    led_g,
    led_b
    );

    input wb_clk_i;
	input wb_rst_i;
    output [31:0] wb_dat_o;
    input [31:0] wb_dat_i;
    input [26:2] wb_adr_i;
    input wb_we_i;
    input wb_cyc_i;
    input wb_stb_i;
    output wb_ack_o;
    output wb_inta_o;
	//	
    output [7:0]led_a_com;
    output [7:0]led_r;
    output [7:0]led_g;
    output [7:0]led_b;
	
parameter p_cnt_2ms_max = 16'd63399;	

reg [15:0]cnt_2ms ;
reg [2:0] cnt_row ;
reg [31:0] r_data_0;
reg [31:0] r_data_1;
reg [31:0] g_data_0;
reg [31:0] g_data_1;
reg [31:0] b_data_0;
reg [31:0] b_data_1;
reg [7:0]led_a_com;
reg [7:0]led_r;
reg [7:0]led_g;
reg [7:0]led_b;
  
reg wb_ack_o;
reg [31:0] wb_dat_o;
	
//----------------------------------------------------------------------------
//WISHBONE BSU IF	
//----------------------------------------------------------------------------
	
assign wb_inta_o = 1'b0;

//ACK生成
always@(posedge wb_clk_i )
  if(( wb_cyc_i == 1'b1)&&(wb_stb_i==1'b1)&&(wb_ack_o==1'b0)) 
	wb_ack_o <= 1'b1;
  else
	wb_ack_o <= 1'b0;

///BUS書き込みデータの保存
always@(posedge wb_clk_i )
  if (wb_rst_i==1'b1) 
       r_data_0<= 32'h00000000;
  else
    if ((wb_stb_i==1'b1) && (wb_cyc_i==1'b1) && (wb_we_i==1'b1 ))
       if (wb_adr_i[5:2]==4'h0)
         r_data_0 <= wb_dat_i;	
       else
         r_data_0 <=r_data_0;
    else
      r_data_0 <=r_data_0;
	
always@(posedge wb_clk_i )
  if (wb_rst_i==1'b1) 
       r_data_1<= 32'h00000000;
  else
    if ((wb_stb_i==1'b1) && (wb_cyc_i==1'b1) && (wb_we_i==1'b1 ))
       if (wb_adr_i[5:2]==4'h1)
         r_data_1 <= wb_dat_i;	
       else
         r_data_1 <=r_data_1;
    else
      r_data_1 <=r_data_1;

  
always@(posedge wb_clk_i )
  if (wb_rst_i==1'b1) 
       g_data_0<= 32'h00000000;
  else
    if ((wb_stb_i==1'b1) && (wb_cyc_i==1'b1) && (wb_we_i==1'b1 ))
       if (wb_adr_i[5:2]==4'h2)
         g_data_0 <= wb_dat_i;	
       else
         g_data_0 <=g_data_0;
    else
      g_data_0 <=g_data_0;
	
always@(posedge wb_clk_i )
  if (wb_rst_i==1'b1) 
       g_data_1<= 32'h00000000;
  else
    if ((wb_stb_i==1'b1) && (wb_cyc_i==1'b1) && (wb_we_i==1'b1 ))
       if (wb_adr_i[5:2]==4'h3)
         g_data_1 <= wb_dat_i;	
       else
         g_data_1 <=g_data_1;
    else
      g_data_1 <=g_data_1;
	  
always@(posedge wb_clk_i )
  if (wb_rst_i==1'b1) 
       b_data_0<= 32'h00000000;
  else
    if ((wb_stb_i==1'b1) && (wb_cyc_i==1'b1) && (wb_we_i==1'b1 ))
       if (wb_adr_i[5:2]==4'h4)
         b_data_0 <= wb_dat_i;	
       else
         b_data_0 <=b_data_0;
    else
      b_data_0 <=b_data_0;
	
always@(posedge wb_clk_i )
  if (wb_rst_i==1'b1) 
       b_data_1<= 32'h00000000;
  else
    if ((wb_stb_i==1'b1) && (wb_cyc_i==1'b1) && (wb_we_i==1'b1 ))
       if (wb_adr_i[5:2]==4'h5)
         b_data_1 <= wb_dat_i;	
       else
         b_data_1 <=b_data_1;
    else
      b_data_1 <=b_data_1;	  
	
//BUS読み出しデータの選択   
always@(posedge wb_clk_i )
  if (wb_rst_i==1'b1) 
    wb_dat_o <= 32'h00000000;
  else
    case(wb_adr_i[5:2])
	  4'd0:wb_dat_o <= r_data_0;
	  4'd1:wb_dat_o <= r_data_1;
	  4'd2:wb_dat_o <= g_data_0;
	  4'd3:wb_dat_o <= g_data_1;
	  4'd4:wb_dat_o <= b_data_0;
	  4'd5:wb_dat_o <= b_data_1;
      default:	wb_dat_o <= 32'h00000000;
    endcase

	
//----------------------------------------------------------------------------
//LED MATRIX CONTROLLER
//----------------------------------------------------------------------------
	
//2ms周期のカウンタ
always@(posedge wb_clk_i )
  if (wb_rst_i==1'b1)
    cnt_2ms <= 16'd0;
  else
    if (cnt_2ms==p_cnt_2ms_max) 
      cnt_2ms <= 16'd0;
	else
      cnt_2ms <= cnt_2ms + 16'd1;
	  
//2ms周期でrowの切替
always@(posedge wb_clk_i )
  if (wb_rst_i==1'b1)
    cnt_row <= 3'd0;
  else
    if(cnt_2ms==p_cnt_2ms_max) 
      cnt_row <= cnt_row + 3'd1;
	else
      cnt_row <= cnt_row ;

 //cnt_rowに従ってカソードコモンを制御 
always@(posedge wb_clk_i )
  if (wb_rst_i==1'b1)
    led_a_com <= 8'h00;
  else
    if((cnt_2ms>=(p_cnt_2ms_max-511))|| (cnt_2ms<=127) )
      led_a_com <= 8'h00;
 	else
      case(cnt_row)
        //シンクドライバはHiで電流が流れ込む
	    3'd0:led_a_com <= 8'h1;  //1row表示
	    3'd1:led_a_com <= 8'h2;  //2row表示
	    3'd2:led_a_com <= 8'h4;  //3row表示
	    3'd3:led_a_com <= 8'h8;  //4row表示
	    3'd4:led_a_com <= 8'h10; //5row表示
	    3'd5:led_a_com <= 8'h20; //6row表示
	    3'd6:led_a_com <= 8'h40; //7row表示
	    3'd7:led_a_com <= 8'h80; //8row表示
	    default:led_a_com <= 8'h00;
	  endcase
  
//cnt_rowに従ってレジスタを選択して赤色LEDのアノードを制御 
always@(posedge wb_clk_i )
  if (wb_rst_i==1'b1)
    led_r <= 8'h00;
  else
    case(cnt_row)
     //ソースドライバはHiで電流が流れる
	  3'd0: led_r <= r_data_0[7:0];
	  3'd1: led_r <= r_data_0[15:8];
	  3'd2: led_r <= r_data_0[23:16];
	  3'd3: led_r <= r_data_0[31:24];
	  3'd4: led_r <= r_data_1[7:0];
	  3'd5: led_r <= r_data_1[15:8];
	  3'd6: led_r <= r_data_1[23:16];
	  3'd7: led_r <= r_data_1[31:24];
	  default:led_r <= 8'h00;
	endcase
	
//cnt_rowに従ってレジスタを選択して緑色LEDのアノードを制御 	
always@(posedge wb_clk_i )
  if (wb_rst_i==1'b1)
    led_g <= 8'h00;
  else
    case(cnt_row)
	  3'd0: led_g <= g_data_0[7:0];
	  3'd1: led_g <= g_data_0[15:8];
	  3'd2: led_g <= g_data_0[23:16];
	  3'd3: led_g <= g_data_0[31:24];
	  3'd4: led_g <= g_data_1[7:0];
	  3'd5: led_g <= g_data_1[15:8];
	  3'd6: led_g <= g_data_1[23:16];
	  3'd7: led_g <= g_data_1[31:24];
	  default:led_g <= 8'h00;
	endcase
	
//cnt_rowに従ってレジスタを選択して青色LEDのアノードを制御 
always@(posedge wb_clk_i )
  if (wb_rst_i==1'b1)
    led_b <= 8'h00;
  else
    case(cnt_row)
	  3'd0: led_b <= b_data_0[7:0];
	  3'd1: led_b <= b_data_0[15:8];
	  3'd2: led_b <= b_data_0[23:16];
	  3'd3: led_b <= b_data_0[31:24];
	  3'd4: led_b <= b_data_1[7:0];
	  3'd5: led_b <= b_data_1[15:8];
	  3'd6: led_b <= b_data_1[23:16];
	  3'd7: led_b <= b_data_1[31:24];
	  default:led_b <= 8'h00;
	endcase
	
	
endmodule
