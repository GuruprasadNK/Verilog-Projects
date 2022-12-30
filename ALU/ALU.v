`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2022 07:30:04 PM
// Design Name: 
// Module Name: ALU
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


module ALU(in1,in2,out);
input [3:0] in1,in2;
output reg [4:0] out;


reg [3:0]opcode;

parameter add=4'b0000,sub=4'b0001,mul=4'b0010,div=4'b0011,parity=4'b0100,AND=4'b0101,OR=4'b0110;

always@(*)
begin
case(opcode)
add : begin
        out<=in1+in2;
      end
sub : begin
        out<=in1-in2;
      end
mul :  begin
        out<=in1*in2;
       end
div :  begin
        out<=in1%in2;
       end
parity :  begin
            out<=^in1;
            out<=^in2;
            end
AND : begin
        out<=in1&in2;
        end
OR : begin
        out<=in1|in2;
        end
        
               
    
      
      
default : begin
            out<=4'd0;
          end
endcase
end
endmodule

           
       
 
