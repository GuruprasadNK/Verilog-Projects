`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2022 12:15:15 PM
// Design Name: 
// Module Name: FIFO
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


module FIFO(data_out,fifo_full,fifo_empty,fifo_threshold,fifo_overflow,fifo_underflow,clk,rst,wr,rd,data_in);
input wr,rd,clk,rst;
input[7:0]data_in;
output[7:0]data_out;
output fifo_full,fifo_empty,fifo_threshold,fifo_overflow,fifo_underflow;
wire[4:0] wptr,rptr;
wire fifo_we,fifo_rd;
write_pointer w_dut(wptr,fifo_we,wr,fifo_full,clk,rst);
read_pointer dut(rptr,fifo_rd,rd,fifo_empty,clk,rst);
mem_Arry dut4(data_out,data_in,clk,fifo_we,wptr,rptr);
status_signal dut6(fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow, wr, rd, fifo_we, fifo_rd, wptr,rptr,clk,rst);  





endmodule


module mem_Arry(data_out,data_in,clk,fifo_we,wptr,rptr);
input clk,fifo_we;
input[7:0] data_in;
input[4:0]wptr,rptr;
output[7:0]data_out;
reg[7:0]mem_arry[15:0];//128 bytes
wire[7:0]out;
always@(posedge clk)
    begin
        if(fifo_we)
            mem_arry[wptr[3:0]]<=data_in;
    end
assign out =mem_arry[rptr[3:0]];
endmodule   

module read_pointer(rptr,fifo_rd,rd,fifo_empty,clk,rst);
input rd,fifo_empty,clk,rst;
output [4:0] rptr;
output fifo_rd;
reg[4:0] rptr;
assign fifo_rd =(~fifo_empty)&rd;
always@(posedge clk or negedge rst)
    begin
    if(~rst)
        rptr <=5'b00000;
    else if (fifo_rd)
        rptr<=rptr+5'b00001;
    else
        rptr <=rptr;
    end
endmodule


module write_pointer (wptr,fifo_we,wr,fifo_full,clk,rst);
input wr,fifo_full,clk,rst;
output[4:0]wptr;
output fifo_we;
reg [4:0]wptr;
assign fifo_we =(~fifo_full)&wr;
always@(posedge clk or negedge rst)
    begin
        if(~rst)
            wptr<=5'b00000;
        else if(fifo_we)
            wptr<=5'b00000+wptr;
        else
        wptr<=wptr;
        end
endmodule




 module status_signal(fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow, wr, rd, fifo_we, fifo_rd, wptr,rptr,clk,rst_n);  
  input wr, rd, fifo_we, fifo_rd,clk,rst_n;  
  input[4:0] wptr, rptr;  
  output fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow;  
  wire fbit_comp, overflow_set, underflow_set;  
  wire pointer_equal;  
  wire[4:0] pointer_result;  
  reg fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow;  
  assign fbit_comp = wptr[4] ^ rptr[4];  
  assign pointer_equal = (wptr[3:0] - rptr[3:0]) ? 0:1;  
  assign pointer_result = wptr[4:0] - rptr[4:0];  
  assign overflow_set = fifo_full & wr;  
  assign underflow_set = fifo_empty&rd;  
  always @(*)  
  begin  
   fifo_full =fbit_comp & pointer_equal;  
   fifo_empty = (~fbit_comp) & pointer_equal;  
   fifo_threshold = (pointer_result[4]||pointer_result[3]) ? 1:0;  
  end  
  always @(posedge clk or negedge rst_n)  
  begin  
  if(~rst_n) fifo_overflow <=0;  
  else if((overflow_set==1)&&(fifo_rd==0))  
   fifo_overflow <=1;  
   else if(fifo_rd)  
    fifo_overflow <=0;  
    else  
     fifo_overflow <= fifo_overflow;  
  end  
  always @(posedge clk or negedge rst_n)  
  begin  
  if(~rst_n) fifo_underflow <=0;  
  else if((underflow_set==1)&&(fifo_we==0))  
   fifo_underflow <=1;  
   else if(fifo_we)  
    fifo_underflow <=0;  
    else  
     fifo_underflow <= fifo_underflow;  
  end  
 endmodule 
 




