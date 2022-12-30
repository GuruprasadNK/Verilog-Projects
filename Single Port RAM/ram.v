`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2022 12:33:12 PM
// Design Name: 
// Module Name: ram
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
/*module adder(a,b,s);
input [7:0]a,b;
output[7:0]s;
wire clk1,we_a;
wire [5:0]read_addr_a,write_addr_a;
wire [7:0]out_a,out_b;
wire we_b;
wire[5:0]read_addr_b,write_addr_b;
ram aram(clk1,we_a,a,read_addr_a,write_addr_a,out_a);
ram bram(clk1,we_b,b,read_addr_b,write_addr_b,out_b);
assign s=out_a+out_b;
endmodule
*/



module ram(clk,we,data,read_addr,write_addr,out);
input clk,we;
input [7:0] data;
input[5:0]read_addr,write_addr;
output reg[7:0] out;
reg[7:0]ram[63:0];//128 byte ram
always@(posedge clk)
begin
if(we)
begin
ram[write_addr]<=data;
end
else
out<=ram[read_addr];
end
endmodule
