`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2022 12:55:33 PM
// Design Name: 
// Module Name: fp_mult
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

module fp_mult(input[31:0]a,b,output reg [31:0]z,input clk,rst);
reg[2:0]state;
reg [23:0]m_a,m_b,m_z;
reg[9:0]e_a,e_b,e_z;
reg s_a,s_b,s_z;
reg[49:0]mult;
parameter s0=3'b001,s1=3'b010,s2=3'b011,s3=3'b100,s4=3'b101,s5=3'b110,s6=3'b111;
reg round,gaurd,sticky;

always@(posedge clk or rst)
begin
    if(rst)
        state<=0;
    else
        state<=state+1;
end
always @(state)
    begin
        case(state)
            s0:
                begin
                    m_a<=a[22:0];
                    m_b<=b[22:0];
                    s_a<=a[31:31];
                    s_b<=b[31:31];
                    e_a<=a[30:23]-127;
                    e_b<=b[30:23]-127;
                    end
                    
            s1:
                begin
                    if((e_a==128 && m_a!=0)||(e_b==128 && m_b!=0))//NOT A NUMBER
                        begin
                            z[31]<=1;
                            z[31:23]<=255;
                            z[22]<=1;
                            z[21:0]<=0;
                        end
                        else if(e_a==128)
                            begin
                            z[31]<=s_a^s_b;
                            z[30:23]<=255;
                            
                            z[22:0]<=0;
                            if(($signed(e_b)==-127) &&(m_b==0))
                                begin
                                    z[31]<=1;
                                    z[30:23]<=255;
                                    z[22]<=1;
                                    z[21:0]<=0;
                                    end
                              end
                         else if(e_b==128)
                            begin
                                z[31]<=s_a^s_b;
                                z[30:23]<=255;
                                                        
                                z[22:0]<=0;
                                if(($signed(e_a)==-127) &&(m_a==0))
                                    begin
                                        z[31]<=1;
                                        z[30:23]<=255;
                                        z[22]<=1;
                                        z[21:0]<=0;
                                     end
                              end
                        else if(($signed(e_a)==-127)&&(m_a==0))
                            begin
                                z[31]<=s_a^s_b;
                                z[30:23]<=0;
                                z[22:0]<=0;
                              end   
                        else if(($signed(e_b)==-127)&&(m_b==0))
                            begin
                                 z[31]<=s_a^s_b;
                                 z[30:23]<=0;
                                 z[22:0]<=0;
                            end    
                        else 
                            begin
                                if($signed(e_a)==-127)
                                    e_a<=-126;
                                else
                                    m_a[23]<=1;
                                if($signed(e_a)==-127)
                                      e_b<=-126;
                                else
                                      m_b[23]<=1;
                             end
                        end
                        
          
               s2:
                begin
                    if(~m_a[23])
                        begin
                            m_a<=m_a<<1;
                            e_a<=e_a-1;
                        end
                     if(~m_b[23])
                         begin
                              m_b<=m_b<<1;
                              e_b<=e_b-1;
                          end    
                            
                  end
                  s3:
                    begin
                        s_z<=s_a^s_b;
                        e_z<=e_a+e_b+1;
                        mult<=m_a*m_b*4;
                    end     
                 s4:
                    begin
                        m_z<=mult[49:26];
                        gaurd<=mult[25];
                        round<=mult[24];
                        sticky<=(mult[23:0]!=0);
                     end
                s5:
                    begin
                        if($signed(e_z)<-126)
                            begin
                                e_z<=e_z+(-126 -$signed(e_z));
                                m_z<=m_z>>(-126 -$signed(e_z));
                                gaurd<=m_z[0];
                                round<=gaurd;
                                sticky<=sticky|round;
                            end
                         else if(m_z[23]==0)
                            begin
                                e_z<=e_z-1;
                                m_z<=m_z<<1;
                                gaurd<=round;
                                round<=0;
                              end
                         else if(gaurd && (round | sticky |m_z[0]))
                            begin
                                m_z<=m_z+1;
                                if(m_z==24'hfffff)
                                    e_z<=e_z+1;
                                 end
                       end
                 s6:
                    begin
                        z[22:0]<=m_z[22:0];
                        z[30:23]<=e_z[7:0]+127;
                        z[31]<=s_z;
                        if($signed(e_z)==-126 && m_z==0)
                            z[30:23]<=0;
                       if($signed(e_z)>127)
                        begin
                            z[22:0]<=0;
                            z[30:23]<=255;
                            z[31]<=s_z;
                            end
                     end   
                 endcase
                 end                           
 endmodule
