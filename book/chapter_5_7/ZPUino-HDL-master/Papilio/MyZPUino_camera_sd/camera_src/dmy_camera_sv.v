//*****************************************************************************
// File Name            : dmy_camera.v
//-----------------------------------------------------------------------------
// Function             : duummy camera 
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo@himwari_co 
//-----------------------------------------------------------------------------
// History
// -.-- 2010/9/22
// -.-- 2010/11/17
//*****************************************************************************
module dmy_camera (
  xclk,
  rstb,
  pclk,    
  c_vsync, 
  href,    
  in_data
);
  input xclk;
  input rstb;  
  output pclk;
  output c_vsync;
  output href;
  output [7:0]in_data;
  reg [3:0]gen_da_r;
  reg [3:0]gen_da_g;
  reg [3:0]gen_da_b;
  reg c_vsync;
  reg href;
  reg [7:0]in_data;
  reg  [11:0]i_h_cnt;
  reg  [11:0]i_v_cnt;
  reg  [11:0]m_box_a_v1;
  wire  [11:0]m_box_a_v2;
  reg  [11:0]m_box_a_h1;
  wire  [11:0]m_box_a_h2;
   
  reg  m_box_b_v_f;
  reg  [11:0]m_box_b_v1;
  wire  [11:0]m_box_b_v2;
  reg  m_box_b_h_f;
  reg  [11:0]m_box_b_h1;
  wire  [11:0]m_box_b_h2;

  reg [9:0]  cl_cnt;
  reg [7:0]  red_cnt;
  reg [7:0]  grn_cnt;
  reg [7:0]  blu_cnt;
  reg  [9:0]         line_cnt;
  wire [10:0]        line_v;

//蜃ｺ蜉帙ヴ繧ｯ繧ｻ繝ｫ繧ｯ繝ｭ繝け   
  assign    pclk = xclk;
 
//逕ｻ邏菴咲ｽｮ繧ｫ繧ｦ繝ｳ繧ｿ
always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
  begin
     i_v_cnt <= 12'h000;
     i_h_cnt <= 12'h000;
  end
else
  if(i_h_cnt == 12'd1399)
     begin
       i_h_cnt <= 12'h000;
       if(i_v_cnt == 12'd500)
         i_v_cnt <= 12'h000;
       else 
         i_v_cnt <= i_v_cnt + 12'h001;
     end
  else
       begin
         i_v_cnt <= i_v_cnt ;
         i_h_cnt <= i_h_cnt + 12'h001;
       end

//蜈･蜉帙ョ繝ｼ繧ｿ蜃ｦ逅  
always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
  begin
    c_vsync <= 1'b0 ;
    href <= 1'b0 ;
  end
else
  begin
    if ((i_v_cnt >=12'd480)&&(i_v_cnt <=12'd490))
      c_vsync <= 1'b1;
    else
      c_vsync <= 1'b0 ;
    if ((i_v_cnt >=12'd0)&&(i_v_cnt <=12'd479))
      if ((i_h_cnt >=12'd1)&&(i_h_cnt <=12'd1280))
        href <= 1'b1;
      else
        href <= 1'b0 ;
  end
   
always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
    in_data <= 8'h0 ; 
else
  if(i_h_cnt[0]==1'b1)
    in_data <= {4'd0,gen_da_b};
  else
    in_data <= {gen_da_g,gen_da_r};

//螟牙喧縺吶ｋ濶ｲ縺ｮ謖ｮ
always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
  cl_cnt <= 10'd0;
else
 if ((i_v_cnt ==12'd0)&&(i_h_cnt ==12'd0))
   if (cl_cnt >= 10'h2ff)
     cl_cnt <= 10'h000;
   else
     cl_cnt <= cl_cnt + 10'h02;
 else
   cl_cnt <= cl_cnt;
   
//box_red濶ｲ謖ｮ
always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
  red_cnt <= 8'd0;
else
 if  (cl_cnt >= 10'h2ff)
   red_cnt <= 8'h00;
 else
 if (cl_cnt[9:8]==2'b00)
   red_cnt <= cl_cnt[7:0];
 else
   red_cnt <= red_cnt;
   
//box_green濶ｲ謖ｮ
always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
  grn_cnt <= 8'd0;
else
 if  (cl_cnt >= 10'h2ff)
   grn_cnt <= 8'h00;
 else
 if (cl_cnt[9:8]==2'b01)
   grn_cnt <= cl_cnt[7:0];
 else
   grn_cnt <= grn_cnt;

//box_blue濶ｲ謖ｮ
always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
  blu_cnt <= 8'd0;
else
 if  (cl_cnt >= 10'h2ff)
   blu_cnt <= 8'h00;
 else
 if (cl_cnt[9:8]==2'b10)
   blu_cnt <= cl_cnt[7:0];
 else
   blu_cnt <= blu_cnt;
   
//譁懊ａ繝ｩ繧､繝ｳ陦ｨ遉ｺ逕ｨ繧ｫ繧ｦ繝ｳ繧ｿ
/*   
always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
  line_cnt <= 10'd0;
else
 if ((i_v_cnt ==12'd0)&&(i_h_cnt ==12'd0))
   if  (line_cnt >= 10'd639)
     line_cnt <= 10'd0;
   else
     line_cnt <=line_cnt + 10'd2;
 else
   line_cnt <=line_cnt;

assign line_v= (i_v_cnt)+ line_cnt;
*/    

//襍､繝繧ｿ逕滓   
always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
    gen_da_r <= 4'h0 ; 
else
  //if (line_v==i_h_cnt)
  //  gen_da_r <= 4'hf ;  
  //else
  //box_a
  if ((i_v_cnt >=m_box_a_v1)&&(i_v_cnt <=m_box_a_v2)&&(i_h_cnt >=m_box_a_h1)&&(i_h_cnt <=m_box_a_h2))
    gen_da_r <= 4'hf ;  
  //box_b
  //else if ((i_v_cnt >=m_box_b_v1)&&(i_v_cnt <=m_box_b_v2)&&(i_h_cnt >=m_box_b_h1)&&(i_h_cnt <=m_box_b_h2))
  //  gen_da_r <= 4'hf ;
  //box1
  else if ((i_v_cnt >=12'd230)&&(i_v_cnt <=12'd299)&&(i_h_cnt >=700)&&(i_h_cnt <=12'd839))
    gen_da_r <= 4'h8 ;
  //box_red
  else if ((i_v_cnt >= 12'd150)&&(i_v_cnt <=12'd199)&&(i_h_cnt >=12'd400)&&(i_h_cnt <=12'd499))   
    gen_da_r <= red_cnt[7:4] ;
  else if ((i_v_cnt >=12'd4)&&(i_v_cnt <=12'd299)&&(i_h_cnt >=32)&&(i_h_cnt <=12'd63))
    gen_da_r <=i_h_cnt[4:1] ;
 else
     gen_da_r <= 4'h0 ;
  
//邱代ョ繝ｼ繧ｿ逕滓 
always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
    gen_da_g <= 4'h0 ; 
else
  //if (line_v==i_h_cnt)
  //  gen_da_g <= 4'hf ;  
  //else 
  //box_a
  if ((i_v_cnt >=m_box_a_v1)&&(i_v_cnt <=m_box_a_v2)&&(i_h_cnt >=m_box_a_h1)&&(i_h_cnt <=m_box_a_h2))
    gen_da_g <= 4'hf ;  
  //box_b
  //else if ((i_v_cnt >=m_box_b_v1)&&(i_v_cnt <=m_box_b_v2)&&(i_h_cnt >=m_box_b_h1)&&(i_h_cnt <=m_box_b_h2))
  //  gen_da_g <= 4'hf ;  
  //box1
  else if ((i_v_cnt >=12'd230)&&(i_v_cnt <=12'd299)&&(i_h_cnt >=700)&&(i_h_cnt <=12'd839))
    gen_da_g <= 4'h8 ;
  //box_green
  else if ((i_v_cnt >=12'd175)&&(i_v_cnt <=12'd224)&&(i_h_cnt >=12'd450)&&(i_h_cnt <=12'd549))   
    gen_da_g <= grn_cnt[7:4] ;
  else if ((i_v_cnt >=12'd4)&&(i_v_cnt <=12'd299)&&(i_h_cnt >=32)&&(i_h_cnt <=63))
     gen_da_g <= i_h_cnt[4:1] + 3;
  else  
    gen_da_g <= 4'h0 ;

//髱偵ョ繝ｼ繧ｿ逕滓   
always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
    gen_da_b <= 4'h0 ; 
else
  //if (line_v==i_h_cnt)
  //  gen_da_b <= 4'hf ;
  //else 
  //box_a
  if ((i_v_cnt >=m_box_a_v1)&&(i_v_cnt <=m_box_a_v2)&&(i_h_cnt >=m_box_a_h1)&&(i_h_cnt <=m_box_a_h2))
    gen_da_b <= 4'hf ;  
  //box_b
  //else if ((i_v_cnt >=m_box_b_v1)&&(i_v_cnt <=m_box_b_v2)&&(i_h_cnt >=m_box_b_h1)&&(i_h_cnt <=m_box_b_h2))
  //  gen_da_b <= 4'hf ; 
  //box1
  else if ((i_v_cnt >=12'd230)&&(i_v_cnt <=12'd299)&&(i_h_cnt >=700)&&(i_h_cnt <=12'd839))
    gen_da_b <= 4'h8 ; 
 //box_blue
  else if ((i_v_cnt >=12'd200)&&(i_v_cnt <=12'd249)&&(i_h_cnt >=12'd500)&&(i_h_cnt <=12'd599))   
    gen_da_b <= blu_cnt[7:4];
  else if ((i_v_cnt >=12'd4)&&(i_v_cnt <=12'd299)&&(i_h_cnt >=32)&&(i_h_cnt <=12'd63))
    gen_da_b <= i_h_cnt[4:1] + 6;
  else  
    gen_da_b <= 4'h0 ;
   

//遘ｻ蜍輔ヶ繝ｭ繝け1縺ｮ蠎ｧ讓呵ｨ育ｮ  
always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
  begin
    m_box_a_v1 <= 12'd120;
    m_box_a_h1 <= 12'd320;
  end
else
  if ((i_v_cnt[4:0] == 5'd0)&&(i_h_cnt ==12'd0))
    if ((m_box_a_v1 == 12'd120)&&(m_box_a_h1 <= 12'd939))
      begin      
        m_box_a_v1 <= 12'd120;      
        m_box_a_h1 <=  m_box_a_h1 + 12'd1;
      end
    else if ((m_box_a_v1 <= 12'd349)&&(m_box_a_h1 == 12'd940))
      begin      
        m_box_a_v1 <=  m_box_a_v1 + 12'd1;      
        m_box_a_h1 <= 12'd940;
      end
    else if ((m_box_a_v1 == 12'd350)&&(m_box_a_h1 >= 12'd321))
      begin      
        m_box_a_v1 <= 12'd350;      
        m_box_a_h1 <=  m_box_a_h1 - 12'd1;
      end
    else if ((m_box_a_v1 >= 12'd121)&&(m_box_a_h1 == 12'd320))
      begin      
        m_box_a_v1 <=  m_box_a_v1 - 12'd1;      
        m_box_a_h1 <= 12'd320;
      end
    else
      begin
        m_box_a_v1 <= 12'd120;
        m_box_a_h1 <= 12'd320;
      end
  else
      begin
        m_box_a_v1 <= m_box_a_v1;
        m_box_a_h1 <= m_box_a_h1;
      end

   assign m_box_a_v2 = m_box_a_v1+12'd9;
   assign m_box_a_h2 = m_box_a_h1+12'd19;

//遘ｻ蜍輔ヶ繝ｭ繝け2縺ｮ蠎ｧ讓呵ｨ育ｮ

always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
  begin
    m_box_b_v_f <= 1'b1;
  end
else
  if ((i_v_cnt[6:0] == 7'd0)&&(i_h_cnt ==12'd0))
    if ((m_box_b_v1 == 12'd120)&&(m_box_b_v_f==1'b0))
      m_box_b_v_f <= 1'b1;
    else if ((m_box_b_v1 == 12'd349)&&(m_box_b_v_f==1'b1))
      m_box_b_v_f <= 1'b0;
    else
      m_box_b_v_f <= m_box_b_v_f;
  else
    m_box_b_v_f <= m_box_b_v_f;
      
always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
  begin
    m_box_b_h_f <= 1'b1;
  end
else
  if ((i_v_cnt[6:0] == 7'd0)&&(i_h_cnt ==12'd0))
    if ((m_box_b_h1 == 12'd320)&&(m_box_b_h_f==1'b0))
      m_box_b_h_f <= 1'b1;
    else
    if ((m_box_b_h1 == 12'd939)&&(m_box_b_h_f==1'b1))
      m_box_b_h_f <= 1'b0;
    else
      m_box_b_h_f <= m_box_b_h_f;
  else
    m_box_b_h_f <= m_box_b_h_f;

always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
    m_box_b_v1 <= 12'd10;
else
  if ((i_v_cnt[6:0] == 7'd0)&&(i_h_cnt ==12'd0))
    if (m_box_b_v_f == 1'b0)  
      m_box_b_v1 <=  m_box_b_v1 - 12'd1;
    else
      m_box_b_v1 <=  m_box_b_v1 + 12'd1;
  else
    m_box_b_v1 <= m_box_b_v1;

always @ (posedge pclk or negedge rstb )
if (rstb==1'b0)
    m_box_b_h1 <= 12'd10;
else
  if ((i_v_cnt[6:0] == 7'd0)&&(i_h_cnt ==12'd0))
    if (m_box_b_h_f == 1'b0)  
      m_box_b_h1 <=  m_box_b_h1 - 12'd1;
    else
      m_box_b_h1 <=  m_box_b_h1 + 12'd1;
  else
    m_box_b_h1 <= m_box_b_h1;


   assign m_box_b_v2 = m_box_b_v1+12'd9;
   assign m_box_b_h2 = m_box_b_h1+12'd19;


endmodule








