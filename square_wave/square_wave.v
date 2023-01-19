`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2022 09:46:37 PM
// Design Name: 
// Module Name: square_wave
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


module square_wave 
(
input wire clk,rst,
output reg s_wave
);
parameter N=4, on_time=3'd5,off_time=3'd3;
localparam onstate=0,offstate=1;
reg state,next_state;
reg[N-1:0]t=0;

always@(posedge clk,posedge rst)
    begin
        if(rst)
            begin
            state<=0;
            end
        else
            state<=next_state;
   end
   
   
 always@(posedge clk, posedge rst)
    begin
        if(state!=next_state)
            t<=0;
        else
            t<=t+1;
     end
 always@(state,t)
    begin
        case(state)
            offstate:begin
                        s_wave=1'b0;
                        if(t==off_time-1)
                            next_state<=onstate;
                        else
                            next_state<=offstate;
                       end
            onstate : begin
                        s_wave=1'b1;
                        if(t==on_time-1)
                            next_state=offstate;
                        else
                            next_state=onstate;
                      end
          endcase
    end
 endmodule
            
            
