//*****************************************************************************
// File Name            : vram_dmy.v
//-----------------------------------------------------------------------------
// Function             : dummy ram
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2010/5/31
// -.-- 2010/11/17
//******************************************************************************
module vram_dmy( 
        clka,
        wea,
        addra,
        dina,
        clkb,
        addrb,
        doutb);

input clka;
input [0 : 0] wea;
input [13 : 0] addra;
input [11 : 0] dina;
input clkb;
input [13 : 0] addrb;
output [11 : 0] doutb;
   
reg [11 : 0] doutb;
reg [11:0]         mem_1 ;
reg [11:0]         mem_2 ;
   
always @( posedge clka  )
  begin
    if (wea==1'b1)
      if ( addra==14'h000)
        mem_1 <= dina;
      else
        mem_1 <= mem_1;
  end
   
always @( posedge clka  )
  begin
    if (wea==1'b1)
      if ( addra!=14'h000)
        mem_2 <= dina;
      else
        mem_2 <= mem_2;
     
  end
 
always @( posedge clkb  )
  begin
    if  ( addrb==12'h000)
      doutb <= mem_1;
    else
      doutb <= mem_2;
  end
  
endmodule
