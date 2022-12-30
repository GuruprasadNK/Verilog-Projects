`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2022 11:00:27 AM
// Design Name: 
// Module Name: up_down_counter
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
module up_down(count,up_or_down,clk,rst);
  input clk,rst,up_or_down;
  output reg [3:0] count;
  always@(posedge clk,posedge rst)
    begin
      if(rst)
        begin
          count<=0;
        end
      else
        begin
          if(up_or_down==1)
            begin
              if(count==15)
                begin
                  count<=0;
                end
              else
                begin
                  count<=count+1;
                end
            end
          else
            begin
              if(count==0)
                begin
                  count<=15;
                end
              else
                count<=count-1;
            end
        end
    end
  
      endmodule
              
