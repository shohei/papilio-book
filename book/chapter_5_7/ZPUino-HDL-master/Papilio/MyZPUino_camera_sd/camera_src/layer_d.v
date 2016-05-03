//******************************************************************************
// File Name            : layer_d.v
//------------------------------------------------------------------------------
// Function             : gazou gen layer_d (background) 
//                        
//------------------------------------------------------------------------------
// Designer             : yokomizo@himwari_co 
//------------------------------------------------------------------------------
// History
// -.-- 2010/9/22
//******************************************************************************
module layer_d (
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
           
   
always @ (posedge clk or negedge rstb )
if (rstb==1'b0) 
  begin
    gen_da_r <= 8'd0;
    gen_da_g <= 8'd0;
    gen_da_b <= 8'd0;
    gen_da_en <= 1'b0;  end
else
  if (h_c_en==1'b0)
    begin
      gen_da_r <= 8'd0;
      gen_da_g <= 8'd0;
      gen_da_b <= 8'd0;
      gen_da_en <= 1'b0;  
    end
  else
    //background
    begin
      gen_da_en <= 1'b1;
      gen_da_r<=8'd64;
      gen_da_g<=8'd64;
      gen_da_b<=8'd128;
    end

 


   
endmodule








