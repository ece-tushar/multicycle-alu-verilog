module controller (
    input clk,rst_ctrl,start,Bzflag,LsbB,
    input [3:0] OPcode,
    output reg LdA,LdB,Ldop,LdO,add_sub,done,rst_dp,ctrl1,
               Sel_A_MA,Sel_BO,SRa,SLa,SRb,SLb,LdAM,LdBM,
    output reg [1:0] ctrl2,
    output reg [3:0] MUX_sel
    );
    
    reg [3:0] state, next_state;  
    
    parameter S0     = 4'b0000,   // resets reg A,B,C waits for start
              S1     = 4'b0001,   // Loads A
              S2     = 4'b0010,   // Loads B
              S3     = 4'b0011,   // Loads Opcode 
              S_hold = 4'b0111,   // The OPcode is stored here (waiting for clk edge) 
              S4_1   = 4'b0100,   // EXCUTION 
              S5     = 4'b0101;   // write back and termination
            //  S6     = 4'b0101;
              
    parameter ADD  =  4'b0000,
              SUB  =  4'b0001,
              UEQ  =  4'b0010,
              UGT  =  4'b0011,
              ULT  =  4'b0100,
              SEQ  =  4'b0101,
              SGT  =  4'b0110,
              SLT  =  4'b0111,
              AND  =  4'b1000,
              OR   =  4'b1001,
              NOT  =  4'b1010,
              XOR  =  4'b1011,
              SRL  =  4'b1100,
              SLL  =  4'b1101,
              SRA  =  4'b1110,
              UMUL =  4'b1111;

    always @ (posedge clk or posedge rst_ctrl)
          state <= (rst_ctrl) ? S0 : next_state; 
          
    always @ (*)
        case (state)
            S0 : if (start)
                    next_state = S1;
                 else 
                    next_state = S0;
            S1      : next_state = S2;
            S2      : next_state = S3;
            S3      : next_state = S_hold;
            S_hold  : next_state = S4_1;
            S4_1    : case (OPcode)
                        UMUL : if (~Bzflag)
                                next_state <= S4_1;
                               else
                                 next_state <= S5;
                         default : next_state = S5;
                      endcase
                                
            S5      :   next_state = S5;
            default : next_state = S0;
        endcase
        
    always @(*) begin
            LdA = 0; LdB = 0; Ldop = 0; LdO = 0;
            add_sub = 0; done = 0; rst_dp = 0;
            MUX_sel = 0;ctrl1 = 0; ctrl2 = 2'b01;
            LdAM = 0; LdBM = 0;
            Sel_A_MA = 0; Sel_BO = 0;SRa = 0;SLb = 0;
            SLa = 0;SRb = 0;
        
            case (state)
                S0: rst_dp = 1;
                S1: begin LdA = 1; LdAM = 1; end
                S2: begin LdB = 1; LdBM = 1; end
                S3: Ldop = 1;
                S_hold : case (OPcode)
                            SRL : ctrl2 = 2'b11;
                            SLL : ctrl2 = 2'b11;
                            SRA : ctrl2 = 2'b11;
                            default : ctrl2 = 2'b01;
                         endcase
                S4_1: begin
                        case (OPcode)
                            ADD : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 0; MUX_sel = 4'b0000; end
                            SUB : begin add_sub = 1; MUX_sel = 4'b0000; end
                            
                            UEQ : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 1; MUX_sel = 4'b0001; end
                            UGT : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 1; MUX_sel = 4'b0010; end
                            ULT : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 1; MUX_sel = 4'b0011; end
                            SEQ : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 1; MUX_sel = 4'b0100; end
                            SGT : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 1; MUX_sel = 4'b0101; end
                            SLT : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 1; MUX_sel = 4'b0110; end
                            
                            AND : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 0; MUX_sel = 4'b0111; end
                            OR  : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 0; MUX_sel = 4'b1000; end
                            NOT : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 0; MUX_sel = 4'b1001; end
                            XOR : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 0; MUX_sel = 4'b1010; end
                            
                            SRL : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 0; ctrl1 = 1'b0; ctrl2 = 2'b00; MUX_sel = 4'b1011; end
                            SLL : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 0; ctrl2 = 2'b10; MUX_sel = 4'b1011; end
                            SRA : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 0; ctrl1 = 1'b1; ctrl2 = 2'b00; MUX_sel = 4'b1011; end
                           UMUL : begin Sel_A_MA = 1; Sel_BO = 1; add_sub = 0; MUX_sel = 4'b0000;
                                         
                                        if (LsbB)
                                            begin SLa = 1;SRb = 1;LdO = 1; end
                                        else 
                                             begin SLa = 1; SRb = 1; LdO = 0; end
                                         end
                            
                            default: begin
                                Sel_A_MA = 0; Sel_BO = 0;
                                add_sub = 0;
                                MUX_sel = 4'b0000;
                            end
                        endcase
                    end
                S5: begin
                        done = 1;
                        case (OPcode)
                            ADD : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 0; MUX_sel = 4'b0000; LdO = 1; end
                            SUB : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 1; MUX_sel = 4'b0000; LdO = 1; end
                            
                            UEQ : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 1; MUX_sel = 4'b0001; LdO = 1; end
                            UGT : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 1; MUX_sel = 4'b0010; LdO = 1; end
                            ULT : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 1; MUX_sel = 4'b0011; LdO = 1; end
                            SEQ : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 1; MUX_sel = 4'b0100; LdO = 1; end
                            SGT : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 1; MUX_sel = 4'b0101; LdO = 1; end
                            SLT : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 1; MUX_sel = 4'b0110; LdO = 1; end
                            
                            AND : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 0; MUX_sel = 4'b0111; LdO = 1; end
                            OR  : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 0; MUX_sel = 4'b1000; LdO = 1; end
                            NOT : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 0; MUX_sel = 4'b1001; LdO = 1; end
                            XOR : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 0; MUX_sel = 4'b1010; LdO = 1; end
                            
                            SRL : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 0; ctrl1 = 1'b0; ctrl2 = 2'b01; MUX_sel = 4'b1011; LdO = 1; end
                            SLL : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 0; ctrl2 = 2'b01; MUX_sel = 4'b1011; LdO = 1; end
                            SRA : begin Sel_A_MA = 0; Sel_BO = 0; add_sub = 0; ctrl1 = 1'b1; ctrl2 = 2'b01; MUX_sel = 4'b1011; LdO = 1; end
                           UMUL : begin Sel_A_MA = 1; Sel_BO = 1;SRa = 0;SLb = 0;
                                        SLa = 0;SRb = 0; add_sub = 0; MUX_sel = 4'b0000; LdO = 0; end
                            default: begin
                                 Sel_A_MA = 0; Sel_BO = 0;
                                add_sub = 0;
                                MUX_sel = 4'b0000;
                            end
                        endcase
                    end
            endcase
        end
        
endmodule 