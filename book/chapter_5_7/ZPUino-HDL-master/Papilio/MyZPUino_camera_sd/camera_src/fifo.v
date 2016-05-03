//*****************************************************************************
// File Name            : fifo.v
//-----------------------------------------------------------------------------
// Function             : fifo
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2010/5/31
// 1.00 2010/11/12 ���͐M�����ύX WEN -> WDAT_EN
//*****************************************************************************
module fifo
( CLK,
  RESET_N,
  WDAT_EN,
  WDAT,
  REN,
  RDAT,
  RDAT_EN,
  FULL,
  N_FULL,
  EMPTY
); 

parameter data_width = 8   ;
parameter data_no = data_width -1;
parameter adr_width = 8   ;
parameter adr_no = adr_width -1;
parameter mem_size = (1 << adr_width)-1;
   
   
input                   CLK;
input                   RESET_N;
input                   WDAT_EN;
input     [data_no:0]   WDAT;
input                   REN;
output    [data_no:0]   RDAT;
output                  RDAT_EN;
output                  FULL;
output                  N_FULL;
output                  EMPTY;

reg             FULL;
reg             N_FULL;
reg             EMPTY;
reg     [adr_no:0]    WADR;
wire    [adr_no:0]    NEXT_WADR;
reg     [adr_no:0]    RADR; 
wire    [adr_no:0]    NEXT_RADR;
wire    [adr_no:0]    BF_RADR;
wire            RAM_WEN;
wire            RAM_REN;
reg                   RDAT_EN;

//�������݃C�l�[�u��    
assign  RAM_WEN = ((WDAT_EN==1'b1)&&(FULL ==1'b0))?1'b1:1'b0;
//�Ǐo���C�l�[�u��
assign  RAM_REN = ((REN==1'b1)&&(EMPTY ==1'b0))?1'b1:1'b0;
 
//�����݃A�h���X����  
always @( posedge CLK or negedge RESET_N )
  begin
    if (RESET_N==1'b0)
      WADR <= 0;
    else
      if (RAM_WEN==1'b1)
         WADR <= WADR + 1;
      else
        WADR <= WADR;
  end

//���̏����݃A�h���X 
assign  NEXT_WADR = WADR + 1;

//�Ǐo���A�h���X����
always @( posedge CLK or negedge RESET_N )
  begin
    if (RESET_N==1'b0)
      RADR <= 0;
    else
      if (RAM_REN==1'b1)
         RADR <= RADR + 1;
      else
        RADR <= RADR;
  end

//���̓Ǐo���݃A�h���X 
assign  NEXT_RADR = RADR + 1;
   
//�O��̓Ǐo���݃A�h���X 
assign  BF_RADR = RADR - 1;

//empty�̔���   
always @( posedge CLK or negedge RESET_N )
  begin
    if (RESET_N==1'b0)
      EMPTY <= 1'b1;
    else
      if (EMPTY==1'b1)
        if (WDAT_EN==1'b1)
          EMPTY <= 1'b0;
        else
          EMPTY <= 1'b1;
      else
        //�Ǐo���A�h���X�������݃A�h���X�ɒǂ���
        if ((WADR==NEXT_RADR)&&(REN==1'b1)&&(WDAT_EN==1'b0))
          EMPTY <= 1'b1;
        else
          EMPTY <= 1'b0;
  end
          
//full�̔���   
always @( posedge CLK or negedge RESET_N )
  begin
    if (RESET_N==1'b0)
      FULL <= 1'b0;
    else
      if (FULL==1'b0)
        //�����݃A�h���X���Ǐo���A�h���X�ɒǂ���
        if ((RADR==NEXT_WADR)&&(WDAT_EN==1'b1)&&(REN==1'b0))
          FULL <= 1'b1;
        else
          FULL <= 1'b0;
      else
        if (REN==1'b1)
          FULL <= 1'b0;
        else
          FULL <= 1'b1;
  end


//n_full�̔���   
always @( posedge CLK or negedge RESET_N )
  begin
    if (RESET_N==1'b0)
      N_FULL <= 1'b0;
    else
      if (N_FULL==1'b0)
        //�����݃A�h���X���O��̓Ǐo���A�h���X�ɒǂ���
        if ((BF_RADR==NEXT_WADR)&&(WDAT_EN==1'b1)&&(REN==1'b0))
          N_FULL <= 1'b1;
        else
          N_FULL <= 1'b0;
      else
        if ((WDAT_EN==1'b0)&&(REN==1'b1))
          N_FULL <= 1'b0;
        else
          N_FULL <= 1'b1;
  end
   
//�o�̓f�[�^�C�l�[�u��  
always @( posedge CLK or negedge RESET_N )
  begin
    if (RESET_N==1'b0)
      RDAT_EN <= 1'b0;
    else
      RDAT_EN <= RAM_REN;
  end          

//�������̃C���X�^���X
ram 
#(data_width,
  data_no,
  adr_width,
  adr_no,
  mem_size
)
ram(
.CLK    (CLK),   
.WEN    (RAM_WEN),   
.WADR   (WADR),   
.WDAT   (WDAT),    
.RADR   (RADR),   
.RDAT   (RDAT));

   
endmodule
