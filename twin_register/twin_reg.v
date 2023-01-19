`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2022 11:05:25 AM
// Design Name: 
// Module Name: twin_reg
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


module twin_reg(rst,d1,d2,clk,q1,q2);
input [7:0]d1,d2;
input clk,rst;
output reg[7:0] q1,q2;
always@(posedge clk)
begin
if(rst)
begin
q1<=0;
q2<=0;
end
else
begin
q1<=d1;
q2<=d2;
end
end

endmodule
