// Code your testbench here
// or browse Examples
module barrel_tb();
  reg [7:0]in;
  reg[2:0]n;
  reg lr;
  wire [7:0]out;
  barrel_8_bit dut(in,n,lr,out);
  initial 
    $monitor("time=%d\t in=%b\t n=%b\t lr=%d\t out=%b\t",$time,in,n,lr,out);
  initial begin
    in=8'b0;
    n=3'b0;
    lr=0;
    repeat(5)
      begin
        #5 in=in+1;
        repeat(5)
          begin
            
         	 #5 n=n+1;
            repeat(4)
              begin
                #5 lr=~lr;
              end
          end
      end
  end
endmodule

      