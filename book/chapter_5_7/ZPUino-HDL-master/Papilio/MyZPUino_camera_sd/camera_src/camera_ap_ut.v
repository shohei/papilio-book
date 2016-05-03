//*****************************************************************************
// File Name            : camera_ap.v
//-----------------------------------------------------------------------------
// Function             : camera sample application
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2010/10/28
// -.-- 2010/11/17
// -.-- 2014/07/13
//*****************************************************************************
module camera_ap_ut ( clk_40m, rstb, led_0,
                   //scl,sda,
				   scl,sda_i,sda_o,
                   txd,rxd,
                   xclk,pclk,c_vsync,href,in_data,mon,
                   da_r,da_g,da_b,vsync,hsync,
				   dmy_camera_mode);
  input clk_40m;    //clk 40MHz
  input rstb;   //reset_b
  output led_0; //led control 0:on 1:off
  //output scl;   //I2C SCL
  //inout  sda;   //I2C SDA
  output scl;
  output sda_o;
  input  sda_i;
  output txd;   //serial tx data    
  input  rxd;   //serial rx data
  output xclk;  //camera system clock
  input pclk;
  input c_vsync;
  input href;
  input [7:0]in_data;
  output    mon;
  output [3:0]da_r;
  output [3:0]da_g;
  output [3:0]da_b;
  output vsync;
  output hsync;  
  input  dmy_camera_mode ;// 0:camera 1:dmy
  reg vsync_d1;
  reg href_d1;
  reg [7:0]data_d1;
  reg pclk_d2;
  reg vsync_d2;
  reg href_d2;
  reg [7:0]data_d2;
  reg    mon; 
  reg  [25:0] pclk_cnt;
  //svga_if
  wire in_a_da_en;
  wire [7:0]in_a_da_r;
  wire [7:0]in_a_da_g;
  wire [7:0]in_a_da_b;
  // 
  wire in_b_da_en; 
  wire [7:0]in_b_da_r;
  wire [7:0]in_b_da_g;
  wire [7:0]in_b_da_b;
  //
  wire in_c_da_en;
  wire [7:0]in_c_da_r;
  wire [7:0]in_c_da_g;
  wire [7:0]in_c_da_b; 
  //
  wire in_d_da_en; 
  wire [7:0]in_d_da_r;
  wire [7:0]in_d_da_g;
  wire [7:0]in_d_da_b;
  //wire sync;
  wire tmg_sync;
  wire h_c_en;
  wire [9:0] v_c;
  wire [9:0] h_c;
  wire [7:0]da_r_tmp;
  wire [7:0]da_g_tmp;
  wire [7:0]da_b_tmp;
  wire da_en;
  //i2c
  wire wr;
  wire rd;
  wire [6:0]adr;
  wire [31:0]wr_data; 
  wire [2:0]wr_bytes; 
  wire [3:0]wr_be; 
  wire rd_data_en;
  wire [31:0]rd_data;
  wire [2:0]rd_bytes; 
  wire [3:0]rd_be; 
  wire    scl_drv;
  wire    sda_i;
  wire    sda_o;
  //rs232c    
  wire  [7:0] tx_fifo_data;    //tx fifo data 8bit
  wire        tx_fifo_data_en; //tx fifo data enable 
  wire       tx_fifo_empty;   //tx fifo read enable 
  wire       tx_fifo_full ;   //tx fifo read enable 
  wire       tx_fifo_n_full ; //tx fifo read enable 
  wire [7:0] tx_data;        //tx data 8bit
  wire       tx_data_en;      //tx data enable 
  wire       tx_busy;         //tx busy
  wire [7:0] rx_data;        //tx data 8bit
  wire       rx_data_en;      //tx data enable 
  wire       rx_busy;         //tx busy
  //cmd gen
  wire  cmd_wr;
  wire  cmd_rd;
  wire [7:0]cmd_adr;
  wire [7:0]cmd_data;
  wire [8:0] rgb_sel;
  //msg_buf
  wire  a_n_full;
  wire  b_n_full;
  //varm
  wire  wea;
  wire [12 : 0] addra;
  wire [31 : 0] dina;
  wire [13 : 0] addrb;
  wire [31 : 0] doutb;
  //clks
  wire clk;
  wire LOCKED;
  wire xclk_dm;
  wire s_pclk;
  wire s_c_vsync;
  wire s_href;
  wire [7:0]s_in_data;
  //dmy
  wire dmy_pclk;
  wire dmy_c_vsync;
  wire dmy_href;
  wire [7:0]dmy_in_data;
parameter  led_cnt_1s = 26'd19999999; //1S plck=20MHz
 
   
always @ (posedge pclk or negedge rstb )
  if (rstb==1'b0)
    begin
      vsync_d1 <= 1'b0;
      href_d1  <= 1'b0;
      data_d1  <= 8'h00;
    end
  else
    begin
      vsync_d1 <= c_vsync ;
      href_d1  <= href;
      data_d1     <= in_data;
    end

//monter signal   
always @ (posedge clk_40m or negedge rstb )
  if (rstb==1'b0)
    begin
      pclk_d2 <= 1'b0; 
      vsync_d2 <= 1'b0;
      href_d2  <= 1'b0;
      data_d2  <= 8'h00;
      mon <= 1'b0;
    end
  else
    begin
      pclk_d2 <= pclk; 
      vsync_d2 <= vsync_d1 ;
      href_d2  <= href_d1;
      data_d2  <= data_d1;
      mon <= (vsync_d2^href_d2^pclk_d2^pclk_cnt[25])^(^data_d2);
    end

//pclkの入力確認用LED点滅   
always @ (posedge pclk or negedge rstb )
  if (rstb==1'b0)
    pclk_cnt <= 26'b0;
  else if (pclk_cnt == led_cnt_1s) //1秒経過 
    pclk_cnt <= 26'b0;             //カウント値を0
  else
    pclk_cnt <= pclk_cnt + 26'd1;  //カウントアップ
   
assign led_0 =pclk_cnt[24];

//assign xclk = clk_16m;
camera_if camera_if(   
  .clk(      clk_40m),        
  .rstb(     rstb),  
  .xclk(     xclk),  
  .pclk(     s_pclk),           
  .c_vsync(  s_c_vsync), 
  .href(     s_href),           
  .in_data(  s_in_data), 
  .h_c_en(   h_c_en), 
  .v_c(      v_c),
  .h_c(      h_c),             
  .gen_da_en(in_c_da_en),
  .gen_da_r( in_c_da_r), 
  .gen_da_g( in_c_da_g), 
  .gen_da_b( in_c_da_b),       
  .rx_data(  rx_data),     
  .rx_data_en(rx_data_en),           
  .wr(       wr),
  .rd(       rd),
  .adr(      adr),
  .wr_data(  wr_data),
  .wr_bytes( wr_bytes),
  .rd_data(  rd_data),
  .rd_data_en(rd_data_en),
  .rd_bytes( rd_bytes),
  .tx_fifo_data_en(tx_fifo_data_en),   
  .tx_fifo_data(tx_fifo_data), 
  .wea(      wea),     
  .addra(    addra), 
  .dina(     dina),  
  .addrb(    addrb), 
  .doutb(    doutb) 
);

//vram_dmy vram (
//vram_128_128 vram (
vram_32b_6144 vram (
        .clka(pclk),
        .wea(wea), // Bus [0 : 0] 
        .addra(addra), // Bus [12 : 0] 
        .dina(dina), // Bus [31 : 0] 
        .clkb(clk_40m),
        .addrb(addrb), // Bus [12 : 0] 
        .doutb(doutb)); // Bus [31 : 0] 
   
//svga_if
  assign da_r = da_r_tmp[7:4];
  assign da_g = da_g_tmp[7:4];
  assign da_b = da_b_tmp[7:4];
   
layer_a layer_a(
  .clk(    clk_40m),        
  .rstb(     rstb),   
  .h_c_en(h_c_en),
  .v_c(v_c),
  .h_c(h_c),             
  .gen_da_en(in_a_da_en),
  .gen_da_r( in_a_da_r), 
  .gen_da_g( in_a_da_g), 
  .gen_da_b( in_a_da_b) 
);

layer_b layer_b(
  .clk(    clk_40m),        
  .rstb(     rstb),   
  .h_c_en(h_c_en),
  .v_c(v_c),
  .h_c(h_c),             
  .gen_da_en(in_b_da_en),
  .gen_da_r( in_b_da_r), 
  .gen_da_g( in_b_da_g), 
  .gen_da_b( in_b_da_b) 
);

layer_d layer_d (
  .clk(    clk_40m),        
  .rstb(     rstb),   
  .h_c_en(h_c_en),
  .v_c(v_c),
  .h_c(h_c),             
  .gen_da_en(in_d_da_en),
  .gen_da_r( in_d_da_r), 
  .gen_da_g( in_d_da_g), 
  .gen_da_b( in_d_da_b)
);

svga_if svga_if (
  .clk(         clk_40m),           
  .rstb(        rstb),     
  .h_c_en(   h_c_en),     
  .out_hsync( hsync),   
  .out_vsync( vsync),   
  .v_c(         v_c),           
  .h_c(         h_c),  
  .in_a_da_en(  in_a_da_en),      
  .in_a_da_r(   in_a_da_r),       
  .in_a_da_g(   in_a_da_g),       
  .in_a_da_b(   in_a_da_b),      
  .in_b_da_en(  in_b_da_en),      
  .in_b_da_r(   in_b_da_r),       
  .in_b_da_g(   in_b_da_g),       
  .in_b_da_b(   in_b_da_b),      
  .in_c_da_en(  in_c_da_en),      
  .in_c_da_r(   in_c_da_r),       
  .in_c_da_g(   in_c_da_g),       
  .in_c_da_b(   in_c_da_b),      
  .in_d_da_en(  in_d_da_en),      
  .in_d_da_r(   in_d_da_r),       
  .in_d_da_g(   in_d_da_g),       
  .in_d_da_b(   in_d_da_b),       
  .out_da_r(    da_r_tmp),      
  .out_da_g(    da_g_tmp),      
  .out_da_b(    da_b_tmp),      
  .out_da_en(   da_en)        
);
   
// i2c master    
i2c_m_if i2c_m_if(
  .clk(   clk_40m),
  .rstb(  rstb),
  .scl(  scl),
  .sda_o(  sda_o),
  .sda_i(  sda_i),
  .wr(    wr),
  .rd(    rd),
  .adr(   adr),
  .wr_data(wr_data),
  .wr_bytes(wr_bytes),
  .rd_data(rd_data),
  .rd_data_en(rd_data_en),
  .rd_bytes(rd_bytes),
  .busy(busy) 
  );
     
rs232c_tx_rx  rs232c_tx_rx(
.RESETB(     rstb),      
.CLK(        clk_40m),           
.TXD(        txd),           
.RXD(        rxd),           
.TX_DATA(    tx_data ),     
.TX_DATA_EN( tx_data_en),  
.TX_BUSY(    tx_busy),     
.RX_DATA(    rx_data),     
.RX_DATA_EN( rx_data_en),  
.RX_BUSY(    rx_busy))             
;
    
msg_buf msg_buf
( 
.CLK(       clk_40m),            
.RESET_N(   rstb),     
.A_DAT_EN(  rx_data_en),  
.A_DAT(     rx_data),     
.A_N_FULL(  a_n_full),     
.B_DAT_EN(  tx_fifo_data_en),  
.B_DAT(     tx_fifo_data), 
.B_N_FULL(  b_n_full),        
.O_DAT(     tx_data),     
.O_DAT_EN(  tx_data_en),
.O_BUSY(    tx_busy)
);           
    
dmy_camera dmy_camera(
.xclk   ( xclk  ),
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




