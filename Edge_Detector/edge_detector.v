`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2022 04:37:08 PM
// Design Name: 
// Module Name: edge_detector
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


module edge_detector(input wire clk,rst,level,output reg mealy_tick,moore_tick );
localparam zeromealy=1'b0,onemealy=1'b1;
localparam[1:0] zeromoore=2'b0,edgemoore=2'b01,onemoore=2'b10;
reg statemealy_reg, statemoore_reg;
reg[1:0] statemealy_next,statemoore_next;


always@(posedge clk,posedge rst)
    begin
        if(rst)
            begin
                
                statemealy_reg <= zeromealy;
                statemoore_reg <= zeromoore;
            end
        else
            begin
                statemealy_reg <= statemealy_next;
                statemoore_reg<=statemoore_next;
            end                      
    end
    
always@(level,statemealy_reg)
    begin
        statemealy_next = statemealy_reg;
        mealy_tick=1'b0;
        case(statemealy_reg)
            zeromealy :
                        if(level)
                                begin
                                    statemealy_next=onemealy;
                                    mealy_tick=1'b1;
                                 end
             onemealy : 
                        if(~level)
                            begin
                                statemealy_next =zeromealy;
                             end
                                
         endcase
         
   end
   
   
   
 always@(level,statemoore_reg)
    begin
        statemoore_next = statemoore_reg;
        moore_tick =1'b0;
        
        case(statemoore_reg)
            zeromoore : 
                        if(level)
                            begin
                                statemoore_next =edgemoore;
                             end
                             
            edgemoore : 
                    begin
                    
                        moore_tick =1'b1;

                        
                        if(level)
                            begin
                            statemoore_next =onemoore;
                            end
                        else
                            statemoore_next = zeromoore;
                     end
                            
            onemoore : 
                        if(~level)
                            statemoore_next=zeromoore;
                
                            
        endcase
        
   end
        
endmodule
