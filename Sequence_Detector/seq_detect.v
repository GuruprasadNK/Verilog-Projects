`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2022 04:16:15 PM
// Design Name: 
// Module Name: seq_detect
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


module seq_detect(

input wire clk,rst,x,
output wire z_mealy_glitch,z_moore_glitch,
output reg z_mealy_glitch_free,z_moore_glitch_free
    );
    
localparam[1:0] zero_moore=0,one_moore=1,two_moore=2,three_moore=3;

reg[1:0]state_reg_moore,state_reg_mealy;
reg[1:0]next_state_mealy,next_state_moore;


localparam[1:0]zero_mealy=0,one_mealy=1,two_mealy=2,three_mealy=3;

reg z_moore,z_mealy;

always@(posedge clk,posedge rst)
    begin
        if(rst)
            begin
                state_reg_moore<=0;
                state_reg_mealy<=0;
            end
        else
            begin
                state_reg_moore<=next_state_moore;
                state_reg_mealy<=next_state_mealy;
             end
     end


//mooore

always@(state_reg_moore,x)
begin
    z_moore=0;
    next_state_moore=state_reg_moore;
    
    case(state_reg_moore)
        zero_moore : 
                    if(x==1'b1)
                        next_state_moore=one_moore;
        one_moore :
                    if(x==1'b1)
                        next_state_moore=two_moore;
                    else
                        next_state_moore = zero_moore;
        two_moore : 
                    if(x==1'b0)
                        next_state_moore=three_moore;
        three_moore :
                    begin
                    
                    z_moore=1'b1;
                    if(x==1'b0)
                        next_state_moore=zero_moore;
                    else
                        next_state_moore=one_moore;
                    end
        endcase
end

//mealy

always@(state_reg_mealy,x)
    begin
        z_mealy=0;
        next_state_mealy=state_reg_mealy;
        case(state_reg_mealy)
            zero_mealy:
                        if(x==1'b1)
                            next_state_mealy=one_mealy;
            one_mealy : 
                        if(x==1'b1)
                             next_state_mealy=two_mealy;
                         else
                             next_state_mealy=zero_mealy;
            two_mealy:
                        begin
                            next_state_mealy=zero_mealy;
                        if(x==1'b0)
                            z_mealy=1'b1;
                        else
                            next_state_mealy=two_mealy;
                         end
            endcase
     end
     
     
 //dff to remove glitch
 
 always@(posedge clk,posedge rst)
    begin
        if(rst==1'b1)
            begin
                z_mealy_glitch_free<=1'b0;
                z_moore_glitch_free<=1'b0;
            end
         else
            begin
            
                z_mealy_glitch_free<=z_mealy;
                z_moore_glitch_free<=z_moore;
            end
    end
   
   
   
assign z_mealy_glitch=z_mealy;
assign z_moore_glitch=z_moore;

             
   
                            
                            
                   
                     

endmodule
