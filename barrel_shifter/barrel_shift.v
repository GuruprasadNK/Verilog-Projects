
module barrel_8_bit(in,n,lr,out);
  input [7:0]in;
  input [2:0]n;//number of shift
  input lr;//left or right shift control sigal
  output reg[7:0]out;
  always@(*)
    begin
      if(lr)
        begin
          out=in<<n;
        end
      else
        begin
          out=in>>n;
        end
    end
endmodule
