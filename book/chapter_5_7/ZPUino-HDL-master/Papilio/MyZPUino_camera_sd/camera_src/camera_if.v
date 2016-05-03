//*****************************************************************************
// File Name            : camera_if.v
//-----------------------------------------------------------------------------
// Function             : camera interface
//                        for ov7670
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2010/10/28
// -.-- 2010/11/17
// -.-- 2014/07/13
//******************************************************************************
module camera_if ( clk, rstb,
                   xclk,pclk,c_vsync,href,in_data,
                   h_c_en,v_c,h_c,
                   gen_da_en,gen_da_r,gen_da_g,gen_da_b,
                   rx_data,rx_data_en,
                   wr,rd,adr,wr_data,wr_bytes,rd_data,rd_data_en,rd_bytes, 
                   tx_fifo_data,tx_fifo_data_en,
                   wea,addra,dina,addrb,doutb
);
  input clk;    //clk 40MHz
  input rstb;   //reset_b
  output xclk;  //camera system clock
  input pclk;
  input c_vsync;
  input href;
  input [7:0]in_data;
  input h_c_en;
  input [9:0] v_c;
  input [9:0] h_c;
  output gen_da_en;
  output [7:0]gen_da_r;
  output [7:0]gen_da_g;
  output [7:0]gen_da_b;
  //rs232C rx
  input [7:0] rx_data;        //tx data 8bit
  input       rx_data_en;      //tx data enable
  //i2c
  output wr;
  output rd;
  output [6:0]adr;
  output [31:0]wr_data;
  output [2:0]wr_bytes;
  output [2:0]rd_bytes;
  input[31:0]rd_data;
  input  rd_data_en;
  //msg_buf 
  output  [7:0] tx_fifo_data;    //tx fifo data 8bit
  output        tx_fifo_data_en; //tx fifo data enable 
  //vram
  output wea;
  output [12 : 0] addra;
  output [31 : 0] dina;
  output [12 : 0] addrb;
  input [31 : 0] doutb;
   
  reg    xclk_reg;
  
//cmd gen
  wire  cmd_wr;
  wire  cmd_rd;
  wire [7:0]cmd_adr;
  wire [7:0]cmd_data;
  wire [8:0] rgb_sel;

// xclk generaitor   
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)
    xclk_reg <= 1'b0;
  else
    xclk_reg <= ~xclk_reg;

assign    xclk = xclk_reg;
//assign    xclk = clk;
   
//画像入力、出力、vram制御   
//vram_ctrl vram_ctrl(
vram_wr vram_wr(
  .pclk(     pclk),           
  .c_vsync(  c_vsync), 
  .href(     href),           
  .data(     in_data),    
  .clk(      clk),        
  .rstb(     rstb), 
  .h_c_en(h_c_en),  
  .v_c(v_c),
  .h_c(h_c),             
  .gen_da_en(gen_da_en),
  .gen_da_r( gen_da_r), 
  .gen_da_g( gen_da_g), 
  .gen_da_b( gen_da_b), 
  .rgb_sel(  rgb_sel),
  .wea(wea),     
  .addra(addra), 
  .dina( dina),  
  .addrb(addrb), 
  .doutb(doutb) 
);

//OV7670用コマンド生成
ov7670_cmd_gen  cmd_gen(
.RESETB(      rstb),      
.CLK(         clk),       
.RX_DATA(     rx_data),     
.RX_DATA_EN(  rx_data_en),  
.CMD_WR(      cmd_wr),        
.CMD_RD(      cmd_rd),    
.CMD_ADR(     cmd_adr),    
.CMD_DATA(    cmd_data),
.RGB_SEL(     rgb_sel)
);
   
//OV7670用i2cコントロールモジュール                    
i2c_ov7670_ctrl i2c_dev_ctrl( 
  .clk(   clk),
  .rstb(  rstb),
  .cmd_wr(      cmd_wr),        
  .cmd_rd(      cmd_rd),    
  .cmd_adr(     cmd_adr),    
  .cmd_data(    cmd_data),
  .wr(    wr),
  .rd(    rd),
  .adr(   adr),
  .wr_data(wr_data),
  .wr_bytes(wr_bytes),
  .rd_data(rd_data),
  .rd_data_en(rd_data_en),
  .rd_bytes(rd_bytes),
  .tx_fifo_data_en    (tx_fifo_data_en),   
  .tx_fifo_data   (tx_fifo_data)
);

endmodule




