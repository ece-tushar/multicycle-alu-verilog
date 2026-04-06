module TL (
    input [3:0] data_in,
    input clk,rst,start,
    output [3:0] data_out,
    output done
    );
    
    wire rst_dp,add_sub,LdA,LdB,LdO,Ldop,ctrl1,Sel_A_MA,Sel_BO,LsbB,
         SRa,SLa,SRb,SLb,Bzflag,LdAM,LdBM;
    wire [1:0]ctrl2;
    wire [3:0]OPcode;
    wire [3:0]MUX_sel;
    wire CarryFlag,OverflowFlag,
         ZeroFlag,NegativeFlag;
    
    
    datapath DP (clk,rst_dp,
                add_sub,LdA,LdAM,LdB,LdBM,LdO,Ldop,ctrl1,SRa,SLa,SRb,SLb,Sel_A_MA,Sel_BO,ctrl2,MUX_sel,
                data_in,data_out,
                OPcode,CarryFlag,OverflowFlag,
                ZeroFlag,NegativeFlag,LsbB,Bzflag);
                
    controller CTRL (clk,rst,start,Bzflag,LsbB,
                     OPcode,LdA,LdB,Ldop,
                     LdO,add_sub,done,
                     rst_dp,ctrl1,Sel_A_MA,Sel_BO,
                     SRa,SLa,SRb,SLb,LdAM,LdBM,ctrl2,MUX_sel);
                                
endmodule 
