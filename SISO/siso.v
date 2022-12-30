`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2022 11:49:30 AM
// Design Name: 
// Module Name: siso
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


module siso(clk,rst,si,so);
input clk,rst;
input [3:0]si;
output reg [3:0] so;
reg[3:0]temp;

always@(posedge clk , posedge rst)
    begin
        if(rst)
            temp<=0;
       
        else
            begin
            
            temp<=temp<<1;
            temp[0]<=si;
            so = temp[3];
            end
       end
 endmodule
            
            
            
