`timescale 1ns / 1ps
 `define get_a  12'b0
`define   get_b 12'b01
 `define   unpack 12'b10
 `define  special_cases 12'b11
  `define   align   12'b100
    `define   add_0  12'b101
          `define    add_1 12'b110
           `define   normalise_1 12'b111
          `define    normalise_2 12'b1000
          `define    round 12'b1001
           `define   pack  12'b1010
         `define     put_z 12'b1011




module fp_adder_fsm(
        input_a,
        input_b,
        input_a_valid,
        input_b_valid,
        output_z_ready,
        clk,
     
        rst,
        output_z,
        output_z_valid,
        input_a_ready,
        input_b_ready);

  
  input clk;
  input     rst;

  input     [31:0] input_a;
  input     input_a_valid;
  output    input_a_ready;

  input     [31:0] input_b;
  input     input_b_valid;
  output    input_b_ready;

  output    [31:0] output_z;
  output    output_z_valid;
  input     output_z_ready;
  

  reg       s_output_z_valid;
  reg       [31:0] s_output_z;
  reg       s_input_a_ready;
  reg       s_input_b_ready;
  reg temp_s_input_a_ready;
  reg temp_s_input_b_ready;

  
 
 reg[4:0]state;
                   

  reg       [31:0] a, b, z;
  reg       [26:0] a_m, b_m;
  reg       [23:0] z_m;
  reg       [9:0] a_e, b_e, z_e;
  reg       a_s, b_s, z_s;
  reg       guard, round_bit, sticky;
 
  reg       [27:0] sum;
  reg temp_a,temp_b,temp_z;
  reg temp_a_m,temp_b_m;
  reg temp_z_m;
  reg temp_a_e,temp_b_e,temp_z_e;
  reg temp_a_s,temp_b_s,temp_z_s;
  reg temp_guard,temp_round_bit,temp_sticky;
  reg temp_sum,temp_z_m1,temp_z_m2,temp_z_e1;
  
  always@(posedge clk)
  begin
          s_input_a_ready <= 1;
          if (s_input_a_ready && input_a_valid) begin
            temp_a<= input_a;
            a<=temp_a;
            
            s_input_a_ready <= 0;
         
            
          end
          end
  always@(posedge clk)
  begin
   s_input_b_ready <= 1;
         if (s_input_b_ready && input_b_valid) begin
           b<= input_b;
           
           s_input_b_ready<= 0;
           
          end
          end
  

  always @(posedge clk)
    begin


    case(state)


      `unpack:
      begin
        a_m <= {a[22 : 0], 3'd0};
       // a_m<=temp_a_m;
        b_m <= {b[22 : 0], 3'd0};
       //b_m<=temp_b_m;
        a_e <= a[30 : 23] - 127;
       //a_e<=temp_a_e;
       b_e <= b[30 : 23] - 127;
      // b_e<=temp_b_e;
        a_s <= a[31];
      // a_s<=temp_a_s;
        b_s <= b[31];
        //b_s<=temp_b_s;
        state <= `special_cases;
      end


      `special_cases:
      begin
        //if a is NaN or b is NaN return NaN 
        if ((a_e == 128 && a_m != 0) || (b_e == 128 && b_m != 0)) begin
     
          z[31]<=1;
          
          z[30:23]<=255;
     
          z[22]<=1;
          
          z[21:0] <=0;
          state <= `put_z;
        //if a is inf return inf
        end else if (a_e == 128) begin
                    z[31]<=1;
                  
                  z[30:23]<=255;
             
                  z[22]<=1;
                  
                  z[21:0] <=0;
          //if a is inf and signs don't match return nan
          if ((b_e == 128) && (a_s != b_s)) begin
                               z[31]<=1;
                           
                           z[30:23]<=255;
                      
                           z[22]<=1;
                           
                           z[21:0] <=0;
          end
          state <= `put_z;
        //if b is inf return inf
        end else if (b_e == 128) begin
              z[31]<=1;
                         
                         z[30:23]<=255;
                    
                         z[22]<=1;
                         
                         z[21:0] <=0;
          state<=`put_z;
        //if a is zero return b
        end else if ((($signed(a_e) == -127) && (a_m == 0)) && (($signed(b_e) == -127) && (b_m == 0))) begin
          z[31]<=a_s&b_s;
          
          z[30:23]<=b_e[7:0] + 127;
          
          
          z[22:0]<=b_m[26:3];
         
          state <= `put_z;
        //if a is zero return b
        end else if (($signed(a_e) == -127) && (a_m == 0)) begin
           b_s<= z[31];
           
          z[30:23] <= temp_z ;
          z[22:0]<=b_m[26:3];
          
          state <= `put_z;
        //if b is zero return a
        end else if (($signed(b_e) == -127) && (b_m == 0)) begin
                   b_s<= z[31];
                     
                    z[30:23]<=a_e[7:0] + 127;
          
                      z[22:0]<=a_m[26:3];
                  
                    state <= `put_z;
        end else begin
          //Denormalised Number
          if ($signed(a_e) == -127) begin
            temp_a_e <= -126;
            a_e<=temp_a_e;
          end else begin
             temp_a_m<=1;
            a_m[26] <= temp_a_m;
          end
          //Denormalised Number
          if ($signed(b_e) == -127) begin
            temp_b_e <= -126;
            b_e<=temp_b_e;
          end else begin
             temp_b_m<=1;
            b_m[26] <= temp_b_m;
          end
          state <= `align;
        end
      end
//endcase
//end

  //always @(posedge clk)
    //begin


    //case(state)

      `align:
      begin
        if ($signed(a_e) > $signed(b_e)) begin
          b_e <= b_e + 1;
          //b_e<=temp_b_e;
         b_m<=b_m>>1;
         // b_m <= temp_b_m;
          b_m[0]<= b_m[0] | b_m[1];
         // b_m[0] <=temp_b_m;
        end else if ($signed(a_e) < $signed(b_e)) begin
          a_e <= a_e + 1;
          //a_e<=temp_a_e;
          a_m <= a_m >> 1;
          //a_m<=temp_a_m;
          a_m[0] <= a_m[0] | a_m[1];
          //a_m[0]<=temp_a_m;
        end else begin
          state <= `add_0;
        end
      end


      `add_0:
      begin
        z_e <= a_e;
        //z_e<=temp_z_e;
        if (a_s == b_s) begin
            sum <= a_m + b_m;
            //sum<=temp_sum;
          z_s <= a_s;
        end else begin
          if (a_m >= b_m) begin
            sum <= a_m - b_m;
            //sum<=temp_sum;
            z_s <= a_s;
          end else begin
            sum <= b_m - a_m;
            //um<=temp_sum;
            z_s <= b_s;
            //z_s<=temp_z_s;
          end
        end
        state <= `add_1;
      end


    //case(state)
      `add_1:
      begin
        if (sum[27]) begin
          z_m <= sum[27:4];
          
          guard <= sum[3];
          
          
          round_bit <= sum[2];
          
          sticky <= sum[1] | sum[0];
          sticky<=temp_sticky;
         
          z_e<=temp_z_e;
        end else begin
          z_m <= sum[26:3];
         
          guard <= sum[2];
         
          round_bit <= sum[1];
          
          sticky <= sum[0];
          
        end
        state <= `normalise_1;
      end

      `normalise_1:
      begin
        if (z_m[23] == 0 && $signed(z_e) > -126) begin
          //temp_z_e <= z_e - 1;
          z_e<=temp_z_e1;
          //temp_z_m <= z_m << 1;
          z_m<=temp_z_m2;
          z_m[0] <= guard;
          guard <= round_bit;
          round_bit <= 0;
       
        end else begin
          state <= `normalise_2;
        end
      end


      `normalise_2:
      begin
        if ($signed(z_e) < -126) begin
          //temp_z_e <= z_e + 1;
          z_e<=temp_z_e;
          //temp_z_m <= z_m >> 1;
          z_m<=temp_z_m1;
       
          guard<=z_m[0];
          round_bit <= guard;
          sticky <= sticky | round_bit;
          
        end else begin
          state <= `round;
        end
      end


      `round:
      begin
        if (guard && (round_bit | sticky | z_m[0])) begin
          //temp_z_m <= z_m + 1;
          z_m<=temp_z_m;
          if (z_m == 24'hffffff) begin
            //temp_z_e <=z_e + 1;
            z_e<=temp_z_e;
          end
        end
        state <= `pack;
      end

      `pack:
      begin
        z[22 : 0] <= z_m[22:0];
        z[30 : 23] <= z_e[7:0] + 127;
        temp_z_s<=z[31];
        z_s<=temp_z_s;
        if ($signed(z_e) == -126 && z_m[23] == 0) begin
          z[30 : 23] <= 0;
        end
        if ($signed(z_e) == -126 && z_m[23:0] == 24'h0) begin
          z[31] <= 1'b0; // FIX SIGN BUG: -a + a = +0.
        end
        //if overflow occurs, return inf
        if ($signed(z_e) > 127) begin
          z[22 : 0] <= 0;
          z[30 : 23] <= 255;
          z[31] <= z_s;
        end
        state <= `put_z;
      end
//endcase
//end



    //case(state)

      `put_z:
      begin
        s_output_z_valid <= 1;
        temp_z<=z;
        s_output_z<=temp_z;
     
        if (s_output_z_valid && output_z_ready) begin
          s_output_z_valid <= 0;
          state <= `get_a;
        end
      end

    endcase
//end

 // always @(posedge clk)
   // begin


    

    if (rst == 1) begin
      state <= `unpack;
      s_input_a_ready <= 0;
      s_input_b_ready <= 0;
      s_output_z_valid <= 0;
    end


end
always @(posedge clk)
begin
temp_z_e = z_e +1;
end
always @(posedge clk)
begin
     temp_z_m <= z_m + 1;
end    

always@(posedge clk)
begin
   temp_z_m <= z_m >> 1;
 end
 always@(posedge clk)
 begin
  temp_z_e1 <= z_e - 1;
  end
  
  always@(posedge clk)
  begin
  temp_z_m2 <= z_m << 1;
  end
  always@(posedge clk)
  begin
  temp_z<=b_e[7:0] + 127;
  end




  assign input_a_ready = s_input_a_ready;
  assign input_b_ready = s_input_b_ready;
  assign output_z_valid = s_output_z_valid;
  assign output_z = s_output_z;

endmodule