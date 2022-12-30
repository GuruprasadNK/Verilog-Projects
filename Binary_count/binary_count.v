`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2022 11:41:53 AM
// Design Name: 
// Module Name: binary_count
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module binary_count #( parameter N=3,M=5)
(
input wire clk,rst,
output wire complete_tick,
output [N-1:0]count
);
localparam MAX=2**N-1;
reg[N-1:0]count_reg;
wire[N-1:0]count_next;

always@(posedge clk,posedge rst)
    begin
        if(rst==1)
            count_reg<=0;
        else
            count_reg<=count_next;
     end
assign count_next =(count_reg==M-1)?1:count_reg+1;
assign complete_tick =(count_reg==M-1)?1:0;
assign count=count_reg;



endmodule
