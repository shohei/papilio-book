`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:29:53 05/06/2014 
// Design Name: 
// Module Name:    blink_led 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////////
// ****************************************************************************
// File Name            :  blink_led.v
//-----------------------------------------------------------------------------
// Function             :  blink_led 
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2014/09/10
// *****************************************************************************
module blink_led(
    input clk,
    input resetb,
    output led
    );

reg [25:0] cnt;

always @ (posedge clk or negedge resetb )
  if (resetb==1'b0)
    cnt <= 26'd0;
  else
     cnt <= cnt + 24'd1;

assign led = cnt[25];
	 
endmodule
