module ImmediateExtractor(
    input [31:0] INSTRUCTION,
    input [2:0] SELECTION,
    output reg signed [63:0] VALUE
);
    wire [11:0] IMM_11_0    = INSTRUCTION[31:20];
    wire [19:0] IMM_31_12   = INSTRUCTION[31:12];
    wire [4:0] IMM_4_0      = INSTRUCTION[11:7];
    wire [6:0] IMM_11_5     = INSTRUCTION[31:25];
    wire IMM_11_B           = INSTRUCTION[7];
    wire [3:0] IMM_4_1      = INSTRUCTION[11:8];
    wire [5:0] IMM_10_5     = INSTRUCTION[30:25];
    wire IMM_12             = INSTRUCTION[31];
    wire [7:0] IMM_19_12    = INSTRUCTION[19:12];
    wire IMM_11_J           = INSTRUCTION[20];
    wire [9:0] IMM_10_1     = INSTRUCTION[30:21];
    wire IMM_20             = INSTRUCTION[31];

    // Extend bits and get immediate values of types.    
    wire signed [63:0] Imm_I = { {64{IMM_11_0[11]}}, IMM_11_0 };
    wire signed [63:0] Imm_U = { {64{IMM_31_12[19]}}, IMM_31_12, 12'h000 };
    wire signed [63:0] Imm_B = { {64{IMM_12}}, IMM_11_B, IMM_10_5, IMM_4_1, 1'b0 };
    wire signed [63:0] Imm_S = { {64{IMM_11_5[6]}}, IMM_11_5, IMM_4_0 };
    wire signed [63:0] Imm_UJ = { {64{IMM_20}}, IMM_19_12, IMM_11_J, IMM_10_1, 1'b0 };

    always @(*) begin
        case (SELECTION)
            1: VALUE = Imm_I;
            2: VALUE = Imm_U;
            3: VALUE = Imm_S;
            4: VALUE = Imm_B;
            5: VALUE = Imm_UJ;
            default : VALUE = 0;
        endcase
    end
endmodule
