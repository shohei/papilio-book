//******************************************************************************
// File Name            : layer_a.v
//------------------------------------------------------------------------------
// Function             : gazou gen layer_a (move box)
//                        
//------------------------------------------------------------------------------
// Designer             : yokomizo@himwari_co 
//------------------------------------------------------------------------------
// History
// -.-- 2010/9/22
//******************************************************************************
module layer_a (
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
  reg [7:0] bv_d_c;
  reg [7:0] bh_d_c;
      
   parameter  size_2 = 100;
   parameter  m_box_a_v = 100;
   parameter  m_box_a_h = 100;
   parameter  m_box_b_v = 150;
   parameter  m_box_b_h = 150;
   parameter  m_box_c_v = 260;
   parameter  m_box_c_h = 200;
   parameter  m_box_d_v = 260;
   parameter  m_box_d_h = 440;
   parameter  route_size_a = 8'd150;
   parameter  route_size_b = 8'd200;
   parameter  route_size_c = 8'd200;
   parameter  route_size_d = 8'd200;
   
   
   
//move_box
//box_aの位置設定
always @ (posedge clk or negedge rstb )
if (rstb==1'b0) 
  begin  
    bv_a_c <= 8'd0;
    bh_a_c <= 8'd0;
  end
else
  if ((h_c_en==1'b1)&&(h_c == 10'd799)&&(v_c == 10'd599))
    if (bv_a_c==8'd0)
      if (bh_a_c== route_size_a)
        begin
          bh_a_c <= route_size_a;
          bv_a_c <= 8'd1;
        end
      else
        bh_a_c <= bh_a_c +8'd1;
    else
      if (bh_a_c==route_size_a)
        if(bv_a_c==route_size_a)
           begin
             bv_a_c <= route_size_a;
             bh_a_c <= route_size_a -8'd1;
           end
        else
          bv_a_c <= bv_a_c +8'd1;
      else
        if(bv_a_c==route_size_a)
          if (bh_a_c==8'd0)
            begin
              bh_a_c <= 8'd0;
              bv_a_c <=  route_size_a -8'd1;
            end
          else
            bh_a_c <= bh_a_c -8'd1;
        else                          
          if (bh_a_c==8'd0)
            if(bv_a_c==8'd0)
              begin
                bv_a_c <= 8'd0;
                bh_a_c <= 8'd1;
              end
            else
               bv_a_c <= bv_a_c -8'd1;
  else
    begin
      bv_a_c <= bv_a_c;
      bh_a_c <= bh_a_c;
    end       

//box_bの位置設定
always @ (posedge clk or negedge rstb )
if (rstb==1'b0) 
  begin  
    bv_b_c <= 8'd0;
    bh_b_c <= 8'd0;
  end
else
  if ((h_c_en==1'b1)&&(h_c == 10'd799)&&(v_c == 10'd599))
    if(bv_b_c==8'd0)
      if (bh_b_c==route_size_b)
        begin
          bh_b_c <= route_size_b;
          bv_b_c <= 8'd2;
        end
      else
        bh_b_c <= bh_b_c +8'd2;
    else
      if (bh_b_c==route_size_b)
        if(bv_b_c>=route_size_b)
           begin
             bv_b_c <= route_size_b;
             bh_b_c <= route_size_b - 8'd2;
           end
        else
          bv_b_c <= bv_b_c +8'd2;
      else
        if(bv_b_c==route_size_b)
          if (bh_b_c==8'd0)
            begin
              bh_b_c <= 8'd0;
              bv_b_c <=  route_size_b - 8'd2;
            end
          else
            bh_b_c <= bh_b_c -8'd2;
        else                          
          if (bh_b_c==8'd0)
            if(bv_b_c==8'd0)
              begin
                bv_b_c <= 8'd0;
                bh_b_c <= 8'd2;
              end
            else
               bv_b_c <= bv_b_c -8'd2;
  else
    begin
      bv_b_c <= bv_b_c;
      bh_b_c <= bh_b_c;
    end // else: !if(bv_b_c<=8'd0)

//box_cの位置設定
always @ (posedge clk or negedge rstb )
if (rstb==1'b0) 
  begin  
    bv_c_c <= 8'd0;
    bh_c_c <= 8'd0;
  end
else
  if ((h_c_en==1'b1)&&(h_c == 10'd799)&&(v_c == 10'd599))
    if(bv_c_c==8'd0)
      if (bh_c_c==route_size_c)
        begin
          bh_c_c <= route_size_c;
          bv_c_c <= 8'd4;
        end
      else
        bh_c_c <= bh_c_c +8'd4;
    else
      if (bh_c_c==route_size_c)
        if(bv_c_c>=route_size_c)
           begin
             bv_c_c <= route_size_c;
             bh_c_c <= route_size_c - 8'd4;
           end
        else
          bv_c_c <= bv_c_c +8'd4;
      else
        if(bv_c_c==route_size_c)
          if (bh_c_c==8'd0)
            begin
              bh_c_c <= 8'd0;
              bv_c_c <=  route_size_c - 8'd4;
            end
          else
            bh_c_c <= bh_c_c -8'd4;
        else                          
          if (bh_c_c==8'd0)
            if(bv_c_c==8'd0)
              begin
                bv_c_c <= 8'd0;
                bh_c_c <= 8'd4;
              end
            else
               bv_c_c <= bv_c_c -8'd4;
  else
    begin
      bv_c_c <= bv_c_c;
      bh_c_c <= bh_c_c;
    end // else: !if(bv_c_c<=8'd0)
   

//box_dの位置設定
always @ (posedge clk or negedge rstb )
if (rstb==1'b0) 
  begin  
    bv_d_c <= 8'd0;
    bh_d_c <= 8'd0;
  end
else
  if ((h_c_en==1'b1)&&(h_c == 10'd799)&&(v_c == 10'd599))
    if(bv_d_c==8'd0)
      if (bh_d_c==route_size_c)
        begin
          bh_d_c <= route_size_c;
          bv_d_c <= 8'd8;
        end
      else
        bh_d_c <= bh_d_c +8'd2;
    else
      if (bh_d_c==route_size_c)
        if(bv_d_c>=route_size_c)
           begin
             bv_d_c <= route_size_c;
             bh_d_c <= route_size_c - 8'd2;
           end
        else
          bv_d_c <= bv_d_c +8'd8;
      else
        if(bv_d_c==route_size_c)
          if (bh_d_c==8'd0)
            begin
              bh_d_c <= 8'd0;
              bv_d_c <=  route_size_c - 8'd8;
            end
          else
            bh_d_c <= bh_d_c -8'd2;
        else                          
          if (bh_d_c==8'd0)
            if(bv_d_c==8'd0)
              begin
                bv_d_c <= 8'd0;
                bh_d_c <= 8'd2;
              end
            else
               bv_d_c <= bv_d_c -8'd8;
  else
    begin
      bv_d_c <= bv_d_c;
      bh_d_c <= bh_d_c;
    end // else: !if(bv_d_c<=8'd0)
   
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
      //move_bx
      //box_aと座標と一致したら出力
      if ((v_c>=bv_a_c+m_box_a_v)&&(v_c<=(bv_a_c+m_box_a_v+size_2))&&
          (h_c>=bh_a_c+m_box_a_h)&&(h_c<=(bh_a_c+m_box_a_h+size_2)))
        begin
          gen_da_en <= 1'b1;
          gen_da_r<=8'd255;
          gen_da_g<=8'd160;
          gen_da_b<=8'd160;
        end
      //box_bと座標と一致したら出力
      else if ((v_c>=bv_b_c+m_box_b_v)&&(v_c<=(bv_b_c+m_box_b_v+size_2))&&
               (h_c>=bh_b_c+m_box_b_h)&&(h_c<=(bh_b_c+m_box_b_h+size_2)))
        begin
          gen_da_en <= 1'b1;
          gen_da_r<=8'd160;
          gen_da_g<=8'd255;
          gen_da_b<=8'd160;
        end
      //box_cと座標と一致したら出力
      else if ((v_c>=bv_c_c+m_box_c_v)&&(v_c<=(bv_c_c+m_box_c_v+size_2))&&
               (h_c>=bh_c_c+m_box_c_h)&&(h_c<=(bh_c_c+m_box_c_h+size_2)))
        begin
          gen_da_en <= 1'b1;
          gen_da_r<=8'd160;
          gen_da_g<=8'd160;
          gen_da_b<=8'd255;
        end
      //box_aと座標と一致したら出力
      else if ((v_c>=bv_d_c+m_box_d_v)&&(v_c<=(bv_d_c+m_box_d_v+size_2))&&
               (h_c>=bh_d_c+m_box_d_h)&&(h_c<=(bh_d_c+m_box_d_h+size_2)))
        begin
          gen_da_en <= 1'b1;
          gen_da_r<=8'd240;
          gen_da_g<=8'd160;
          gen_da_b<=8'd240;
        end
      else
        begin
          gen_da_en <= 1'b0 ;
          gen_da_r <= 8'd0;
          gen_da_g <= 8'd0;
          gen_da_b <= 8'd0;
        end
    end
   


   
endmodule


