`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module adder(eqz,lda,ldb,ldp,clrp,decb,d_in,clk);
input lda,ldb,ldp,clrp,decb,clk;
input[15:0]d_in;
output eqz;
wire[15:0]x,y,z,bout,bus;
register16 A(x,bus,lda,clk);
reg2 P(y,z,ldp,clrp,clk);
cntr B(bout,bus,ldb,decb,clk);
eq comp(eqz,bout);
endmodule

module register16 (dout,din,ld,clk);
input[15:0]din;
output reg[15:0]dout;
input ld,clk;
always @(posedge clk)
    begin
        if(ld)
            dout<=din;
    end
endmodule    
module reg2(dout,din,ld,clr,clk);
input[15:0]din;
input ld,clk,clr;
output reg[15:0]dout;
always @(posedge clk)
begin
    if(clr)
        begin
            dout<=0;
        end
    else if(ld)
        dout<=din;
        end
        
        endmodule        
module eq(eqz,data);
input [15:0]data;
output eqz;
assign eqz=(data==0);
endmodule
module add(out,in1,in2);
input [15:0]in1,in2;
output reg[15:0]out;
always @(*)
    out=in1+in2;
 endmodule
 module cntr(dout,din,ld,dec,clk);
 input [15:0]din;
 input ld,dec,clk;
 output reg[15:0]dout;
 always @(posedge clk)
 if(ld)
 dout<=din;
 else if(dec)
 dout<=dout-1;
 endmodule
 
 module controller (lda,ldb,ldp,clrp,decb,done,clk,eqz,start);
 input clk,eqz,start;
 output reg lda,ldb,clrp,decb,done,ldp;
 reg[2:0]state;
 parameter s0=3'b000,s1=3'b001,s2=3'b010,s3=3'b011,s4=3'b100;
 always @(posedge clk)
 begin
 case(state)
 s0:if(start)state<=s1;
 s1:state<=s2;
 s2:state<=s3;
 s3:#2 if(eqz)state<=s4;
 s4:state<=s4;
 default : state<=s0;
 endcase
 end
always @ (state)
begin
case(state)
    s0:begin
            lda=0;
            ldb=0;
            ldp=0;
            clrp=0;
            decb=0;
          end
    s1:begin
           lda=1;
          end
    s2:begin
        lda=0;
        ldb=1;
        clrp=1;
        end
    s3:begin
        ldb=0;
        ldp=1;
        clrp=0;
        decb=0;
        end
    s4: 
        begin
            done=1;
            ldb=0;
            ldp=0;
            clrp=0;
            decb=0;
        end
       default : begin
                    lda=0;ldb=0;ldp=0;clrp=0;decb=0;end
    endcase
    end
   endmodule
     
        
        
        
            
       
        
        
           
                  
          
            
            
            
           

 
    