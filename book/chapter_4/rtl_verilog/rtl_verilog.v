`timescale 1ns / 1ps

module rtl_verilog(
    input clk,
    input reset,
    input d,
    output q,
    input a,
    input b,
    input s,
    output sel_o,
    output x,
    output y
    );

dff bkock_1(
  .clk(  clk),
  .reset( reset),
  .d(  d),
  .q(    q)
);
	 
sel_dff bkock_2(
  .clk(  clk),
  .reset( reset),
  .a(  a),
  .b(  b),
  .s(  s),
  .sel_o(  sel_o)
);
	 
	 
and_gate bkock_3(
  .a(  a),
  .b(  b),
  .x(  x)
);

assign y =  ((a==1'b1)&&(b==1'b1))?1'b1:1'b0;

endmodule


module dff(
    input clk,
    input reset,
    input d,
    output reg q
    );
	 
always @ (posedge clk or posedge reset )
  if (reset==1'b1)
    q <= 1'b0;
  else
    q <= d;	 
	
endmodule


module sel_dff(
    input clk,
    input reset,
    input a,
    input b,
    input s,
    output reg sel_o
    );
	
always @ (posedge clk or posedge reset )
  if (reset==1'b1)
    sel_o <= 1'b0;
  else
    if (s==0)
      sel_o <= a;
	 else
      sel_o <= b;	 
endmodule


module and_gate(
    input a,
    input b,
    output reg x
    );

always @ (a or b )
  if ((a==1'b1)&&(b==1'b1))
    x <= 1'b1;
  else
    x <= 1'b0;
	 
endmodule
