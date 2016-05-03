//*****************************************************************************
// File Name            : i2c_ov7670_ctrl.v
//-----------------------------------------------------------------------------
// Function             : i2c ov7670 controler
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2010/10/14
// -.-- 2010/11/15
// -.-- 2010/11/17
//******************************************************************************
module i2c_ov7670_ctrl ( 
 clk, rstb,
 cmd_wr,cmd_rd,cmd_adr,cmd_data,
 wr,rd,adr,wr_data,wr_bytes,rd_data,rd_data_en,rd_bytes, 
 tx_fifo_data,tx_fifo_data_en
);
  input clk;
  input rstb;  
  input  cmd_wr;
  input  cmd_rd;
  input[7:0]cmd_adr;
  input[7:0]cmd_data;
  
  output wr;
  output rd;
  output [6:0]adr;
  output [31:0]wr_data;
  output [2:0]wr_bytes;
  output [2:0]rd_bytes;
  input[31:0]rd_data;
  input  rd_data_en;
  output  [7:0] tx_fifo_data;    //tx fifo data 8bit
  output        tx_fifo_data_en; //tx fifo data enable 
 
  reg  [25:0] main_cnt;
  reg wr;
  reg rd;
  reg [6:0]adr;
  reg [31:0]wr_data; 
  reg [2:0]wr_bytes; 
  wire [3:0]wr_be; 
  wire rd_data_en;
  wire [31:0]rd_data;
  reg [2:0]rd_bytes; 
  wire [3:0]rd_be; 
  reg [3:0] msg_cnt;  //tx fifo data 8bit
  reg [1:0] msg_type;
  wire [31:0]msg_data;
  wire [3:0]msg_be;
  reg  [7:0] tx_fifo_data;    //tx fifo data 8bit
  reg        tx_fifo_data_en; //tx fifo data enable 
  reg [7:0] mem_adr;
  reg [7:0] mem_dat;
  reg        done;
  reg  [25:0] read_tmg;
  reg  cmd_rd_flg;
 
   
function [7:0] hex2ascii;
  input [3:0] hex_data;
  begin
    if (hex_data<4'ha)
      hex2ascii = 8'h30 + hex_data;
    else
      hex2ascii = 8'h37 + hex_data;
  end
endfunction
   
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0) begin 
    main_cnt <= 26'b0;
  end
  //else if (main_cnt == 26'd7999999) begin
  else if (main_cnt == 26'd39999999) begin
  //else if (main_cnt ==26'd5000000) begin
    main_cnt <= 26'b0;
    end
  else begin
    main_cnt <= main_cnt + 26'd1;
  end
    
// for OV7670

always @ (posedge clk or negedge rstb )
  if (rstb==1'b0) begin
    wr <= 1'b0;
    wr_data <=32'h00000000;
    wr_bytes <= 3'd0; 
    adr <= 7'b0100001;  //OV7670  
    mem_adr <= 8'h00; 
    mem_dat <= 8'h10; 
    end
  else if(done==1'b0)
    //初期設定
    if (main_cnt == 26'd2000000)
      begin
        //データ書き込み
        wr <= 1'b1;
        //[31:16]には書込みアドレス,[15:0]には書込みデータ
        wr_data <= {32'h12040000};
        adr <= adr ;
        wr_bytes <= 3'd2;
      end
    else
      begin
        wr <= 1'b0;
        wr_data <= wr_data;
        adr <= adr;
        wr_bytes <= wr_bytes; 
      end // else: !if(main_cnt == 26'd2000000)
  //コマンド受付 
  else if (cmd_wr==1'b1)
    begin
        //データ書き込み
        wr <= 1'b1;
        //[31:16]には書込みアドレス,[15:0]には書込みデータ
        wr_data <= {cmd_adr,cmd_data,16'h0000};
        adr <= adr ;
        wr_bytes <= 3'd2;
    end
  else if (cmd_rd==1'b1)
    begin
        //データ書き込み
        wr <= 1'b1;
        //[31:16]には書込みアドレス,[15:0]には書込みデータ
        wr_data <= {cmd_adr,cmd_data,16'h0000};
        adr <= adr ;
        wr_bytes <= 3'd1;
    end
  else
    begin
      wr <= 1'b0;
      wr_data <= wr_data;
      adr <= adr;
      wr_bytes <= wr_bytes; 
    end

always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)
    begin
      rd <= 1'b0; 
      rd_bytes <= 3'd0; 
    end   
  else   
    if (done==1'b0)
      if((main_cnt ==26'd1500000)||
         (main_cnt ==26'd3500000)||
         (main_cnt ==26'd4500000)||
         (main_cnt ==26'd6500000)||
         (main_cnt ==26'd8500000))
        begin
          //データ読み出し　
          rd <= 1'b1;
          rd_bytes <= 3'd1; 
        end
      else
        begin   
          rd <= 1'b0;
          rd_bytes <= rd_bytes; 
        end
    else if ((cmd_rd_flg==1'b1)&&(read_tmg==main_cnt))   
        begin
          //データ読み出し　
          rd <= 1'b1;
          rd_bytes <= 3'd1; 
        end
    else
      begin   
        rd <= 1'b0;
        rd_bytes <= rd_bytes; 
      end   
   
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)
    read_tmg <= 26'd0;
  else
    if (cmd_rd==1'b1)
      if (main_cnt <= 27'd39499999)
        read_tmg <= main_cnt + 26'd500000;
      else
        read_tmg <= (26'd40499999-main_cnt);
    else
      read_tmg <= read_tmg;
   
   
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)
    cmd_rd_flg <= 1'b0;
  else
    if (cmd_rd==1'b1)
      cmd_rd_flg <= 1'b1;
    else if(read_tmg==main_cnt)
      cmd_rd_flg <= 1'b0;
    else
      cmd_rd_flg <= cmd_rd_flg;

//初期設定終了時刻設定   
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0) 
    done <=1'b0;
    //done <=1'b1;
  else if (main_cnt ==26'd100)
  //else if (main_cnt ==26'd9000000) //ORG
    done <= 1'b1;
        
// wr,rd byte enable
assign wr_be = (wr_bytes==3'd1)?4'b1000:    
               (wr_bytes==3'd2)?4'b1100: 
               (wr_bytes==3'd3)?4'b1110:
               (wr_bytes==3'd4)?4'b1111:4'b0000;
   
assign rd_be = (rd_bytes==3'd1)?4'b1000:    
               (rd_bytes==3'd2)?4'b1100: 
               (rd_bytes==3'd3)?4'b1110:
               (rd_bytes==3'd4)?4'b1111:4'b0000;
   

//メッセージ生成

always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)
    msg_type <= 2'b0;
  else
    if (wr==1'b1)
      msg_type <= 2'b00;
    else if (rd_data_en==1'b1)
      msg_type <= 2'b01;
    else
      msg_type <= msg_type;
   
assign msg_data =(msg_type == 2'b00)? wr_data:
                 (msg_type == 2'b01)? rd_data:32'h00000000;
   
assign msg_be =( msg_type == 2'b00)? wr_be:
               ( msg_type == 2'b01)? rd_be:4'b0000;
   

//メッセージ生成用カウンタ
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)
    msg_cnt <= 4'd0;
  else
    if ((wr==1'b1)||(rd_data_en==1'b1))
      msg_cnt <= 4'd1;
    else
      if (msg_cnt==4'd0)
        msg_cnt <= 4'd0;
      else
        msg_cnt <= msg_cnt + 4'd1;

//メッセージ出力    
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)
    begin
      tx_fifo_data <= 8'h00;
      tx_fifo_data_en <= 1'b0;
    end
  else
    case(msg_cnt)
      4'd0:begin
        tx_fifo_data <= 8'h00;
        tx_fifo_data_en <= 1'b0;
        end
      4'd1:begin
        if (msg_type==2'b00) 
          begin
            tx_fifo_data <= 8'h57; //"W"
            tx_fifo_data_en <= 1'b1;
          end
        else if (msg_type==2'b01) 
          begin
            tx_fifo_data <= 8'h52; //"R"
            tx_fifo_data_en <= 1'b1;
          end
        else  
          begin
            tx_fifo_data <= 8'h44; //"E"
            tx_fifo_data_en <= 1'b1;
          end
        end
      4'd2:begin
        tx_fifo_data <= 8'h5f; // "-"
        tx_fifo_data_en <= 1'b1;
        end
      4'd3:begin
        if (msg_type[1]==1'b0)
          begin 
             tx_fifo_data <= hex2ascii(adr[6:3]);
             tx_fifo_data_en <= 1'b1;
          end
        else
          begin
            tx_fifo_data <= 8'h5f; // "-"
            tx_fifo_data_en <= 1'b1;
          end
        end
      4'd4:begin
        if (msg_type[1]==1'b0)
          begin
            tx_fifo_data <= hex2ascii({adr[2:0],msg_type[0]});
            tx_fifo_data_en <= 1'b1;
          end
        else
          begin
            tx_fifo_data <= 8'h5f; // "-"
            tx_fifo_data_en <= 1'b1;
          end
        end        
      4'd5:begin
        tx_fifo_data <= 8'h5f; // "-"
        tx_fifo_data_en <= 1'b1;
        end
      4'd6:begin
        tx_fifo_data <=  hex2ascii(msg_data[31:28]);
        tx_fifo_data_en <= msg_be[3];
        end
      4'd7:begin
        tx_fifo_data <=  hex2ascii(msg_data[27:24]);
        tx_fifo_data_en <= msg_be[3];
        end
      4'd8:begin
        tx_fifo_data <=  hex2ascii(msg_data[23:20]);
        tx_fifo_data_en <= msg_be[2];
        end
      4'd9:begin
        tx_fifo_data <=  hex2ascii(msg_data[19:16]);
        tx_fifo_data_en <= msg_be[2];
        end
      4'd10:begin
        tx_fifo_data <=  hex2ascii(msg_data[15:12]);
        tx_fifo_data_en <= msg_be[1];
        end
      4'd11:begin
        tx_fifo_data <=  hex2ascii(msg_data[11:8]);
        tx_fifo_data_en <= msg_be[1];
        end
      4'd12:begin
        tx_fifo_data <=  hex2ascii(msg_data[7:4]);
        tx_fifo_data_en <= msg_be[0];
        end
      4'd13:begin
        tx_fifo_data <=  hex2ascii(msg_data[3:0]);
        tx_fifo_data_en <= msg_be[0];
        end
      4'd14:begin
        tx_fifo_data <= 8'h0a; // LF
        tx_fifo_data_en <= 1'b1;
        end
      default
        begin
          tx_fifo_data <= 8'h00;
          tx_fifo_data_en <= 1'b0;
        end
    endcase
              

   
endmodule






