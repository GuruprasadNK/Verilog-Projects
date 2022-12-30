`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/29/2022 11:22:10 PM
// Design Name: 
// Module Name: spiControl
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


module spiControl(
input clk,rst,
input [7:0]slv_data_in,
input slv_data_in_valid,
output  mst_spi_clk,
output reg mst_spi_data_out,
output reg mst_spi_data_out_valid

    );
    
 reg [2:0]counter;
 reg[2:0]state;
 localparam IDLE='d0,SEND='d1,DONE='d2;
 reg[2:0]count_check;
 reg[7:0]data_in_reg;
 reg CE;
 reg clock2;
 assign mst_spi_clk=(CE==1)?clock2:1'b1;
 
 
 initial
    clock2<=0;
 always@(posedge clk)
    begin
        if(counter!=4)
            counter<=counter+1;
        else
            counter<=0;
   end
always@(posedge clk)
    begin
        if(counter==4)
            clock2<= ~clock2;
    end


always@(negedge clock2)
    begin
        if(rst)
            begin
                state<=IDLE;
                count_check<=0;
                CE<=0;
                mst_spi_data_out<=0;
                mst_spi_data_out_valid<=0;
                
                
                
                
            end
            
        else
            case(state)
               IDLE :
                    begin
                        if(slv_data_in_valid)
                            begin
                                data_in_reg<= slv_data_in;
                                state<=SEND;
                                count_check<=0;
                            end
                     end
               SEND:
                    begin
                        mst_spi_data_out<=data_in_reg[7];
                        data_in_reg<={data_in_reg[6:0],1'b0};
                        CE<=1'b1;
                        if(count_check!=7)
                            begin
                                count_check<=count_check+1;
                            end
                        else
                            begin
                     
                                state<=DONE;
                            end
                    end
              DONE : 
                    begin
                        CE<=1'b0;
                        mst_spi_data_out_valid<=1'b1;
                        if(!slv_data_in_valid)
                            begin
                                mst_spi_data_out_valid<=1'b0;
                                state<=IDLE;
                             end
                    end
               endcase
     end           
    
endmodule
