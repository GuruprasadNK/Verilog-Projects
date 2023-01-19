`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2022 01:06:54 PM
// Design Name: 
// Module Name: fp_axi
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
/////////////////////////////////////////////////////////////////////////////
module axi_stream_fp #(parameter data=32)
(

input axis_clk,
input axis_reset,
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
    
  wire [31:0] m_out;
  wire [24:0]test;
  wire [7:0]shi;
  wire c_o;
  
  float_adder axi_inter(m_axis_data[31:0],m_axis_data1[31:0],m_out[31:0],test[24:0],shi[7:0],c_o);
endmodule
module float_adder(
    input [31:0] a,
    input [31:0] b,
    output [31:0] Out,
	 output [24:0] Out_test,
	 output [7:0] shift,
	 output c_out,sa,sb,
	 output reg sign
    );
	wire [7:0] sm_exp_diff,exp_out_mux,exp_out_inc;
	wire sel_shit_r,sel_no_shift_r,inc,sel_max_exp,sm_exp_brw;
	wire [24:0] fl_add_out,final_out;
	wire [22:0] frac_out;
assign sa=a[31:31];
assign sb=b[31:31];

always @(*)
begin
if(sa==1 && sb==0)
begin
sign =sa;
end
else
begin
sign=sb;
end
end

	assign c_out = Out_test[24:24];
	
	exp_alu sub_alu1(a[30:23],b[30:23],sm_exp_diff[7:0],sm_exp_brw);
	signal_controller sc(sm_exp_diff[7:0],c_out,sm_exp_brw,sel_shift_r,sel_no_shift_r,shift,inc,sel_max_exp);
	fract_add FDD(a[22:0],b[22:0],shift[7:0],sel_shift_r,sel_no_shift_r,Out_test);
	mux_exp e_m(a[30:23],b[30:23],sel_max_exp,exp_out_mux);
	 final_fp_out dut(exp_out_mux,inc,Out_test,exp_out_inc,final_out);
	assign frac_out = final_out[22:0];
	assign Out = {sign,exp_out_inc,frac_out};
endmodule
        





module fract_add(
    input [22:0] a,
    input [22:0] b,
    input [7:0] shift,
    input sel_b,
    input sel_a,
    output reg [24:0] Out
    );

	wire [23:0] sr_input, alu_input_a;
reg [23:0]	alu_input_b;
	fraction_mux mux0({1'b1,a},{1'b1,b},sel_a,alu_input_a);
	fraction_mux mux1({1'b1,a},{1'b1,b},sel_b,sr_input);
	always@(*)
	begin
	 alu_input_b = sr_input >> shift;
	 Out = alu_input_a + alu_input_b;
	end
endmodule
module mux_exp(
    input [7:0] exp_a,
    input [7:0] exp_b,
    input sel_c,
    output [7:0] exp_out
    );

	assign exp_out = (sel_c) ? exp_b : exp_a;
endmodule

module final_fp_out(
    input [7:0] exp_diff,
    input inc_control,
    input [24:0] shifter,
    output reg[7:0] exp_out,
    output reg [24:0] frac_out
    );

	always@(*)
	begin
		if(inc_control > 0)
			begin
				exp_out = exp_diff + 8'b1;
				frac_out = shifter >> 1'b1;
			end

		else
			begin
				exp_out = exp_diff - 8'b0;
				frac_out = shifter << 1'b0;				
			end
	end
endmodule
module signal_controller(
    input [7:0] exp_diff,
    input c_out,
	 input sm_alu_sign,
    output reg sel_b,
    output reg sel_a,
    output reg [7:0] shift,
	 output reg inc,
	 output reg sel_c
    );
always@(exp_diff or sm_alu_sign or c_out)
	begin
		if(sm_alu_sign ==  0)
			begin
				sel_a = 1'b0; 	
                sel_b = 1'b1; 			
                sel_c = 1'b0; 				
                shift = exp_diff;
			end
		else
			begin
				sel_a = 1'b1; 				
                 sel_b = 1'b0; 				
                sel_c = 1'b1;				
                 shift = ~exp_diff +1;
		end
	end
	always@(c_out)
		begin
		if(c_out > 0)
				inc = 1'b1;
		else
				inc = 1'b0;
		end
endmodule


module exp_alu(
    input [7:0] a,
    input [7:0] b,
    output reg [7:0] c,
	 output reg sign
    );
	
	always@(a or b)
	begin
		if(a >= b)
		begin
			c = a-b;
			sign = 1'b0;
		end
		else
		begin
			c=a-b;
			sign = 1'b1;
		end
	end
endmodule
module fraction_mux(
    input [23:0] a,
    input [23:0] b,
    input sel,
    output [23:0] Out
    );
	assign Out = (sel) ? b : a;
endmodule