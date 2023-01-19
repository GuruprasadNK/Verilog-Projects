`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2022 10:58:13 AM
// Design Name: 
// Module Name: LSFR
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


module LSFR #(parameter N=3)
(input wire clk,rst,
output [N:0]q);
reg[N-1:0]r_reg;
wire [N-1:0]r_next;
wire feedback;

always@(posedge clk,posedge rst)
    begin
        if(rst)
            r_reg<=1;
        else if(clk==1'b1)
                r_reg<=r_next;
    end
  assign feedback =r_reg[3]^r_reg[2]^r_reg[0];
  
  assign r_next={feedback,r_reg[N-1:0]};
  assign q=r_reg;
  
endmodule
