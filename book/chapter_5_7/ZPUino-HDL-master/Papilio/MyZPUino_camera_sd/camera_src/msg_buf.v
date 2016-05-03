//----------------------------------------------------------------------------
//*****************************************************************************
// File Name            : msg_buf.v
//-----------------------------------------------------------------------------
// Function             : message buffer and arbitartion 
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2010/5/31
// -.-- 2010/11/12
//*****************************************************************************
module msg_buf
( CLK,
  RESET_N,
  A_DAT_EN,
  A_DAT,
  A_N_FULL,
  B_DAT_EN,
  B_DAT,
  B_N_FULL,
  O_DAT,
  O_DAT_EN,
  O_BUSY
); 

parameter data_width = 8   ;
parameter data_no = data_width -1;
parameter adr_width = 3   ;
parameter adr_no = adr_width -1;
parameter mem_size = (1 << adr_width)-1;
   
   
input                   CLK;
input                   RESET_N;
input                   A_DAT_EN;
input     [data_no:0]   A_DAT;
output                  A_N_FULL;
input                   B_DAT_EN;
input     [data_no:0]   B_DAT;
output                  B_N_FULL;
output                   O_DAT_EN;
output     [data_no:0]   O_DAT;
input                   O_BUSY;


wire                  REN_A;
wire                  RDAT_EN_A;
wire    [data_no:0]   RDAT_A;
wire            FULL_A;
wire            N_FULL_A;
wire            EMPTY_A;

wire                  REN_B;
wire                  RDAT_EN_B;
wire    [data_no:0]   RDAT_B;
wire            FULL_B;
wire            N_FULL_B;
wire            EMPTY_B;

wire    A_REQ;
wire    A_REDAY;
wire    B_REQ;
wire    B_REDAY;
wire                   ABT_DAT_EN;
wire     [data_no:0]   ABT_DAT;   


wire            REN_O;
wire            FULL_O;
wire            N_FULL_O;
wire            EMPTY_O;
   
fifo
#(data_width,
  data_no,
  adr_width,
  adr_no,
  mem_size
)

DUT_A(
.CLK    (CLK),
.RESET_N  (RESET_N), 
.WDAT_EN    (A_DAT_EN),   
.WDAT   (A_DAT),  
.REN    (REN_A),     
.RDAT   (RDAT_A),
.RDAT_EN   (RDAT_EN_A),
.EMPTY  (EMPTY_A),
.FULL   (FULL_A),
.N_FULL   (N_FULL_A)
);

fifo
#(data_width,
  data_no,
  adr_width,
  adr_no,
  mem_size
)

DUT_B(
.CLK    (CLK),
.RESET_N  (RESET_N), 
.WDAT_EN    (B_DAT_EN),   
.WDAT   (B_DAT),  
.REN    (REN_B),     
.RDAT   (RDAT_B),
.RDAT_EN(RDAT_EN_B),
.EMPTY  (EMPTY_B),
.FULL   (FULL_B),
.N_FULL   (N_FULL_B)
);

assign A_REQ = ~EMPTY_A;
assign REN_A = A_REDAY;
assign A_N_FULL = N_FULL_A;
   
assign B_REQ = ~EMPTY_B;
assign REN_B = B_REDAY;
assign B_N_FULL = N_FULL_B;

assign O_REDAY = ~N_FULL_O;
assign REN_O = ~ O_BUSY;
   
abt
#(data_width,
  data_no
)

ABT(
.CLK    (CLK),
.RESET_N  (RESET_N), 
.A_REQ   (A_REQ),   
.A_REDAY (A_REDAY),   
.A_DAT_EN(RDAT_EN_A),  
.A_DAT   (RDAT_A),  
.B_REQ   (B_REQ),   
.B_REDAY (B_REDAY),   
.B_DAT_EN(RDAT_EN_B),  
.B_DAT   (RDAT_B),  
.O_REQ   (O_REQ),   
.O_REDAY (O_REDAY),   
.O_DAT_EN(ABT_DAT_EN),  
.O_DAT   (ABT_DAT)
);
   

fifo
#(data_width,
  data_no,
  adr_width,
  adr_no,
  mem_size
)

DUT_O(
.CLK    (CLK),
.RESET_N  (RESET_N), 
.WDAT_EN    (ABT_DAT_EN),   
.WDAT   (ABT_DAT),  
.REN    (REN_O),     
.RDAT   (O_DAT),
.RDAT_EN(O_DAT_EN),
.EMPTY  (EMPTY_O),
.FULL   (FULL_O),
.N_FULL (N_FULL_O)
);
   
    
 
endmodule
