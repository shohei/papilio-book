//*****************************************************************************
// File Name            : ram.v
//-----------------------------------------------------------------------------
// Function             : ram
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2010/5/31
// -.-- 2011/11/12
//*****************************************************************************
module ram
( CLK,
  WEN,
  WADR,
  WDAT,
  RADR,
  RDAT
); 

parameter data_width = 8   ;
parameter data_no = data_width -1;
parameter adr_width = 8   ;
parameter adr_no = data_width -1;
parameter mem_size = (1 << adr_width)-1;
   
   
input                   CLK;
input                   WEN;
input     [adr_no:0]    WADR;
input     [data_no:0]   WDAT;
input     [adr_no:0]    RADR;
output    [data_no:0]   RDAT;

reg [data_no:0]         mem [0:mem_size];
   
reg    [data_no:0]   RDAT;
   
always @( posedge CLK  )
  begin
    if (WEN==1'b1)
      mem[WADR] <= WDAT;
  end
 
always @( posedge CLK  )
  begin
    RDAT <= mem[RADR];
  end
  
endmodule
