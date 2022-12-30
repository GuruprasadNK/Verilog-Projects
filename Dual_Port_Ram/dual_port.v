`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2022 04:21:10 PM
// Design Name: 
// Module Name: dual_port
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


module dual_port(clk1,clk2,data,out,we,w_addr,r_addr);
input clk1,clk2,we;
input [5:0] w_addr,r_addr;
input[7:0] data;
output reg [7:0] out;
reg [7:0] ram[0:1024];
always@(posedge clk1)
begin
if(we)
ram[w_addr]<=data;
end
always@(posedge clk2)
begin

out<=ram[r_addr];
end


endmodule
