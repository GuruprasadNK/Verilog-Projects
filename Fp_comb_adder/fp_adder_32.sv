module fp_adder (
	input clk,
	input reset,
	input [31:0] a,
	input [31:0] b,
	input  a_valid, 
	input  b_valid,
	input [2:0]rounding_mode ,
	output reg[31:0] sum,
	output reg a_ready,
	output reg b_ready,
	output reg out_valid_4);



	//intermidiate wire and reg
	reg [31:0] a1;
    reg [31:0] b1;
    reg a_excepted;
    reg b_excepted;
	reg ab_excepted;
	reg [27:0] significand1,significand1new,significand1_2;
	reg [27:0] significand2,significand2new,significand2_2;
	reg [27:0] significandx,significandx_3,significandx_4;
	reg [27:0] significand_small,significand_small_3;
	reg [27:0] significand_r_shift;
	reg [27:0] significandini,significandini_5new;
	reg [27:0] significandfinal;
	reg [27:0] significandfinale;
	
	//reg significand_shift[0:23][24:0];
	reg out_valid,out_valid_2,out_valid_3;

	reg [7:0] exponent1,exponent1new,exponent1_2;
	reg [7:0] exponent2,exponent2new,exponent2_2;
	reg [7:0] exponent_diff;
	reg [7:0] exponentx,exponentx_3,exponentx_5new;
	reg [7:0] exponentfinal;
	reg [7:0] exponent_abs,exponent_abs_2, exponent_abs_3; 
	reg [7:0] exponentfinale;
	//reg exponent_shift[0:23][7:0];

	reg sign1,sign1_2;
	reg sign2,sign2_2;
	reg signfinal;
	reg signx,signx_3,signx_4,signx_5;
	
	reg sel,sel_2;
	reg op,op_2,op_3 ;
	reg flag_infinity,flag_infinity_2,flag_infinity_3;
	reg flag_zero,flag_zero_2,flag_zero_3;
	reg flag_nan,flag_nan_2,flag_nan_3;
	reg [253:0]for_sticky;
	reg [281:0]significand_small_forsticky;
	

// this is used for handshaking with axi stream

always @(posedge clk) begin
	if(reset)
	a1 <= 32'd0;
	
	else if(a_ready && a_valid)
	a1 <= a;
end



always @(posedge clk) begin
 	if(reset) 
	a_excepted <=1'b0;
	
	else if( a_ready && a_valid && ~ b_excepted && ~b_valid )
	a_excepted <=1'b1;
	
	else if( ( a_valid && b_valid) || (a_valid && b_excepted) || (b_valid && a_excepted))
	a_excepted <=1'b0;
end



always @(posedge clk) begin
	if(reset)
	b1 <= 32'd0;
	
	else if(b_ready && b_valid)
	b1 <= b;
end


always @(posedge clk) begin
	if(reset) 
	b_excepted <=1'b0;
	
	else if( b_ready && b_valid && ~ a_excepted && ~a_valid )
	b_excepted <=1'b1;
	
	else if( ( a_valid && b_valid) || (a_valid && b_excepted) || (b_valid && a_excepted))
	b_excepted <=1'b0;
end



always @(posedge clk) begin
	if(reset) 
	ab_excepted <=1'b0;
	
	else if( ( a_valid && b_valid) || (a_valid && b_excepted) || (b_valid && a_excepted))
	ab_excepted <=1'b1;
	else
	ab_excepted <=1'b0;
end

always @(posedge clk) begin
	if(reset)
	a_ready<=1'b0;
	else if ((a_valid || a_excepted) & ~ b_excepted & ~b_valid )
	a_ready <=1'b0;
	else
    a_ready <=1'b1;
end


always @(posedge clk) begin
	if(reset)
	b_ready<=1'b0;
	else if ((b_valid ||b_excepted) & ~ a_excepted & ~a_valid )
	b_ready <=1'b0;
	else
        b_ready <=1'b1;
end


	
//stage 1  sequential

always @(posedge clk)
begin				

//pass valid input		
//when we have both the input then proceed
//ab excepted will 1 when we have both the input

if(ab_excepted==1'b1)
begin
out_valid<=1'b1;

significand1 <= { 2'b01, a1[22:0],3'b000};
exponent1 <= a1[30:23];
sign1 <= a1[31];


significand2 <= { 2'b01, b1[22:0],3'b000};
exponent2 <= b1[30:23];
sign2 <= b1[31];

end

else
begin

out_valid<=1'b0;
significand1 <= significand1;
exponent1 <= exponent1;
sign1 <= sign1;


significand2 <= significand2;
exponent2 <= exponent2;
sign2 <= sign2;

end
end

// 1st combinational

always @(*)
begin
exponent1new=exponent1;
exponent2new=exponent2;

significand1new=significand1;
significand2new=significand2;
//inputs are getting checked for infinity 

if((exponent1new == 255 && significand1new[25:3]==23'd0) || (exponent2new == 255 && significand2new[25:3]==23'd0))
begin
flag_infinity=1'b1;//infinity
flag_nan=1'b0;
flag_zero=1'b0;
//this sel use for sign bit of infinity

if($unsigned(exponent1new)> $unsigned(exponent2new))
	begin
	sel=1'b0;
	end

else if ($unsigned(exponent2new)> $unsigned(exponent1new))
	begin
	sel=1'b1;
	end
end
//inputs are getting checked for nan

else if((exponent1new == 255 && significand1new[25:3]!=0) || (exponent2new == 255 && significand2new[25:3]!=0))
begin
flag_nan=1'b1; //nan
flag_zero=1'b0;
flag_infinity=1'b0;
end

else 
begin

flag_infinity=1'b0;
flag_nan=1'b0;
flag_zero=1'b0;


//demormalize the number if exponents of number is zero
if(exponent1new == 0 )
begin
	significand1new = { 2'b00, significand1new[25:3],3'b000};
        
 end	
if(exponent2new == 0 )
begin
	significand2new = { 2'b00, significand2new[25:3],3'b000};
        
end	


op=sign1 ^ sign2;   //it is lead to addition or subtraction of significands			

//small alu
//sel signal used in mux's to get different signal 

if($unsigned(exponent1new)> $unsigned(exponent2new))
begin
	if(exponent1new== 8'd1 & exponent2new==8'd0)
	exponent_diff=8'd0;
	else
	exponent_diff= $unsigned(exponent1new) - $unsigned(exponent2new);
	sel=1'b0;
end

else if ($unsigned(exponent2new)> $unsigned(exponent1new))
begin
	
	if(exponent2new== 8'd1 & exponent1new==8'd0)
	exponent_diff=8'd0;
	else
	exponent_diff= $unsigned(exponent2new) - $unsigned(exponent1new);
	sel=1'b1;
end

else
begin
exponent_diff=8'h00;
if($unsigned(significand2new[25:3]) > $unsigned(significand1new[25:3]))
	sel = 1'b1;
else if($unsigned(significand2new[25:3]) < $unsigned(significand1new[25:3]))
	sel = 1'b0;
else
	//zero flag set when both number is same and sign is different
	if(op==1'b1)
	begin
        sel = 1'b0;
	flag_zero=1'b1;
	end
	else
	begin
	sel = 1'b0;
	flag_zero=1'b0;
        end

end
exponent_abs = exponent_diff;
end
end


//stage 2 sequential
always @(posedge clk)
begin
flag_zero_2<=flag_zero;
flag_infinity_2<=flag_infinity;
flag_nan_2<=flag_nan;
		
sel_2 <=sel;
exponent_abs_2 <= exponent_abs;
op_2 <=op;
		
exponent1_2 <=exponent1new;
exponent2_2 <=exponent2new;

significand1_2 <=significand1new;
significand2_2 <=significand2new;
		
sign1_2 <=sign1;
sign2_2 <=sign2;
out_valid_2 <=out_valid;
end

//2nd combinational

always @(*)
begin
//if any flag is up then we simply pass previous values and didn't do else
//part

if(flag_infinity_2==1'b1 || flag_nan_2==1'b1 ||flag_zero_2==1'b1)
	begin
	signx=sel_2 ? sign2_2:sign1_2;
	exponentx=exponentx;
	significandx=significandx;
	significand_small=significand_small;
	end
else
begin
	//mux
    signx= sel_2 ? sign2_2:sign1_2;//sign of larger exponent
    exponentx= sel_2 ? exponent2_2 : exponent1_2;//larger exponent
    significandx = sel_2? significand2_2 : significand1_2 ;//larger significand
    significand_small = sel_2? significand1_2 : significand2_2 ;//smaller significand
end	 
end



//stage 3 sequential 
always @(posedge clk)
begin
flag_zero_3<=flag_zero_2;
flag_infinity_3<=flag_infinity_2;
flag_nan_3<=flag_nan_2;

exponent_abs_3 <=  exponent_abs_2;
op_3 <=op_2;
significand_small_3 <= significand_small;
exponentx_3 <=exponentx;
signx_3<=signx;
significandx_3 <= significandx;
out_valid_3<=out_valid_2;
end

//3rd combinational
always @(*)
begin
//if any flag is up then we simply pass previous values and didn't do else
//part

if(flag_infinity_3==1'b1 || flag_nan_3==1'b1 ||flag_zero_3==1'b1)
begin
	significand_r_shift=significand_r_shift; 
	significandini=significandini;
	significandfinal = significandfinal;
        exponentfinal = exponentfinal;
	end
//shift right
else 
begin
	significand_small_forsticky={significand_small_3,254'd0}; //concat small significand with other zero
        {significand_r_shift,for_sticky} =significand_small_forsticky>>exponent_abs_3;//shift smaller significand by exponent diff
	significand_r_shift[0]=|for_sticky;//sticky bit
	//significand_r_shift =significand_small_3>>exponent_abs_3;


//big alu
if(op_3 == 0)
	significandini = significandx_3 + significand_r_shift;
else if(op_3 == 1)
	significandini = significandx_3 - significand_r_shift;
	significandini[0]=significand_r_shift[0];
		






	//normalise sum
	 significandini_5new = significandini;
     exponentx_5new = exponentx_3;
	if(op_3 == 0) begin					// In addition, if the sum exceeds a single bit before the decimal, frac [27] will become 1
	 if(significandini_5new[27] == 1) 
		begin
                
                significandini_5new = significandini_5new >> 1;

		exponentx_5new = exponentx_5new + 1;
	        end
	 else 
		begin
		significandini_5new = significandini_5new;
		exponentx_5new = exponentx_5new;
		end 
	         end
	else begin
			/*significand_shift[23]=significandini_5;
			exponent_shift[23]=exponentx_5;
			
			for(i = 23; i >= 0; i = i - 1) begin
			shift_l l1(significand_shift[i],exponent_shift[i],significand_shift[i-1],exponent_shift[i-1]);
          		end
			
			significandfinal = significand_shift[0];
		        exponentfinal = exponent_shift[0];*/
			
			repeat(24) begin
                        if(significandini_5new [26] == 1'b0) begin
			if(exponentx_5new==8'h00)  
			significandini_5new[26]=1'b1;
			else
			begin
			exponentx_5new = exponentx_5new - 8'b1;
			if(exponentx_5new==8'h00)
			significandini_5new [26] = 1'b1;
			else
                        significandini_5new = significandini_5new << 1'b1;
                        end
                        end
                        end
		        
		
		
		
  
	     end
		//for sticky bit

	     if(significandini[0]==1'b1)
                         begin
                         significandfinal = significandini_5new;
                         significandfinal[0] =1'b1;
                         end
                         else
                         significandfinal = significandini_5new;
         
                 exponentfinal = exponentx_5new;
		//rounding to even  it will give best result
	     	//for rounding three bits are used guard ,round , sticky bit
	     	//signicandfinal[2]=guard bit, significand[1]=round
	     	//bit,significand[0]=sticky bit
                       
                        
			if((significandfinal[2]==0))
					significandfinal=significandfinal;
			else if((significandfinal[2]==1 && (significandfinal[1]==1 || significandfinal[0]==1)))
					{exponentfinal,significandfinal[25:3]}={exponentfinal,significandfinal[25:3]} +1'b1;
			else if((significandfinal[2]==1 && significandfinal[1]==0 && significandfinal[0]==0))
					if(significandfinal[3]==0)
						significandfinal=significandfinal;
					else
						{exponentfinal,significandfinal[25:3]}={exponentfinal,significandfinal[25:3]}+1'b1;
                       
		
			
		//expection check
		//infinity
		if (exponentfinal == 255 && significandfinal[25:3]==0) begin
		significandfinale = 25'd0;
		exponentfinale = 8'd255;
		end
		//nan
		else if (exponentfinal == 255 && significandfinal[25:3]!=0) begin
		significandfinale = 25'h0400000;
		exponentfinale = 8'd255;
		end
		//zero
		else if (exponentfinal == 0 && significandfinal[25:3]==0) begin
		significandfinale = 25'd0;
		exponentfinale = 8'd0;
		end
		else begin
		significandfinale = significandfinal;
		exponentfinale = exponentfinal;
		end


end
end







//stage 4 sequential
always @(posedge clk)
begin
out_valid_4<=out_valid_3;

if(flag_infinity_3==1'b1)
begin
	sum<= {signx_3,8'hff,23'd0}; //infinity
end
else if(flag_nan_3==1'b1)
begin
	sum<= 32'h7fc00000; //nan
end
else if(flag_zero_3==1'b1)
begin
	sum <= 32'd0; //zero
end

else

sum <= {signx_3, exponentfinale, significandfinale[25:3]};

end



/*always @(posedge clk)
begin
		
		 
	if(reset) begin
		sum<=32'd0;

		end	
	else begin

			//stage 1
		 significand1 <= { 2'b01, a[22:0],3'b000};
		 significand2 <= { 2'b01, b[22:0],3'b000};

		 exponent1 <= a[30:23];
		 exponent2 <= b[30:23];
		
		 sign1 <= a[31];
		 sign2 <= b[31];

		

			//stage 2
             	flag_zero_2<=flag_zero;//	sum1 <= 32'd0; //zero
	        flag_infinity_2<=flag_infinity;
	        flag_nan_2<=flag_nan;
		
		sel_2 <=sel;
		exponent_abs_2 <= exponent_abs;
		op_2 <=op;
		
		exponent1_2 <=exponent1new;
		exponent2_2 <=exponent2new;

		significand1_2 <=significand1;
		significand2_2 <=significand2;
		
		sign1_2 <=sign1;
		sign2_2 <=sign2;


		//stage 3
		flag_zero_3<=flag_zero_2;//	sum1 <= 32'd0; //zero
	        flag_infinity_3<=flag_infinity_2;
	        flag_nan_3<=flag_nan_2;

		exponent_abs_3 <=  exponent_abs_2;
		op_3 <=op_2;
		significand_small_3 <= significand_small;
		exponentx_3 <=exponentx;
		signx_3<=signx;
		significandx_3 <= significandx;

		// stage 4

		flag_zero_4<=flag_zero_3;//	sum1 <= 32'd0; //zero
	        flag_infinity_4<=flag_infinity_3;
	        flag_nan_4<=flag_nan_3;

		op_4 <=op_3;
		significand_r_shift_4 <= significand_r_shift;
		exponentx_4 <=exponentx_3;
		signx_4<=signx_3;
		significandx_4 <= significandx_3;
 		//stage 5
		flag_zero_5<=flag_zero_4;//	sum1 <= 32'd0; //zero
	        flag_infinity_5<=flag_infinity_4;
	        flag_nan_5<=flag_nan_4;

		op_5<=op_4;
		significandini_5 <= significandini;
		exponentx_5 <=exponentx_4;
		signx_5<=signx_4;
		
		

		
		if(flag_infinity_5==1'b1)
			begin
			sum<= {signx_5,8'hff,23'd0}; //infinity
			end
		else if(flag_nan_5==1'b1)
			begin
			sum<= 32'h7fc00000; //nan
			end
		else if(flag_zero_5==1'b1)
			begin
			sum <= 32'd0; //zero
			end
		else

                sum <= {signx_5, exponentfinale, significandfinale[25:3]};
		
	
   end  
end*/

endmodule