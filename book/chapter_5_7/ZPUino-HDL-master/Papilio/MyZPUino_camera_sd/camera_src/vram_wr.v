//*****************************************************************************
// File Name            : vram_wr.v
//-----------------------------------------------------------------------------
// Function             : gazou gen layer_d (background) 
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo@himwari_co 
//-----------------------------------------------------------------------------
// History
// -.-- 2010/9/22
// -.-- 2010/11/17
//*****************************************************************************
module vram_wr (
  pclk,    
  c_vsync, 
  href,    
  data,    
  clk,
  rstb,
  h_c_en,
  v_c,
  h_c,
  gen_da_en,
  gen_da_r,
  gen_da_g,
  gen_da_b,
  rgb_sel,
  wea,
  addra,
  dina,
  addrb,
  doutb
);

  input pclk;
  input c_vsync;
  input href;
  input [7:0]data;
  input clk;
  input rstb;
  input h_c_en;
  input [9:0] v_c;
  input [9:0] h_c;
  output gen_da_en;
  output [7:0]gen_da_r;
  output [7:0]gen_da_g;
  output [7:0]gen_da_b;
  input [8:0]rgb_sel;
  output wea;
  output [12 : 0] addra;
  output [31 : 0] dina;
  output [12 : 0] addrb;
  input [31 : 0] doutb;
   
  reg gen_da_en;
  reg [7:0]gen_da_r;
  reg [7:0]gen_da_g;
  reg [7:0]gen_da_b;
//  reg c_vsync_cb;
  reg c_vsync_d1;
  reg c_vsync_d2;
  reg c_vsync_d3;
//  reg href_cb;
  reg href_d1;
  reg href_d2;
  reg href_d3;
 // reg [7:0]data_cb; 
  reg [7:0]data_d1; 
  reg [7:0]data_d2; 
  reg [7:0]data_d3; 
  reg [7:0]data_d4; 
  reg [7:0]data_d5; 
  reg [7:0]data_d6; 
  reg [7:0]data_d7; 
  reg [7:0]data_d8; 
  reg  [11:0]i_h_cnt;
  reg  [11:0]i_v_cnt;
  reg [13:0] addra;
  wire       wea;
  wire [31:0] dina;
  wire [3:0]  r_data;
  wire [3:0]  g_data;
  wire [3:0]  b_data;
  // vram signal
  wire [7:0] radr_v_base;
  wire [6:0] radr_v;
  wire [7:0] radr_h_base;
  wire [6:0] radr_h;
  reg [6:0] radr_h_d1;
  wire [13:0] addrb;
  wire [1:0] addrb_low;
  wire [31:0] doutb;
  reg [31:0] doutb_d1;
  reg [31:0] doutb_d2;
  wire [11:0] doutb_rgb;

  parameter  vram_size_v = 128;         //VRAM垂直方向サイズ 最大128
  parameter  vram_size_h = 128;         //VRAM水平方向サイズ 最大128
  parameter  v_start = 12'h80;        //カメラ画像取り込み垂直方向開始位置
  parameter  v_end = v_start + (vram_size_v-1); //カメラ画像取り込み垂直方向終了位置
  parameter  h_start = 12'h100;        //カメラ画像取り込み水平方向開始位置
  parameter  h_start_p = h_start * 2;        //カメラ画像取り込み水平方向開始位置
  parameter  h_end_p = h_start_p + (2*vram_size_h -1); //カメラ画像取り込み水平方向終了位置
  parameter  out_size_v = vram_size_v * 2;//出力画像サイズ vram_size_vの2倍
  parameter  out_size_h = vram_size_h * 2;//出力画像サイズ vram_size_hの2倍
  parameter  out_start_v = 32;        //出力画像 垂直方向開始位置
  parameter  out_start_h = 500;      //出力画像 水平方向開始位置
  parameter  out_end_v = out_start_v + out_size_v -1;//出力画像 垂直方向終了位置
  parameter  out_end_h = out_start_h + out_size_h -1;//出力画像 水平方向終了位置

//入力データ処理   
/*
always @ (negedge pclk or negedge rstb )
if (rstb==1'b0)
  begin
    c_vsync_cb <= 1'b0 ;
    href_cb <= 1'b0 ;
    data_cb <= 8'h0 ;
  end
else
  begin
    c_vsync_cb <= c_vsync ;
    href_cb <= href ;
    data_cb <= data ; 
  end
*/

always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
  begin
    c_vsync_d1 <= 1'b0 ;
    c_vsync_d2 <= 1'b0 ;
    c_vsync_d3 <= 1'b0 ;
    href_d1 <= 1'b0 ;
    href_d2 <= 1'b0 ;
    href_d3 <= 1'b0 ;
    data_d1 <= 8'h0 ; 
    data_d2 <= 8'h0 ; 
    data_d3 <= 8'h0 ; 
    data_d4 <= 8'h0 ; 
    data_d5 <= 8'h0 ; 
    data_d6 <= 8'h0 ; 
    data_d7 <= 8'h0 ; 
    data_d8 <= 8'h0 ; 
  end
else
  begin
    c_vsync_d1 <= c_vsync ;
    c_vsync_d2 <= c_vsync_d1 ;
    c_vsync_d3 <= c_vsync_d2 ;
    href_d1 <= href ;
    href_d2 <= href_d1 ;
    href_d3 <= href_d2 ;
    data_d1 <= data ; 
    data_d2 <= data_d1 ; 
    data_d3 <= data_d2 ; 
    data_d4 <= data_d3 ;  
    data_d5 <= data_d4 ;  
    data_d6 <= data_d5 ; 
    data_d7 <= data_d6 ; 
    data_d8 <= data_d7 ; 
  end

//入力画素位置カウンタ
always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
  begin
     i_v_cnt <= 12'h000;
     i_h_cnt <= 12'h000;
  end
else
  if((c_vsync_d2==1'b1)&&(c_vsync_d3==1'b0)) //vsync
     begin
       i_v_cnt <= 12'h000;
       i_h_cnt <= 12'h000;
     end
  else
     if((href_d2==1'b0)&&(href_d3==1'b1)) //line end
       begin
         i_v_cnt <= i_v_cnt + 12'h001;
         i_h_cnt <= 12'h000;
       end
     else if (href_d2==1'b1) //data enable
       begin
         i_v_cnt <= i_v_cnt ;
         i_h_cnt <= i_h_cnt + 12'h001;
       end
     else
       begin
         i_v_cnt <= i_v_cnt ;
         i_h_cnt <= i_h_cnt ;
       end
   
 //VRAM書込みアドレス算出
 
always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
  addra <= 13'h00;
else 
  if((c_vsync_d2==1'b1)&&(c_vsync_d3==1'b0)) //vsync
    addra <= 13'h00;
  else
    if((i_v_cnt>=v_start)&&(i_v_cnt<=v_end)&&(i_h_cnt>=h_start_p)&&(i_h_cnt<=h_end_p))
      if((i_h_cnt[3:0]==4'h4)||(i_h_cnt[3:0]==4'ha)||(i_h_cnt[3:0]==4'he))
	    addra <=  addra + 13'd1;
	   else
	    addra <= addra;
    else
	  addra <= addra;
  
 
 
 
//VRAM書込みイネーブル
 assign wea =((((i_v_cnt>=v_start)&&(i_v_cnt<=v_end))&&((i_h_cnt>=h_start_p)&&(i_h_cnt<=h_end_p)))&&((i_h_cnt[3:0]==4'h4)||(i_h_cnt[3:0]==4'ha)||(i_h_cnt[3:0]==4'he)))? 1'b1:1'b0;

//VRAM書込みデータ

 assign r_data = (rgb_sel[8:6]==3'b000)?data_d3[7:4]:
                 (rgb_sel[8:6]==3'b001)?data_d3[3:0]:
                 (rgb_sel[8:6]==3'b010)?data_d2[7:4]:
                 (rgb_sel[8:6]==3'b011)?data_d2[3:0]:
                 (rgb_sel[8:6]==3'b100)?data_d1[7:4]:
                 (rgb_sel[8:6]==3'b101)?data_d1[3:0]:4'b0000;
   
 assign g_data = (rgb_sel[5:3]==3'b000)?data_d3[7:4]:
                 (rgb_sel[5:3]==3'b001)?data_d3[3:0]:
                 (rgb_sel[5:3]==3'b010)?data_d2[7:4]:
                 (rgb_sel[5:3]==3'b011)?data_d2[3:0]:
                 (rgb_sel[5:3]==3'b100)?data_d1[7:4]:
                 (rgb_sel[5:3]==3'b101)?data_d1[3:0]:4'b0000;
   
 assign b_data = (rgb_sel[2:0]==3'b000)?data_d3[7:4]:
                 (rgb_sel[2:0]==3'b001)?data_d3[3:0]:
                 (rgb_sel[2:0]==3'b010)?data_d2[7:4]:
                 (rgb_sel[2:0]==3'b011)?data_d2[3:0]:
                 (rgb_sel[2:0]==3'b100)?data_d1[7:4]:
                 (rgb_sel[2:0]==3'b101)?data_d1[3:0]:4'b0000;

/*   
 assign r_data = (rgb_sel[8:6]==3'b000)?data_d4[7:4]:
                 (rgb_sel[8:6]==3'b001)?data_d4[3:0]:
                 (rgb_sel[8:6]==3'b010)?data_d3[7:4]:
                 (rgb_sel[8:6]==3'b011)?data_d3[3:0]:
                 (rgb_sel[8:6]==3'b100)?data_d2[7:4]:
                 (rgb_sel[8:6]==3'b101)?data_d2[3:0]:4'b0000;
   
 assign g_data = (rgb_sel[5:3]==3'b000)?data_d4[7:4]:
                 (rgb_sel[5:3]==3'b001)?data_d4[3:0]:
                 (rgb_sel[5:3]==3'b010)?data_d3[7:4]:
                 (rgb_sel[5:3]==3'b011)?data_d3[3:0]:
                 (rgb_sel[5:3]==3'b100)?data_d2[7:4]:
                 (rgb_sel[5:3]==3'b101)?data_d2[3:0]:4'b0000;
   
 assign b_data = (rgb_sel[2:0]==3'b000)?data_d4[7:4]:
                 (rgb_sel[2:0]==3'b001)?data_d4[3:0]:
                 (rgb_sel[2:0]==3'b010)?data_d3[7:4]:
                 (rgb_sel[2:0]==3'b011)?data_d3[3:0]:
                 (rgb_sel[2:0]==3'b100)?data_d2[7:4]:
                 (rgb_sel[2:0]==3'b101)?data_d2[3:0]:4'b0000;
				 */
//assign dina = {r_data,g_data,b_data};

assign dina = (i_h_cnt[3:0]==4'h4)?{data_d1,data_d4[3:0],data_d3,data_d6[3:0],data_d5}:
               (i_h_cnt[3:0]==4'ha)?{data_d1[3:0],data_d4[3:0],data_d3,data_d6[3:0],data_d5,data_d8[3:0]}:
               (i_h_cnt[3:0]==4'he)?{data_d2[3:0],data_d1,data_d4[3:0],data_d3,data_d6[3:0],data_d5[7:4]}:32'h00000000;

//出力データ   
always @ (posedge clk or negedge rstb )
if (rstb==1'b0) 
  begin
    gen_da_r <= 8'd0;
    gen_da_g <= 8'd0;
    gen_da_b <= 8'd0;
    gen_da_en <= 1'b0;  end
else
    begin
      gen_da_en <= 1'b0 ;
      gen_da_r <= 8'd0;
      gen_da_g <= 8'd0;
      gen_da_b <= 8'd0;
      // vram 
      if (((v_c>=out_start_v)&&(v_c<=(out_end_v)))&&
          ((h_c>=out_start_h)&&(h_c<=(out_end_h)))&&(h_c_en==1'b1))
        begin
          gen_da_en <= 1'b1;
          gen_da_r<={doutb_rgb[3:0],4'd0};
          gen_da_g<={doutb_rgb[7:4],4'd0};
          gen_da_b<={doutb_rgb[11:8],4'd0};
        end 
      else
        begin
          gen_da_en <= 1'b0;
          gen_da_r<=gen_da_r;
          gen_da_g<=gen_da_g;
          gen_da_b<=gen_da_b;
        end 
    end 
always @ (posedge clk or negedge rstb )
if (rstb==1'b0) 
  doutb_d1 <= 32'h00000000;
else
  doutb_d1 <= doutb; 
  
always @ (posedge clk or negedge rstb )
if (rstb==1'b0) 
  doutb_d2 <= 32'h00000000;
else
  doutb_d2 <= doutb_d1; 
  
  
assign doutb_rgb = (radr_h_d1[2:0]==3'h0)?doutb[11:0]:  
                    (radr_h_d1[2:0]==3'h1)?doutb[23:12]: 
                    (radr_h_d1[2:0]==3'h2)?{doutb[3:0],doutb_d2[31:24]}: 
                    (radr_h_d1[2:0]==3'h3)?doutb[15:4]: 
                    (radr_h_d1[2:0]==3'h4)?doutb[27:16]: 
                    (radr_h_d1[2:0]==3'h5)?{doutb[7:0],doutb_d2[31:28]}: 
                    (radr_h_d1[2:0]==3'h6)?doutb[19:8]: 
                    (radr_h_d1[2:0]==3'h7)?doutb[31:20]:12'h000; 
  
//VRAM読出しアドレス算出
   assign radr_v_base = v_c-out_start_v;
   assign radr_v = ((v_c>=out_start_v)&&(v_c<=(out_end_v)))?radr_v_base[7:1]:7'h0;
  
   assign radr_h_base = h_c-out_start_h;
   assign radr_h = ((h_c>=out_start_h)&&(h_c<=(out_end_h)))?radr_h_base[7:1]:7'h0;
   
     
always @ (posedge clk or negedge rstb )
if (rstb==1'b0)
   radr_h_d1 <= 2'd0;
else
   radr_h_d1 <= radr_h[2:0];   
   
   //assign addrb ={radr_v,radr_h};
   assign addrb_low = ((radr_h[2:0]==3'h0)||(radr_h[2:0]==3'h1))?2'd0:
                       ((radr_h[2:0]==3'h2)||(radr_h[2:0]==3'h3)||(radr_h[2:0]==3'h4))?2'd1:
                       ((radr_h[2:0]==3'h5)||(radr_h[2:0]==3'h6)||(radr_h[2:0]==3'h7))?2'd2:2'b0;
   assign addrb =radr_v*48+radr_h[6:3]*3+addrb_low ;

endmodule








