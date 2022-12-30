`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2022 12:02:59 PM
// Design Name: 
// Module Name: universal_shift
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


module universal_shift(sel,in,out,clk,rst,si,so);
input[1:0]sel;
input[4:0]in;
input clk,rst,si;
output reg[4:0] out;
output so;

always@(posedge clk)
begin
if(rst)
out<=0;
else
begin
case(sel)
2'b00: out<=out;
2'b01:out<={out[3:0],si};
2'b10:out<={si,out[4:1]};
2'b11:out<=in;
default :  out<=5'b0;
endcase
end
end

assign so =(sel==2'b01)?out[4]:out[0];
endmodule
