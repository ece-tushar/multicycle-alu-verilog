
module ALU_tb;

reg [3:0] data_in;
reg clk,rst,start;
wire [3:0] data_out;
wire done;

wire [3:0] OReg_in = uut.DP.OReg_in;
wire [3:0] RegA = uut.DP.Aout;
//wire [3:0] MulA = uut.DP.AMout;
//wire [3:0] MulB = uut.DP.BMout;
//wire [3:0] RegOP = uut.DP.OPcode;
wire [3:0] RegB = uut.DP.Bout;
//wire [3:0] oprdB = uut.DP.B_eff;
wire [3:0] Sum = uut.DP.Sum;

//wire UEQ = uut.DP.Ueq;
//wire UGT = uut.DP.Ugt;
//wire ULQ = uut.DP.Ult;
//wire SEQ = uut.DP.Seq;
//wire SGT = uut.DP.Sgt;
//wire SLQ = uut.DP.Slt;
//wire BZflag = uut.DP.Bzflag;
//wire lsb = uut.DP.LsbB;
wire [2:0] MUXsel = uut.DP.MUX_sel;
wire [2:0] state = uut.CTRL.state;
wire [2:0] NEXTstate = uut.CTRL.next_state;
wire add_sub = uut.CTRL.add_sub;
TL uut (.data_in(data_in), 
        .clk(clk), .rst(rst), .start(start), 
        .data_out(data_out), .done(done));
        
initial clk = 0;

always #5 clk = !clk;

initial begin
    rst = 1;
    #9;
    rst = 0;
    start = 1;
    #10;
    start = 0;
    data_in = 4'b0100; // regA
    #10;
    data_in = 4'b0011; // regB
    #10;
    data_in = 4'b1111;  // opcode
    #100;
//    ADD  -  0000
//    SUB  -  0001
//    UEQ  -  0010
//    UGT  -  0011
//    ULT  -  0100
//    SEQ  -  0101
//    SGT  -  0110
//    SLT  -  0111
//    AND  -  1000
//    OR   -  1001
//    NOT  -  1010
//    XOR  -  1011 
//    SRL  -  1100
//    SLL  -  1101
//    SRA  -  1110
//    UMUL -  1111
    $finish;
    end
endmodule