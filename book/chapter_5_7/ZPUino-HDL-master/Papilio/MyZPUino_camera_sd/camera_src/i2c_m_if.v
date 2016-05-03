`timescale 1ns / 1ps
//******************************************************************************
// File Name            : i2c_m_if.v
//------------------------------------------------------------------------------
// Function             : i2c master if
//                        
//------------------------------------------------------------------------------
// Designer             : yokomizo 
//------------------------------------------------------------------------------
// History
// -.-- 2010/10/14
//******************************************************************************
module i2c_m_if ( 
  clk, rstb,
  scl,sda_i,sda_o,     
  adr,wr,rd,wr_data,wr_bytes,rd_data,rd_data_en,rd_bytes, 
  busy 
);
  input clk;
  input rstb;  
  output scl;
  output sda_o;
  input  sda_i;
  input [6:0]adr;
  input wr;
  input rd;
  input [31:0]wr_data;
  input [2:0]wr_bytes;
  input [2:0]rd_bytes;
  output[31:0]rd_data;
  output  rd_data_en;
  output busy;
   
  wire [3:0] wr_be;
  wire [3:0] rd_be;
  reg        wr_d1;
  reg        rd_d1;
  wire      wr_start;
  wire      rd_start;  
  wire       start_sig;
  wire       end_sig;
 
  reg [6:0] adr_reg;
  reg        rd_reg;
  reg [35:0] tx_data;
  
  reg       count_en;
  reg [11:0] time_cnt;
  reg [7:0] bit_cnt;
  reg       scl;
  reg       sda_o;
  reg       sda_i_d1;
  reg [35:0]      sda_i_reg;
  reg [31:0] rd_data;
  reg      rd_data_en;
  reg [7:0] end_bit;

  parameter p_1bit_cnt = 12'd100;
  parameter p_sda_chg = 12'd10;
   

// wr,rd 1clk delay   
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0) begin 
     wr_d1 <= 1'b0;
     rd_d1 <= 1'b0;
  end
  else begin
     wr_d1 <= wr;
     rd_d1 <= rd;
  end

// wr,rd byte enable
assign wr_be = (wr_bytes==3'd1)?4'b1000:    
               (wr_bytes==3'd2)?4'b1100: 
               (wr_bytes==3'd3)?4'b1110:
               (wr_bytes==3'd4)?4'b1111:4'b0000;
   
assign rd_be = (rd_bytes==3'd1)?4'b1000:    
               (rd_bytes==3'd2)?4'b1100: 
               (rd_bytes==3'd3)?4'b1110:
               (rd_bytes==3'd4)?4'b1111:4'b0000;

// strat signal        
assign wr_start = ((wr==1'b1)&&(wr_d1==1'b0))?1'b1:1'b0;
assign rd_start = ((rd==1'b1)&&(rd_d1==1'b0))?1'b1:1'b0;

assign start_sig = ((wr_start==1'b1)||(rd_start==1'b1))?1'b1:1'b0;
assign end_sig =   ((time_cnt==p_1bit_cnt)&&(bit_cnt==(end_bit+8'd1)))?1'b1:1'b0;

// hold adr data

always @ (posedge clk or negedge rstb )
  if (rstb==1'b0 )
    adr_reg <= 7'h00;
  else
    if (start_sig==1'b1)
      adr_reg <= adr;
    else if ((time_cnt == p_sda_chg)&&(bit_cnt>=8'd1)&&(bit_cnt<=8'd7))
      adr_reg <= {adr_reg[5:0],1'b0};
    else
      adr_reg <= adr_reg;

always @ (posedge clk or negedge rstb )
  if (rstb==1'b0 )
    rd_reg <= 1'b0;
  else
    if (start_sig==1'b1)
      if (rd==1'b1)
        rd_reg <= 1'b1;
      else
        rd_reg <= 1'b0;
    else
      rd_reg <= rd_reg;

always @ (posedge clk or negedge rstb )
  if (rstb==1'b0 )
    tx_data <= 36'hffffffff;
  else
    if (start_sig==1'b1)
      if (rd==1'b1)
        if (rd_be==4'b1000)
          tx_data <= 36'hff8000000;
        else if (rd_be==4'b1100)
          tx_data <= 36'hff7fc0000;
        else if (rd_be==4'b1110)
          tx_data <= 36'hff7fbfe00;
        else 
          tx_data <= 36'hff7fbfdff;
      else
        tx_data <= {wr_data[31:24],1'b1,wr_data[23:16],1'b1,wr_data[15:8],1'b1,wr_data[7:0],1'b1};
    else if((time_cnt ==p_sda_chg)&&(bit_cnt>=8'd10)&&(bit_cnt<=end_bit))
      tx_data <= {tx_data[34:0],1'b1};
    else
      tx_data <= tx_data;
 
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0 )
    end_bit <= 8'd44;
  else
    if (start_sig==1'b1)
      if (rd==1'b1)
        if (rd_be==4'b1111)
          end_bit <= 8'd45;
        else if (rd_be==4'b1110)  
          end_bit <= 8'd36;
        else if (rd_be==4'b1100)  
          end_bit <= 8'd27;
        else if (rd_be==4'b1000)  
          end_bit <= 8'd18;
        else
          end_bit <= 8'd18;
      else 
        if (wr_be==4'b1111)
          end_bit <= 8'd45;
        else if (wr_be==4'b1110)  
          end_bit <= 8'd36;
        else if (wr_be==4'b1100)  
          end_bit <= 8'd27;
        else if (wr_be==4'b1000)  
          end_bit <= 8'd18;
        else
          end_bit <= 8'd18;
    else
      end_bit <= end_bit;
   

// count_en
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0) 
    count_en <= 1'b0;
  else
    if (start_sig==1'b1)
      count_en <= 1'b1;
    else if (end_sig==1'b1)
      count_en <= 1'b0;
    else
      count_en <= count_en;
   
// time_count
  
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0) 
    time_cnt <= 12'h00;
  else
    if ( count_en==1'b1)
      if (time_cnt==p_1bit_cnt)
        time_cnt <= 12'h000;
      else
        time_cnt <= time_cnt + 12'h001;
    else
      time_cnt <= 12'h000;
   
// time_count
  
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0) 
    bit_cnt <= 8'h00;
  else
    if ( count_en==1'b1)
      if (time_cnt==p_1bit_cnt)
        bit_cnt <= bit_cnt + 8'h01;
      else
        bit_cnt <= bit_cnt ;
    else
      bit_cnt <= 8'h00;

//SCL
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)   
    scl <= 1'b1;
  else
    if (count_en==1'b1)
      if (time_cnt == 12'h00)
        if (bit_cnt==8'd0)
        //if ((bit_cnt==8'd0)||(bit_cnt==(end_bit+8'd2)))
          scl <= 1'b1;
        else
          scl <= 1'b0;
      else if (time_cnt == {1'b0,p_1bit_cnt[11:1]})
        scl <= 1'b1;
      else
        scl <= scl;
    else      
      scl <= 1'b1; 

//SDA output
/*
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)  
    sda_o <= 1'b1;
  else
    if (count_en==1'b1)
      if (time_cnt == 8'h00)
        if (bit_cnt==8'd0)        
          sda_o <= 1'b0;        //start
        else if ((bit_cnt>=8'd1)&&(bit_cnt<=8'd7))
          sda_o <= adr_reg[6];
        else if (bit_cnt==8'd8)
          sda_o <= rd_reg ;     //rw
        else if (bit_cnt==8'd9)
          sda_o <= 1'b1;        //ack
        else if ((bit_cnt>=8'd10)&&(bit_cnt<=end_bit))
          sda_o <= tx_data[35];  //data
        else if (bit_cnt==(end_bit+8'd1))
          sda_o <= 1'b0;         //stop
        else if (bit_cnt==(end_bit+8'd2))
          sda_o <= 1'b1;         //stop
        else
          sda_o <= sda_o;       
      else
        sda_o <= sda_o;       
    else
      sda_o <= 1'b1;
*/

always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)  
    sda_o <= 1'b1;
  else
    if ( start_sig ==1'b1)
       sda_o <= 1'b0;        //start
    else if (count_en==1'b1)
      if (time_cnt == p_sda_chg)
        if ((bit_cnt>=8'd1)&&(bit_cnt<=8'd7))
          sda_o <= adr_reg[6];
        else if (bit_cnt==8'd8)
          sda_o <= rd_reg ;     //rw
        else if (bit_cnt==8'd9)
          sda_o <= 1'b1;        //ack
        else if ((bit_cnt>=8'd10)&&(bit_cnt<=end_bit))
          sda_o <= tx_data[35];  //data
        else if (bit_cnt==(end_bit+8'd1))
          sda_o <= 1'b0;         //stop
          //sda_o <= 1'b1;         //stop
        else if (bit_cnt==(end_bit+8'd2))
          sda_o <= 1'b1;         //stop
        else
          sda_o <= sda_o;       
      else
        sda_o <= sda_o;       
    else
      sda_o <= 1'b1;
   
//SDA input


always @ (posedge clk or negedge rstb )
if (rstb==1'b0)
  sda_i_d1 <= 1'b1;
else
  sda_i_d1 <= sda_i;
 
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)
    sda_i_reg <= 36'h00000000;
  else
    if ((count_en==1'b1)&&(time_cnt == {1'b0,p_1bit_cnt[11:1]}))
      sda_i_reg <= {sda_i_reg[34:0],sda_i_d1};
    else
     sda_i_reg <= sda_i_reg;


always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)
    begin
      rd_data <= 32'h00000000;
      rd_data_en <= 1'b0;
    end
  else
    //if ((rd_reg==1'b1)&&(time_cnt=={1'b0,p_1bit_cnt[11:1]})&&(bit_cnt==8'd18))
    if ((rd_reg==1'b1)&&(time_cnt=={1'b0,p_1bit_cnt[11:1]})&&(bit_cnt==end_bit))
      begin
        if (rd_be==4'b1000)
          rd_data <= {sda_i_reg[7:0],24'h000000};
        else if (rd_be==4'b1100)
          rd_data <= {sda_i_reg[16:9],sda_i_reg[7:0],16'h0000};
        else if (rd_be==4'b1110)
          rd_data <= {sda_i_reg[25:18],sda_i_reg[16:9],sda_i_reg[7:0],8'h00};
        else 
          rd_data <= {sda_i_reg[34:27],sda_i_reg[25:18],sda_i_reg[16:9],sda_i_reg[7:0]};
        rd_data_en <= 1'b1;
      end
    else
      begin
        rd_data <= rd_data;
        rd_data_en <= 1'b0;
      end

//busy
  assign busy = count_en;
   
                       
endmodule






