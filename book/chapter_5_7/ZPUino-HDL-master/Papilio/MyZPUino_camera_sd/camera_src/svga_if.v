//******************************************************************************
// File Name            : svga_if.v
//------------------------------------------------------------------------------
// Function             : svga(800x600) RGB data output
//                        
//------------------------------------------------------------------------------
// Designer             : yokomizo@himwari_co 
//------------------------------------------------------------------------------
// History
// -.-- 2010/8/5
// -.-- 2010/9/22
//******************************************************************************
module svga_if (
  clk,
  rstb,
  out_hsync,
  out_vsync,
  v_c,
  h_c,
  h_c_en,
  in_a_da_en,
  in_a_da_r,
  in_a_da_g,
  in_a_da_b,
  in_b_da_en,
  in_b_da_r,
  in_b_da_g,
  in_b_da_b,
  in_c_da_en,
  in_c_da_r,
  in_c_da_g,
  in_c_da_b,
  in_d_da_en,
  in_d_da_r,
  in_d_da_g,
  in_d_da_b,
  out_da_r,
  out_da_g,
  out_da_b,
  out_da_en
  );

  input clk;
  input rstb;
  
  output out_vsync;
  output out_hsync;
  output [9:0] v_c;
  output [9:0] h_c;
  output h_c_en;
  //output p_en;
  //output p_clk;
  //
  input in_a_da_en;
  input [7:0]in_a_da_r;
  input [7:0]in_a_da_g;
  input [7:0]in_a_da_b;
  //
  input in_b_da_en;
  input [7:0]in_b_da_r;
  input [7:0]in_b_da_g;
  input [7:0]in_b_da_b;
  //
  input in_c_da_en;
  input [7:0]in_c_da_r;
  input [7:0]in_c_da_g;
  input [7:0]in_c_da_b;
  //
  input in_d_da_en;
  input [7:0]in_d_da_r;
  input [7:0]in_d_da_g;
  input [7:0]in_d_da_b;
  //
  output [7:0]out_da_r;
  output [7:0]out_da_g;
  output [7:0]out_da_b;
  output  out_da_en;

  reg tmg_da_en;
  reg disp_da_en;
  reg [9:0] vsync_cnt;
  reg [10:0] hsync_cnt;
  reg vsync;
  reg hsync;
  //reg p_clk ;
  reg tmg_sync;
  reg [4:0]vsync_shift;
  reg [4:0]hsync_shift;
   
  reg [7:0]out_da_r;
  reg [7:0]out_da_g;
  reg [7:0]out_da_b;
  reg  out_da_en;
  reg [9:0] v_c;
  reg [9:0] h_c;
  reg [9:0] h_c_1;
  reg [9:0] h_c_2;
  reg [9:0] h_c_3;
  reg       h_c_en; 
  reg [19:0] da_tmp2;

 
  wire in_da_en;
  wire [7:0]in_da_r;
  wire [7:0]in_da_g;
  wire [7:0]in_da_b;
   
  parameter hsync_max = 11'd1055;
  parameter vsync_max = 10'd627;
  parameter h_c_max = 10'd799;
  parameter v_c_max = 10'd599;
  parameter hsync_off_h = 11'd839;
  parameter hsync_on_h = 11'd967;
  /*
  parameter vsync_off_v = 10'd601;
  parameter vsync_off_h = 11'd0;
  parameter vsync_on_v = 10'd605;
  parameter vsync_on_h = 11'd0;
  */
  parameter vsync_off_v = 10'd600;
  parameter vsync_off_h = 11'd839;
  parameter vsync_on_v = 10'd604;
  parameter vsync_on_h = 11'd839;
  parameter da_on_v = 10'd0;
  parameter da_on_h = 11'd0;
  parameter da_off_v = 10'd599;
  parameter da_off_h = 11'd800;
   
always @ (posedge clk or negedge rstb )
if (rstb==1'b0) 
  begin  
    vsync_cnt <= 10'd0;
    hsync_cnt <= 11'd0;
  end
else
  if (hsync_cnt == hsync_max)
    begin
       hsync_cnt <= 11'd0;
        if (vsync_cnt == vsync_max)
          vsync_cnt <= 10'd0;
        else
          vsync_cnt <= vsync_cnt + 10'd1;
    end
  else
    begin
      hsync_cnt <= hsync_cnt +11'd1;
      vsync_cnt <= vsync_cnt ;
    end

always @ (posedge clk or negedge rstb )
if (rstb==1'b0) 
  begin 
     tmg_sync  <= 1'b1; 
    vsync <= 1'b1;
    hsync <= 1'b1;
    tmg_da_en <= 1'b0;
    h_c_en <= 1'b0;
    disp_da_en <= 1'b0;
  end
else
  begin
      //tmg_sync
      if ((vsync_cnt==10'd0)&&(hsync_cnt==11'd0))
        tmg_sync  <= 1'b1;
      else 
        tmg_sync  <= 1'b0;
      //vsync
      if ((vsync_cnt==vsync_on_v)&&(hsync_cnt==vsync_on_h))
        vsync <= 1'b1;
      else
        if ((vsync_cnt==vsync_off_v)&&(hsync_cnt==vsync_off_h))
          vsync <= 1'b0;
        else
          vsync <= vsync;
      //hsync
      if (hsync_cnt==hsync_on_h)
        hsync <= 1'b1;
      else
        if  (hsync_cnt==hsync_off_h)
          hsync <= 1'b0;
        else
          hsync <= hsync;
      //tmg_da_en
      if ((vsync_cnt>=da_on_v)&&(vsync_cnt <= da_off_v))
        if (hsync_cnt==da_on_h)
          tmg_da_en <= 1'b1;
        else
          if  (hsync_cnt==da_off_h)
            tmg_da_en <= 1'b0;
          else
            tmg_da_en <= tmg_da_en;
      else
        tmg_da_en <= 1'b0;
      //
       h_c_en <= tmg_da_en; 
       disp_da_en <= h_c_en; 
    end
 
   
always @ (posedge clk or negedge rstb )
if (rstb==1'b0) 
  begin 
        vsync_shift <= 5'b11111;
        hsync_shift <= 5'b11111;
  end
else
  begin
    vsync_shift <= {vsync_shift[3:0],vsync};
    hsync_shift <= {hsync_shift[3:0],hsync};
  end

assign out_vsync = vsync_shift[4];
assign out_hsync = hsync_shift[4];
//assign out_hsync = hsync_shift[3];

   
always @ (posedge clk or negedge rstb )
if (rstb==1'b0) 
  begin  
    v_c <= 10'd0;
    h_c <= 10'd0;
  end
else
    if (tmg_sync==1'b1)
          begin 
          v_c <= 10'd0;
          h_c <= 10'd0;
        end
    else
      if (tmg_da_en==1'b1)
          if (h_c == 10'd799)
                begin
              h_c <= 10'd0;
                  if (v_c == 10'd599)
                v_c <= 10'd0;
                  else
                v_c <= v_c + 10'd1;
                end
          else
                begin
              h_c <= h_c +10'd1;
              v_c <= v_c ;
                end
       else
         begin
           h_c <= h_c ;
           v_c <= v_c ;
         end

   assign in_da_r =(in_a_da_en==1'b1)?in_a_da_r:
                   (in_b_da_en==1'b1)?in_b_da_r:
                   (in_c_da_en==1'b1)?in_c_da_r:in_d_da_r;
   assign in_da_g =(in_a_da_en==1'b1)?in_a_da_g:
                   (in_b_da_en==1'b1)?in_b_da_g:
                   (in_c_da_en==1'b1)?in_c_da_g:in_d_da_g;
   assign in_da_b =(in_a_da_en==1'b1)?in_a_da_b:
                   (in_b_da_en==1'b1)?in_b_da_b:
                   (in_c_da_en==1'b1)?in_c_da_b:in_d_da_b;
   
  
   
always @ (posedge clk or negedge rstb )
if (rstb==1'b0) 
  begin
    out_da_r <= 8'd0;
    out_da_g <= 8'd0;
    out_da_b <= 8'd0;
  end
else
  if (disp_da_en==1'b0)
    begin
      out_da_r <= 8'd0;
      out_da_g <= 8'd0;
      out_da_b <= 8'd0;
    end
  else
    begin
      out_da_r  <= in_da_r;
      out_da_g  <= in_da_g;
      out_da_b  <= in_da_b;
    end
  

   
always @ (posedge clk or negedge rstb )
if (rstb==1'b0) 
  begin
          out_da_en <= 1'b0;
  end
else
        begin
          out_da_en <= out_da_en;
        end
   
endmodule






