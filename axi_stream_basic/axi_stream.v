
`include "fp_mult.v"

`timescale 1ns / 1ps


//////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////


module axi_stream #(parameter data=32)
(

input axis_clk,
input s_axis_valid_a,
input s_axis_valid_b,
input [data-1:0] s_axis_data,
input [data-1:0] s_axis_data1,

output s_axis_ready_a,
output s_axis_ready_b,
//AXI4 Master
output reg m_axis_valid_a,
output reg m_axis_valid_b,
output reg [data-1:0]m_axis_data,
output reg [data-1:0]m_axis_data1,
input m_axis_ready_a,
input m_axis_ready_b

    );
    integer i;
    assign s_axis_ready_a=m_axis_ready_a;
    assign s_axis_ready_b=m_axis_ready_b;
    always @(posedge axis_clk)
    begin
       if(s_axis_valid_a & s_axis_ready_a)
       begin
          for(i=0;i<data/8;i=i+1)
          begin
             m_axis_data[i*8+:8]<=s_axis_data[i*8+:8];
             //m_axis_data1[i*8+:8]<=s_axis_data1[i*8+:8];
               
          end
                
       end
    end
    always @(posedge axis_clk)
        begin
           if(s_axis_valid_b & s_axis_ready_b)
           begin
              for(i=0;i<data/8;i=i+1)
              begin
                 //m_axis_data[i*8+:8]<=s_axis_data[i*8+:8];
                 m_axis_data1[i*8+:8]<=s_axis_data1[i*8+:8];
                   
              end
                    
           end
        end
    always @(posedge axis_clk)
    begin
       m_axis_valid_a <= s_axis_valid_a & s_axis_ready_a;
    end
    always @(posedge axis_clk)
        begin
           m_axis_valid_b <= s_axis_valid_b & s_axis_ready_b;
        end
   
       
       wire rst;
       wire [31:0]out;
     
     fp_mult A(m_axis_data[31:0],m_axis_data1[31:0],out[31:0],axis_clk,rst);   
  
endmodule

