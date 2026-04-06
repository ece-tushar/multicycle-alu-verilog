module PIPO_reg (                   //  This is the register used for RegA,
    input [3:0] data_in,            //  RegB, and o/p Reg.
    input Ld,clk,rst,
    output reg [3:0] data_out
    );
    
    always @ (posedge clk)
        if (rst)
            data_out <= 4'b0;
        else if (Ld)
            data_out <= data_in;
    
endmodule

module bit4_adder (                // This is the main adder module 
    input [3:0] A, B,
    input Cin,
    output [3:0] Sum,
    output Cout
    );
    
    assign {Cout,Sum} = A + B + Cin;

endmodule
    
module Flag_gen (                           // This is the flag generator module
    input [3:0] A, B, Sum,
    input Cout,
    output CarryFlag, OverflowFlag, ZeroFlag, NegativeFlag
    );
    
    assign CarryFlag     =  Cout;
    assign OverflowFlag  =  (A[3] & B[3] & ~Sum[3]) | 
                            (~A[3] & ~B[3] & Sum[3]);
    assign ZeroFlag      =  ~|Sum;
    assign NegativeFlag  =  Sum[3]; 
endmodule
    
module ever_expnd_MUX(                     // output mux
    input  [3:0] AddSub,
    input        Ueq,Ugt,Ult,Seq,Sgt,Slt,
    input  [3:0] AndOp,OrOp,XorOp,NotOp,
    input  [3:0] shf_out,
    input  [3:0] Sel,
    output reg [3:0] OReg_in
    );
    
    parameter ADDSUB = 4'b0000,
              UEQ    = 4'b0001,
              UGT    = 4'b0010,
              ULT    = 4'b0011,
              SEQ    = 4'b0100,
              SGT    = 4'b0101,
              SLT    = 4'b0110,
              AND    = 4'b0111,
              OR     = 4'b1000,
              NOT    = 4'b1001,
              XOR    = 4'b1010,
              SRLSLLSRA = 4'b1011;
              //UMUL      = 4'b1100;
//              SLL    = 4'b1100;
              //XOR    = 4'b1010,
              //XOR    = 4'b1010;
              
    always @ (*)
    case (Sel)
        ADDSUB    : OReg_in = AddSub;
        UEQ       : OReg_in = {3'b000,Ueq};
        UGT       : OReg_in = {3'b000,Ugt};
        ULT       : OReg_in = {3'b000,Ult};
        SEQ       : OReg_in = {3'b000,Seq};
        SGT       : OReg_in = {3'b000,Sgt};
        SLT       : OReg_in = {3'b000,Slt};
        AND       : OReg_in = AndOp;
        OR        : OReg_in = OrOp;
        NOT       : OReg_in = NotOp;
        XOR       : OReg_in = XorOp;
        SRLSLLSRA : OReg_in = shf_out;
        //UMUL      : OReg_in = AddSub;
        
        //SLL    : OReg_in = shf_out;
        default: OReg_in = 4'b0000;
    endcase
    
endmodule
    
module d_ff (
    input clk,rst,d,
    output reg q
    );
    
    always @ (posedge clk)
        if(rst)
            q <= 1'b0;
        else
            q <= d;
endmodule
 
module mux2to1(
    input  data_in1,data_in2,
    input  Sel,
    output reg data_out
    );
    
              
    always @ (*)
    case (Sel)
        1'b0 : data_out = data_in1;
        1'b1 : data_out = data_in2;
    endcase
    
endmodule  
 
module INmux2to1(
    input  [3:0] data_in1,data_in2,
    input  Sel,
    output reg [3:0] data_out
    );
    
              
    always @ (*)
    case (Sel)
        1'b0 : data_out = data_in1;
        1'b1 : data_out = data_in2;
    endcase
    
endmodule   
    
module mux4to1(
    input  data_in1,data_in2,data_in3,data_in4,
    input  [1:0]Sel,
    output reg data_out
    );
    
              
    always @ (*)
    case (Sel)
        2'b00 : data_out = data_in1;
        2'b01 : data_out = data_in2;
        2'b10 : data_out = data_in3;
        2'b11 : data_out = data_in4;
    endcase
    
endmodule
    
module uni_shf_reg(          // Universal shift register for shifting
    input [3:0] data_in,
    input clk, rst, ctrl1,
    input [1:0] ctrl2,
    output [3:0]data_out 
    );
    
//    ctrl2:
//    00 : SHIFT RIGHT
//    01 : HOLD
//    10 : SHIFT LEFT
//    11 : LOAD
    
//    ctrl1:
//    0 : SRL
//    1 : SRA
    
    wire [3:0]t_in,t_out;
    wire m21out;
    
    mux2to1 M2_1 (1'b0,t_out[3],ctrl1,m21out);
    
    mux4to1 M4_3 (m21out,t_out[3],t_out[2],data_in[3],ctrl2,t_in[3]);    
    mux4to1 M4_2 (t_out[3],t_out[2],t_out[1],data_in[2],ctrl2,t_in[2]);    
    mux4to1 M4_1 (t_out[2],t_out[1],t_out[0],data_in[1],ctrl2,t_in[1]);    
    mux4to1 M4_0 (t_out[1],t_out[0],1'b0,data_in[0],ctrl2,t_in[0]);
    
    d_ff D3 (clk,rst,t_in[3],t_out[3]);
    d_ff D2 (clk,rst,t_in[2],t_out[2]);
    d_ff D1 (clk,rst,t_in[1],t_out[1]);
    d_ff D0 (clk,rst,t_in[0],t_out[0]);
      
    assign data_out = t_out;
        
endmodule
    
 module shift_reg (          // shift reg for multiplication
	input clk, rst,sr,sl,Ld,
	input [3:0] data_in,
	output reg [3:0] data_out
	);

	always @ (posedge clk)
		if (rst)
			data_out <= 4'b0;
	
	   else if (Ld)
            data_out <= data_in;

		else if (sr)
			data_out <= data_out >> 1 ;

	 	else if (sl)
			data_out <= data_out << 1;
	    
	    else
            data_out <= data_out;

		
endmodule   
    
    