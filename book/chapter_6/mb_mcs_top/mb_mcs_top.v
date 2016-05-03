`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:07:07 06/05/2014 
// Design Name: 
// Module Name:    mb_mcs_top 
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
//////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************
// File Name            : mb_mcs_top.v
//-----------------------------------------------------------------------------
// Function             : MicroBlaze MCS top
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2014/04/06 
//*****************************************************************************
module mb_mcs_top(
    input clk,
    input resetb,
    input rxd,
    output txd,
    output led,
    input [7:0] gpio_i,
    output [7:0] gpio_o
    );

   wire [8:0]GPO1;
   wire [7:0]GPI1;
	wire reset;
	
	assign reset = ~resetb;
   //MicroBlazeのインスタンス
   mb_mcs mcs_0 (
  .Clk(clk), // input Clk
  .Reset(reset), // input Reset
  .UART_Rx(rxd), // input UART_Rx
  .UART_Tx(txd), // output UART_Tx
  .GPO1(GPO1), // output [8 : 0] GPO1
  .GPI1(GPI1), // input [7 : 0] GPI1
  .GPI1_Interrupt(GPI1_Interrupt) // output GPI1_Interrupt
);
  assign GPI1 = gpio_i;
  assign gpio_o = GPO1[7:0];
  assign led = GPO1[8];
endmodule
