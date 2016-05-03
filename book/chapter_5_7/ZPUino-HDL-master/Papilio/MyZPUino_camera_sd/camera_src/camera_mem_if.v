
//*****************************************************************************
// File Name            : zpuino_camera.vhd
//-----------------------------------------------------------------------------
// Function             : Camera_if for ZPUINO
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2014/07/17
//*****************************************************************************
module camera_mem_if(
	wb_clk_i, wb_rst_i, wb_adr_i, wb_dat_i, wb_dat_o,
	wb_we_i, wb_stb_i, wb_cyc_i, wb_ack_o, wb_inta_o,
	pclk,c_vsync,href,in_data,dmy_camera_mode );

	// parameters
	parameter ARST_LVL = 1'b0; // asynchronous reset level

  parameter  vram_size_v = 128;         //VRAM垂直方向サイズ 最大128
  parameter  vram_size_h = 128;         //VRAM水平方向サイズ 最大128
  parameter  v_start = 12'h30;        //カメラ画像取り込み垂直方向開始位置
  parameter  v_end = v_start + (vram_size_v-1); //カメラ画像取り込み垂直方向終了位置
  parameter  h_start = 12'h60;        //カメラ画像取り込み水平方向開始位置
  parameter  h_start_p = h_start * 2;        //カメラ画像取り込み水平方向開始位置
  parameter  h_end_p = h_start_p + (2*vram_size_h -1); //カメラ画像取り込み水平方向終了位置
	//
	// inputs & outputs
	//

	// wishbone signals
	input        wb_clk_i;     // master clock input
	input        wb_rst_i;     // synchronous active high reset
	input  [15:2] wb_adr_i;     // lower address bits
	input  [31:0] wb_dat_i;     // databus input
	output [31:0] wb_dat_o;     // databus output
	input        wb_we_i;      // write enable input
	input        wb_stb_i;     // stobe/core select signal
	input        wb_cyc_i;     // valid bus cycle input
	output       wb_ack_o;     // bus cycle acknowledge output
	output       wb_inta_o;    // interrupt request signal outputk
	
	// canera signalsk
    input pclk;
    input c_vsync;
    input href;
    input [7:0]in_data;
	input dmy_camera_mode ;


	//
	
	reg wb_ack_o;
  //vram
	
  ///camera
  wire s_pclk;
  wire s_c_vsync;
  wire s_href;
  wire [7:0]s_in_data;
  //dmy
  wire dmy_pclk;
  wire dmy_c_vsync;
  wire dmy_href;
  wire [7:0]dmy_in_data;
  wire rstb;
  reg c_vsync_d1;
  reg c_vsync_d2;
  reg c_vsync_d3;
  reg href_d1;
  reg href_d2;
  reg href_d3;
  reg [7:0]data_d1; 
  reg [7:0]data_d2; 
  reg [7:0]data_d3; 
  reg [7:0]data_d4; 
  reg [7:0]data_d5; 
  reg [7:0]data_d6; 
  reg  [11:0]i_h_cnt;
  reg  [11:0]i_v_cnt;
  reg [13:0] addra;
  wire       wea;
  wire [31:0] dina;
  wire [31:0] doutb;
  reg  vram_read_flg ;
  reg vram_we ;
//
	
assign wb_inta_o = 1'b1;
//ACK生成

always @ (posedge wb_clk_i )
  if(( wb_cyc_i == 1'b1 )&&(wb_stb_i==1'b1)&&(wb_ack_o==1'b0)) 
    wb_ack_o <= 1'b1;
  else
	wb_ack_o <= 1'b0;

//設定レジスタ	
	
always @ (posedge wb_clk_i )
    if (wb_rst_i==1'b1)
       vram_read_flg <= 1'b0;
    else
	  if ((wb_stb_i==1'b1)&&(wb_cyc_i==1'b1)&&(wb_we_i==1'b1)) 
	    if(wb_adr_i[15:2]==14'h0000)
		  vram_read_flg <= wb_dat_i[0];
		else
		  vram_read_flg <= vram_read_flg;
	  else
		vram_read_flg <= vram_read_flg;
		  
//読み出しデータ VRAM

vram_32b_6144 vram (
        .clka(pclk),
        .wea(wea), // Bus [0 : 0] 
        .addra(addra), // Bus [12 : 0] 
        .dina(dina), // Bus [31 : 0] 
        .clkb(wb_clk_i),
        .addrb( wb_adr_i[14:2]), // Bus [12 : 0] 
        .doutb(doutb)); // Bus [31 : 0] 

//読み出しデータ選択		
assign wb_dat_o = ( wb_adr_i[15]==1'b0)?{31'h00000000,vram_read_flg}:doutb;		
		
//camera if
assign rstb = ~wb_rst_i;

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
  end
else
  begin
    c_vsync_d1 <= s_c_vsync ;
    c_vsync_d2 <= c_vsync_d1 ;
    c_vsync_d3 <= c_vsync_d2 ;
    href_d1 <= s_href ;
    href_d2 <= href_d1 ;
    href_d3 <= href_d2 ;
    data_d1 <= s_in_data ; 
    data_d2 <= data_d1 ; 
    data_d3 <= data_d2 ; 
    data_d4 <= data_d3 ;  
    data_d5 <= data_d4 ;  
    data_d6 <= data_d5 ; 
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
  addra <= 13'h000;
else 
  if((c_vsync_d2==1'b1)&&(c_vsync_d3==1'b0)) //vsync
    //addra <= 13'h17FF;
    addra <= 13'h000;
  else
    if((i_v_cnt>=v_start)&&(i_v_cnt<=v_end)&&(i_h_cnt>=h_start_p)&&(i_h_cnt<=h_end_p))
      if((i_h_cnt[3:0]==4'h4)||(i_h_cnt[3:0]==4'h9)||(i_h_cnt[3:0]==4'he))
	    //addra <=  addra - 13'd1;
	    addra <=  addra + 13'd1;
	   else
	    addra <= addra;
    else
	  addra <= addra;
  
 
//VRAM書込みイネーブル

always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
  vram_we <= 1'b1;
else
  if ((c_vsync_d2==1'b1)&&(c_vsync_d3==1'b0))
    if(vram_read_flg==1'b1)
	   vram_we <=1'b0;
	else
	   vram_we <= 1'b1;
	   
 assign wea =((((vram_we==1'b1)&&(i_v_cnt>=v_start)&&(i_v_cnt<=v_end))&&((i_h_cnt>=h_start_p)&&(i_h_cnt<=h_end_p)))&&((i_h_cnt[3:0]==4'h4)||(i_h_cnt[3:0]==4'h9)||(i_h_cnt[3:0]==4'he)))? 1'b1:1'b0;

//VRAM書込みデータ
 

assign dina = (i_h_cnt[3:0]==4'h4)?{data_d6[3:0],data_d5,data_d4[3:0],data_d3,data_d2[3:0],data_d1[7:4]}:
               (i_h_cnt[3:0]==4'h9)?{data_d6[3:0],data_d5[3:0],data_d4,data_d3[3:0],data_d2,data_d1[3:0]}:
               (i_h_cnt[3:0]==4'he)?{data_d5,data_d4[3:0],data_d3,data_d2[3:0],data_d1}:32'h00000000;
			   
dmy_camera dmy_camera(
.xclk   ( pclk  ),
.rstb   ( rstb  ),
.pclk   ( dmy_pclk  ),    
.c_vsync( dmy_c_vsync), 
.href   ( dmy_href  ),    
.in_data( dmy_in_data  ) 
);

assign s_pclk = (dmy_camera_mode==1'b0)? pclk:dmy_pclk;
assign s_c_vsync = (dmy_camera_mode==1'b0)?c_vsync:dmy_c_vsync;
assign s_href =(dmy_camera_mode==1'b0)?href:dmy_href;
assign s_in_data =(dmy_camera_mode==1'b0)?in_data:dmy_in_data;

endmodule
