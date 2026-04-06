module datapath (
    input clk,rst,add_sub,LdA,LdAM,LdBM,LdB,LdO,Ldop,ctrl1,SRa,SLa,SRb,SLb,
          Sel_A_MA,Sel_BO,
    input [1:0] ctrl2,
    input [3:0] MUX_sel, 
    input [3:0] data_in,
    output [3:0] data_out,
    output [3:0]OPcode,
    output CarryFlag,OverflowFlag,ZeroFlag,NegativeFlag,LsbB,Bzflag
    );
    
    wire [3:0] bus,Aout,AMout,Bout,BMout,B_eff,
                Sum,OReg_in,And,Or,Xor,Not,shf_out,
                Ain_adder,Bin_adder;
    wire Cout,Ueq,Ugt,Ult,Seq,Sgt,Slt;
    assign bus = data_in;
    
    PIPO_reg    RegA      (bus,LdA,clk,rst,Aout);
    PIPO_reg    RegB      (bus,LdB,clk,rst,Bout);
    shift_reg   MRegA     (clk,rst,SRa,SLa,LdAM,bus,AMout);
    shift_reg   MRegB     (clk,rst,SRb,SLb,LdBM,bus,BMout);
   
    assign Bzflag = ~|BMout;
    assign LsbB = BMout[0];
   
    PIPO_reg    RegOP     (bus,Ldop,clk,rst,OPcode);
    
    uni_shf_reg SRegA     (Aout,clk,rst,ctrl1,ctrl2,shf_out);
    
    assign B_eff = Bout ^ {4{add_sub}};    // step 1 of 2's complement
    
    INmux2to1 INA (Aout,AMout,Sel_A_MA,Ain_adder);
    INmux2to1 INB (B_eff,data_out,Sel_BO,Bin_adder);
    
    bit4_adder  addsub4  (Ain_adder,Bin_adder,add_sub,Sum,Cout);
    Flag_gen    flag_gen (Aout,B_eff,Sum,Cout,
                          CarryFlag,OverflowFlag,
                          ZeroFlag,NegativeFlag);
                          
    assign Ueq = ZeroFlag;                  // Unsigned Comparison
    assign Ult = ~Cout;
    assign Ugt = ((~Ult)&(~ZeroFlag));

    assign Seq = ZeroFlag;                  // Signed Comparison
    assign Slt = (Sum[3]^OverflowFlag);
    assign Sgt = ((~Slt)&(~ZeroFlag));
    
    assign And = Aout & Bout;
    assign Or  = Aout | Bout;
    assign Xor = Aout ^ Bout;
    assign Not = ~Aout;
    
    ever_expnd_MUX MUXop  (Sum,Ueq,Ugt,Ult,Seq,Sgt,Slt,And,Or,Xor,Not,shf_out,MUX_sel,OReg_in);
    
    PIPO_reg    OReg      (OReg_in,LdO,clk,rst,data_out);
    
endmodule 
