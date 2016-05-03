//******************************************************************************
// File Name            : layer_b.v
//------------------------------------------------------------------------------
// Function             : gazou gen layer_b (color box)
//                        
//------------------------------------------------------------------------------
// Designer             : yokomizo@himwari_co 
//------------------------------------------------------------------------------
// History
// -.-- 2010/9/22
//******************************************************************************
module layer_b (
  clk,
  rstb,
  h_c_en,
  v_c,
  h_c,
  gen_da_en,
  gen_da_r,
  gen_da_g,
  gen_da_b
);

  input clk;
  input rstb;
  input h_c_en;
  input [9:0] v_c;
  input [9:0] h_c;
  output gen_da_en;
  output [7:0]gen_da_r;
  output [7:0]gen_da_g;
  output [7:0]gen_da_b;

  reg gen_da_en;
  reg [7:0]gen_da_r;
  reg [7:0]gen_da_g;
  reg [7:0]gen_da_b;
  reg [7:0] bv_a_c;
  reg [7:0] bh_a_c;  
  reg [7:0] bv_b_c;
  reg [7:0] bh_b_c;   
  reg [7:0] bv_c_c;
  reg [7:0] bh_c_c;
   
   parameter  size_1 = 125;
   parameter  r_box_v = 50;
   parameter  r_box_h = 150;
   parameter  r_box2_v = 200;
   parameter  r_box2_h = 300;
   parameter  g_box_v = 100;
   parameter  g_box_h = 200;
   parameter  b_box_v = 150;
   parameter  b_box_h = 250;
   
   parameter  size_2 = 20;
   parameter  m_box_v = 150;
   parameter  m_box_h = 300;
   parameter  route_size = 8'd240;

//rgb data gen   
always @ (posedge clk or negedge rstb )
if (rstb==1'b0) 
  begin
    gen_da_r <= 8'd0;
    gen_da_g <= 8'd0;
    gen_da_b <= 8'd0;
    gen_da_en <= 1'b0;
  end
else
  begin
      gen_da_en <= 1'b0 ;
      gen_da_r <= 8'd0;
      gen_da_g <= 8'd0;
      gen_da_b <= 8'd0;
      //red_box
      if   (((v_c>=r_box_v)&&(v_c<=(r_box_v+size_1 ))&&(h_c>=r_box_h)&&(h_c<=(r_box_h+size_1)))||
            ((v_c>=r_box2_v)&&(v_c<=(r_box2_v+size_1))&&(h_c>=r_box2_h)&&(h_c<=(r_box2_h+size_1))))
        begin
          gen_da_en <= 1'b1;       
          gen_da_r <= 8'd255;
        end
      //green_box
      if   ((v_c>=g_box_v)&&(v_c<=(g_box_v+size_1 ))&&(h_c>=g_box_h)&&(h_c<=(g_box_h+size_1)))      
        begin
          gen_da_en <= 1'b1;       
          gen_da_g <= 8'd255;
        end
      //blue_box
      if   ((v_c>=b_box_v)&&(v_c<=(b_box_v+size_1 ))&&(h_c>=b_box_h)&&(h_c<=(b_box_h+size_1)))   
        begin
          gen_da_en <= 1'b1;       
          gen_da_b <= 8'd255;
        end
      //gray bar
      if ((v_c>=60)&&(v_c<=570)&&(h_c>=60)&&(h_c<=100))
        begin
          gen_da_en <= 1'b1;
          gen_da_r <= v_c[9:1]-8'd30;
          gen_da_g <= v_c[9:1]-8'd30;
          gen_da_b <= v_c[9:1]-8'd30;
        end
      //white bar
      if ((v_c>=540)&&(v_c<=570))
        if (((h_c>=200)&&(h_c<=205))||
           ((h_c>=250)&&(h_c<=254))||
           ((h_c>=300)&&(h_c<=303))||
           ((h_c>=350)&&(h_c<=352))||
           ((h_c>=400)&&(h_c<=401)))
        begin
          gen_da_en <= 1'b1;
          gen_da_r<=8'd255;
          gen_da_g<=8'd255;
          gen_da_b<=8'd255;
        end
    end 


   
endmodule


