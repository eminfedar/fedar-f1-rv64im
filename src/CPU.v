`include "ALU.v"
`include "RegFile.v"
`include "ImmediateExtractor.v"
`include "Encoders.v"

module CPU (
    input [63:0] RAM_READ_DATA,
    input [31:0] INSTRUCTION,
    input CLK,

    output [9:0] RAM_ADDR,          // 10-bit Size RAM
    output reg [63:0] RAM_WRITE_DATA,
    output RAM_WRITE_ENABLE,
    output [9:0] INSTRUCTION_ADDR   // 10-bit Size ROM
);
    // CONSTANTS:
    // -- OPCODE DEFINES:
    integer OP_R_TYPE           = 7'h33;
    integer OP_R_TYPE_64        = 7'h3B;
    integer OP_I_TYPE_LOAD      = 7'h03;
    integer OP_I_TYPE_OTHER     = 7'h13;
    integer OP_I_TYPE_64        = 7'h1B;
    integer OP_I_TYPE_JUMP      = 7'h6F;
    integer OP_S_TYPE           = 7'h23;
    integer OP_B_TYPE           = 7'h63;
    integer OP_U_TYPE_LOAD      = 7'h37;
    integer OP_U_TYPE_JUMP      = 7'h67;
    integer OP_U_TYPE_AUIPC     = 7'h17;
    // -- PIPELINE HAZARD INSTRUCTION TYPE DEFINES:
    integer TYPE_REGISTER       = 0;
    integer TYPE_LOAD           = 1;
    integer TYPE_STORE          = 2;
    integer TYPE_IMMEDIATE      = 3;
    integer TYPE_UPPERIMMEDIATE = 4;
    integer TYPE_BRANCH         = 5;
    // -- PIPELINE STAGES
    integer DECODE      = 0;
    integer EXECUTE     = 1;
    integer MEMORY      = 2;
    integer WRITEBACK   = 3;


    // WIRE DEFINITIONS:
    wire [6:0] OPCODE   = INSTRUCTION_EXECUTE_3[6:0];
    wire [4:0] RD       = INSTRUCTION_WRITEBACK_5[11:7];
    wire [2:0] FUNCT3   = INSTRUCTION_EXECUTE_3[14:12];
    wire [4:0] R1       = INSTRUCTION_EXECUTE_3[19:15];
    wire [4:0] R2       = INSTRUCTION_EXECUTE_3[24:20];
    wire [6:0] FUNCT7   = INSTRUCTION_EXECUTE_3[31:25];

    wire R_TYPE         = OPCODE == OP_R_TYPE;
    wire R_TYPE_64      = OPCODE == OP_R_TYPE_64;
    wire I_TYPE_LOAD    = OPCODE == OP_I_TYPE_LOAD;
    wire I_TYPE_OTHER   = OPCODE == OP_I_TYPE_OTHER;
    wire I_TYPE_64      = OPCODE == OP_I_TYPE_64;
    wire I_TYPE_JUMP    = OPCODE == OP_I_TYPE_JUMP;
    wire I_TYPE         = I_TYPE_JUMP || I_TYPE_LOAD || I_TYPE_OTHER || I_TYPE_64;
    wire S_TYPE         = OPCODE == OP_S_TYPE;
    wire B_TYPE         = OPCODE == OP_B_TYPE;
    wire U_TYPE_LOAD    = OPCODE == OP_U_TYPE_LOAD;
    wire U_TYPE_JUMP    = OPCODE == OP_U_TYPE_JUMP;
    wire U_TYPE_AUIPC   = OPCODE == OP_U_TYPE_AUIPC;
    wire U_TYPE         = U_TYPE_JUMP || U_TYPE_LOAD || U_TYPE_AUIPC;

    // -- Register-Register Types (R-Type)    
    // ---- RV32I:
    wire R_add      = R_TYPE && FUNCT3 == 3'h0 && FUNCT7 == 7'h00;
    wire R_sub      = R_TYPE && FUNCT3 == 3'h0 && FUNCT7 == 7'h20;
    wire R_sll      = R_TYPE && FUNCT3 == 3'h1 && FUNCT7 == 7'h00;
    wire R_slt      = R_TYPE && FUNCT3 == 3'h2 && FUNCT7 == 7'h00;
    wire R_sltu     = R_TYPE && FUNCT3 == 3'h3 && FUNCT7 == 7'h00;
    wire R_xor      = R_TYPE && FUNCT3 == 3'h4 && FUNCT7 == 7'h00;
    wire R_srl      = R_TYPE && FUNCT3 == 3'h5 && FUNCT7 == 7'h00;
    wire R_sra      = R_TYPE && FUNCT3 == 3'h5 && FUNCT7 == 7'h20;
    wire R_or       = R_TYPE && FUNCT3 == 3'h6 && FUNCT7 == 7'h00;
    wire R_and      = R_TYPE && FUNCT3 == 3'h7 && FUNCT7 == 7'h00;
    // ---- RV32M:
    wire R_mul      = R_TYPE && FUNCT3 == 3'h0 && FUNCT7 == 7'h01;
    wire R_mulh     = R_TYPE && FUNCT3 == 3'h1 && FUNCT7 == 7'h01;
    wire R_rem      = R_TYPE && FUNCT3 == 3'h6 && FUNCT7 == 7'h01;
    wire R_div      = R_TYPE && FUNCT3 == 3'h4 && FUNCT7 == 7'h01;
    // ---- RV64I:
    wire R_addw     = R_TYPE_64 && FUNCT3 == 3'h0 && FUNCT7 == 7'h00;
    wire R_subw     = R_TYPE_64 && FUNCT3 == 3'h0 && FUNCT7 == 7'h20;
    wire R_sllw     = R_TYPE_64 && FUNCT3 == 3'h1 && FUNCT7 == 7'h00;
    wire R_srlw     = R_TYPE_64 && FUNCT3 == 3'h5 && FUNCT7 == 7'h00;
    wire R_sraw     = R_TYPE_64 && FUNCT3 == 3'h5 && FUNCT7 == 7'h20;
    // ---- RV64M:
    wire R_mulw     = R_TYPE_64 && FUNCT3 == 3'h0 && FUNCT7 == 7'h01;
    wire R_divw     = R_TYPE_64 && FUNCT3 == 3'h4 && FUNCT7 == 7'h01;
    wire R_remw     = R_TYPE_64 && FUNCT3 == 3'h6 && FUNCT7 == 7'h01;
    

    // -- Immediate Types (I-Type)
    // ---- RV32I:
    wire I_addi     = I_TYPE_OTHER && FUNCT3 == 3'h0;
    wire I_slli     = I_TYPE_OTHER && FUNCT3 == 3'h1 && FUNCT7 == 7'h00;
    wire I_slti     = I_TYPE_OTHER && FUNCT3 == 3'h2;
    wire I_sltiu    = I_TYPE_OTHER && FUNCT3 == 3'h3;
    wire I_xori     = I_TYPE_OTHER && FUNCT3 == 3'h4;
    wire I_srli     = I_TYPE_OTHER && FUNCT3 == 3'h5 && FUNCT7 == 7'h00;
    wire I_srai     = I_TYPE_OTHER && FUNCT3 == 3'h5 && FUNCT7 == 7'h10;
    wire I_ori      = I_TYPE_OTHER && FUNCT3 == 3'h6;
    wire I_andi     = I_TYPE_OTHER && FUNCT3 == 3'h7;
    // ---- RV64I:
    wire I_addiw    = I_TYPE_64 && FUNCT3 == 3'h0;
    wire I_slliw    = I_TYPE_64 && FUNCT3 == 3'h1 && FUNCT7 == 7'h00;
    wire I_srliw    = I_TYPE_64 && FUNCT3 == 3'h5 && FUNCT7 == 7'h00;
    wire I_sraiw    = I_TYPE_64 && FUNCT3 == 3'h5 && FUNCT7 == 7'h20;
    // ---- Load
    wire I_lb       = INSTRUCTION_MEMORY_4[6:0] == OP_I_TYPE_LOAD && INSTRUCTION_MEMORY_4[14:12] == 3'h0;
    wire I_lh       = INSTRUCTION_MEMORY_4[6:0] == OP_I_TYPE_LOAD && INSTRUCTION_MEMORY_4[14:12] == 3'h1;
    wire I_lw       = INSTRUCTION_MEMORY_4[6:0] == OP_I_TYPE_LOAD && INSTRUCTION_MEMORY_4[14:12] == 3'h2;
    wire I_ld       = INSTRUCTION_MEMORY_4[6:0] == OP_I_TYPE_LOAD && INSTRUCTION_MEMORY_4[14:12] == 3'h3;
    // ---- Jump
    wire I_jalr     = I_TYPE_JUMP;


    // -- Upper Immediate Types (U-Type)
    wire U_lui      = U_TYPE_LOAD;
    wire U_auipc    = U_TYPE_AUIPC;
    wire U_jal      = U_TYPE_JUMP;


    // -- Store Types (S-Type)
    wire S_sb       = INSTRUCTION_MEMORY_4[6:0] == OP_S_TYPE && INSTRUCTION_MEMORY_4[14:12] == 3'h0;
    wire S_sh       = INSTRUCTION_MEMORY_4[6:0] == OP_S_TYPE && INSTRUCTION_MEMORY_4[14:12] == 3'h1;
    wire S_sw       = INSTRUCTION_MEMORY_4[6:0] == OP_S_TYPE && INSTRUCTION_MEMORY_4[14:12] == 3'h2;
    wire S_sd       = INSTRUCTION_MEMORY_4[6:0] == OP_S_TYPE && INSTRUCTION_MEMORY_4[14:12] == 3'h3;


    // -- Branch Types (B-Type)
    wire B_beq      = B_TYPE && FUNCT3 == 0;
    wire B_bne      = B_TYPE && FUNCT3 == 1;
    wire B_blt      = B_TYPE && FUNCT3 == 4;
    wire B_bge      = B_TYPE && FUNCT3 == 5;
    wire B_bltu     = B_TYPE && FUNCT3 == 6;
    wire B_bgeu     = B_TYPE && FUNCT3 == 7;

    // -- PC Get Data From ALU Switch
    wire signed [63:0] R1_DATA =    DATA_DEPENDENCY_HAZARD_R1 ? ALU_OUT_MEMORY_4 :
                                    DATA_DEPENDENCY_HAZARD_R1_WRITEBACK ?
                                        (REG_WRITEBACK_SELECTION == 3 ? RAM_READ_DATA_WRITEBACK_5 : REG_WRITE_DATA_WRITEBACK_5)
                                        : R1_DATA_EXECUTE_3;
    wire signed [63:0] R2_DATA =    DATA_DEPENDENCY_HAZARD_R2 ? ALU_OUT_MEMORY_4 :
                                    DATA_DEPENDENCY_HAZARD_R2_WRITEBACK ?
                                        (REG_WRITEBACK_SELECTION == 3 ? RAM_READ_DATA_WRITEBACK_5 : REG_WRITE_DATA_WRITEBACK_5)
                                        : R2_DATA_EXECUTE_3;
    
    wire [63:0] R1_DATA_UNSIGNED = R1_DATA;
    wire [63:0] R2_DATA_UNSIGNED = R2_DATA;

    wire PC_ALU_SEL =   (B_beq && R1_DATA == R2_DATA)
                        || (B_bne && R1_DATA != R2_DATA)
                        || (B_blt && R1_DATA <  R2_DATA)
                        || (B_bge && R1_DATA >= R2_DATA)
                        || (B_bltu && R1_DATA_UNSIGNED <  R2_DATA_UNSIGNED)
                        || (B_bgeu && R1_DATA_UNSIGNED >= R2_DATA_UNSIGNED)
                        || I_jalr
                        || U_jal
                        ;
    
    // -- RAM Read & Write Enable Pins
    assign RAM_WRITE_ENABLE     = INSTRUCTION_MEMORY_4[6:0] == OP_S_TYPE;
    assign RAM_ADDR             = ALU_OUT_MEMORY_4[9:0];


    // -- PIPELINING HAZARDS
    // ---- DATA HAZARD CONTROL REGISTERS
    reg [4:0] R1_PIPELINE[3:0];        // R1 Register of the current stage.
    reg [4:0] R2_PIPELINE[3:0];        // R2 Register of the current stage.
    reg [4:0] RD_PIPELINE[3:0];        // RD Register of the current stage.
    reg [2:0] TYPE_PIPELINE[3:0];      // Instruction Types of the current stage. [R-Type=0, Load=1, Store=2, Immediate or UpperImmediate=3, Branch=4]

    // If R1 depends on the previous RD (or R2 if STORE)
    wire DATA_DEPENDENCY_HAZARD_R1 =
                        R1_PIPELINE[EXECUTE] != 0
                    &&  TYPE_PIPELINE[EXECUTE] != TYPE_UPPERIMMEDIATE
                    &&  R1_PIPELINE[EXECUTE] == RD_PIPELINE[MEMORY];
    // If R2 depends on the previous RD (or R2 if STORE)
    wire DATA_DEPENDENCY_HAZARD_R2 =
                        R2_PIPELINE[EXECUTE] != 0
                    &&  TYPE_PIPELINE[EXECUTE] != TYPE_UPPERIMMEDIATE
                    &&  TYPE_PIPELINE[EXECUTE] != TYPE_IMMEDIATE
                    &&  R2_PIPELINE[EXECUTE] == RD_PIPELINE[MEMORY];
    
    // If R1 depends on the 5th stage RD
    wire DATA_DEPENDENCY_HAZARD_R1_WRITEBACK =
                        R1_PIPELINE[EXECUTE] != 0
                    &&  TYPE_PIPELINE[EXECUTE] != TYPE_UPPERIMMEDIATE
                    &&  R1_PIPELINE[EXECUTE] == RD_PIPELINE[WRITEBACK];
    // If R2 depends on the 5th stage RD
    wire DATA_DEPENDENCY_HAZARD_R2_WRITEBACK =
                        R2_PIPELINE[EXECUTE] != 0
                    &&  TYPE_PIPELINE[EXECUTE] != TYPE_UPPERIMMEDIATE
                    &&  TYPE_PIPELINE[EXECUTE] != TYPE_IMMEDIATE
                    &&  R2_PIPELINE[EXECUTE] == RD_PIPELINE[WRITEBACK];
    

    // If the next instruction depends on a Load instruction before, stall one clock.
    wire LOAD_STALL =
                        TYPE_PIPELINE[EXECUTE] == TYPE_LOAD
                    &&  (
                            (
                                TYPE_PIPELINE[DECODE] != TYPE_UPPERIMMEDIATE
                            &&  TYPE_PIPELINE[DECODE] != TYPE_IMMEDIATE
                            &&  (
                                    (R1_PIPELINE[DECODE] != 0 && R1_PIPELINE[DECODE] == RD_PIPELINE[EXECUTE])
                                ||  (R2_PIPELINE[DECODE] != 0 && R2_PIPELINE[DECODE] == RD_PIPELINE[EXECUTE])
                                )
                            )
                        ||  (   
                                TYPE_PIPELINE[DECODE] == TYPE_IMMEDIATE
                            &&  R1_PIPELINE[DECODE] != 0
                            &&  R1_PIPELINE[DECODE] == RD_PIPELINE[EXECUTE]
                            )
                        );
    
    // If there is a branch instruction, stall for 2 clocks.
    wire CONTROL_HAZARD_STALL = INSTRUCTION_DECODE_2[6:0] == OP_B_TYPE || INSTRUCTION_EXECUTE_3[6:0] == OP_B_TYPE;
    



    // COMPONENT DEFINITIONS (IMMEDIATE EXTRACTOR, ALU, REGFILE):
    // -- Immediate Extractor
    wire [63:0] IMMEDIATE_VALUE;
    wire [2:0] IMMEDIATE_SELECTION;
    wire [7:0] immediateSelectionInputs;

    assign immediateSelectionInputs[0] = 0;
    assign immediateSelectionInputs[1] = I_TYPE;
    assign immediateSelectionInputs[2] = U_TYPE_LOAD || U_TYPE_AUIPC;
    assign immediateSelectionInputs[3] = S_TYPE;
    assign immediateSelectionInputs[4] = B_TYPE;
    assign immediateSelectionInputs[5] = U_TYPE_JUMP;
    assign immediateSelectionInputs[6] = 0;
    assign immediateSelectionInputs[7] = 0;
    Encoder_8 immediateSelectionEncoder(immediateSelectionInputs, IMMEDIATE_SELECTION);
    
    ImmediateExtractor immediateExtractor(INSTRUCTION_EXECUTE_3, IMMEDIATE_SELECTION, IMMEDIATE_VALUE);




    // -- ALU Operation Selection
    wire [15:0] aluOpEncoderInputs;
    wire [3:0] ALU_OP;
    
    assign aluOpEncoderInputs[0] = R_add || R_addw || I_addi || I_addiw;
    assign aluOpEncoderInputs[1] = R_sub || R_subw;
    assign aluOpEncoderInputs[2] = R_and || I_andi;
    assign aluOpEncoderInputs[3] = R_or || I_ori;
    assign aluOpEncoderInputs[4] = R_xor || I_xori;
    assign aluOpEncoderInputs[5] = R_sll || R_sllw || I_slli || I_slliw;
    assign aluOpEncoderInputs[6] = R_srl || R_srlw || I_srli || I_srliw;
    assign aluOpEncoderInputs[7] = R_sra || R_sraw || I_srai || I_sraiw;
    assign aluOpEncoderInputs[8] = R_mul || R_mulw;
    assign aluOpEncoderInputs[9] = R_mulh;
    assign aluOpEncoderInputs[10] = R_div || R_divw;
    assign aluOpEncoderInputs[11] = R_rem || R_remw;
    assign aluOpEncoderInputs[12] = R_slt || I_slti;
    assign aluOpEncoderInputs[13] = R_sltu || I_sltiu;
    assign aluOpEncoderInputs[14] = 0;
    assign aluOpEncoderInputs[15] = 0;
    Encoder_16 aluOpEncoder(aluOpEncoderInputs, ALU_OP);

    // -- ALU Input Selection Encoders
    wire [3:0] aluX1SelectionInputs;
    wire [3:0] aluX2SelectionInputs;
    wire [1:0] ALU_X1_SEL;
    wire [1:0] ALU_X2_SEL;
    
    assign aluX1SelectionInputs[0] = 1;
    assign aluX1SelectionInputs[1] = B_TYPE || U_TYPE_JUMP || U_TYPE_AUIPC || I_TYPE_JUMP;
    assign aluX1SelectionInputs[2] = U_TYPE_LOAD;
    assign aluX1SelectionInputs[3] = 0; //DATA_DEPENDENCY_HAZARD_R1_WRITEBACK && B_TYPE == 0 && I_TYPE_JUMP == 0;
    //assign aluX1SelectionInputs[4] = 0; //DATA_DEPENDENCY_HAZARD_R1 && B_TYPE == 0 && I_TYPE_JUMP == 0;
    //assign aluX1SelectionInputs[5] = 0;
    //assign aluX1SelectionInputs[6] = 0;
    //assign aluX1SelectionInputs[7] = 0;

    assign aluX2SelectionInputs[0] = 1;
    assign aluX2SelectionInputs[1] = S_TYPE || I_TYPE || B_TYPE || U_TYPE;    
    assign aluX2SelectionInputs[2] = 0; //DATA_DEPENDENCY_HAZARD_R2_WRITEBACK && (S_TYPE || B_TYPE || U_TYPE) == 0;
    assign aluX2SelectionInputs[3] = 0; //DATA_DEPENDENCY_HAZARD_R2 && (S_TYPE || B_TYPE || U_TYPE) == 0;
    Encoder_4 aluX1SelectionEncoder(aluX1SelectionInputs, ALU_X1_SEL);
    Encoder_4 aluX2SelectionEncoder(aluX2SelectionInputs, ALU_X2_SEL);

    // -- ALU
    reg [63:0] ALU_X1;
    reg [63:0] ALU_X2;
    wire [63:0] ALU_OUT;
    wire isALUEqual;
    ALU alu(ALU_X1, ALU_X2, ALU_OP, ALU_OUT, isALUEqual);

    always @(*) begin
        case(ALU_X1_SEL)
            0: ALU_X1 <= R1_DATA;
            1: ALU_X1 <= PC_EXECUTE_3;
            //2: ALU_X1 <= 0;
            //3: ALU_X1 <= REG_WRITE_DATA_WRITEBACK_5; // USE WRITEBACK output directly (Data Hazard fix)
            //4: ALU_X1 <= ALU_OUT_MEMORY_4; // USE ALU output directly (Data Hazard fix)
            default: ALU_X1 <= 0;
        endcase

        case(ALU_X2_SEL)
            0: ALU_X2 <= R2_DATA;
            1: ALU_X2 <= IMMEDIATE_VALUE;
            //2: ALU_X2 <= REG_WRITE_DATA_WRITEBACK_5; // USE WRITEBACK output directly (Data Hazard fix)
            //3: ALU_X2 <= ALU_OUT_MEMORY_4; // USE ALU output directly (Data Hazard fix)
            default: ALU_X2 <= 0;
        endcase
    end




    // -- RegFile
    // Decoding OPCODE for 5th stage of pipeline.
    wire [6:0] OPCODE_WRITEBACK_5 = INSTRUCTION_WRITEBACK_5[6:0];
    wire WB_R_TYPE         = OPCODE_WRITEBACK_5 == OP_R_TYPE;
    wire WB_R_TYPE_64      = OPCODE_WRITEBACK_5 == OP_R_TYPE_64;
    wire WB_I_TYPE_LOAD    = OPCODE_WRITEBACK_5 == OP_I_TYPE_LOAD;
    wire WB_I_TYPE_OTHER   = OPCODE_WRITEBACK_5 == OP_I_TYPE_OTHER;
    wire WB_I_TYPE_64      = OPCODE_WRITEBACK_5 == OP_I_TYPE_64;
    wire WB_I_TYPE_JUMP    = OPCODE_WRITEBACK_5 == OP_I_TYPE_JUMP;
    wire WB_I_TYPE         = WB_I_TYPE_JUMP || WB_I_TYPE_LOAD || WB_I_TYPE_OTHER || WB_I_TYPE_64;
    wire WB_U_TYPE_LOAD    = OPCODE_WRITEBACK_5 == OP_U_TYPE_LOAD;
    wire WB_U_TYPE_JUMP    = OPCODE_WRITEBACK_5 == OP_U_TYPE_JUMP;
    wire WB_U_TYPE_AUIPC   = OPCODE_WRITEBACK_5 == OP_U_TYPE_AUIPC;
    wire WB_U_TYPE         = WB_U_TYPE_JUMP || WB_U_TYPE_LOAD || WB_U_TYPE_AUIPC;

    wire REG_WRITE_ENABLE = WB_R_TYPE || WB_R_TYPE_64 || WB_I_TYPE || WB_U_TYPE;

    // -- Register Write Back Selection Encoder
    wire [3:0] regWritebackSelectionInputs;
    wire [1:0] REG_WRITEBACK_SELECTION;

    assign regWritebackSelectionInputs[0] = 0;
    assign regWritebackSelectionInputs[1] = WB_R_TYPE || WB_R_TYPE_64 || WB_U_TYPE_LOAD || WB_I_TYPE_OTHER || WB_I_TYPE_64;
    assign regWritebackSelectionInputs[2] = WB_U_TYPE_JUMP || WB_I_TYPE_JUMP;
    assign regWritebackSelectionInputs[3] = WB_I_TYPE_LOAD;
    
    Encoder_4 writeBackSelectionEncoder(regWritebackSelectionInputs, REG_WRITEBACK_SELECTION);    


    wire signed[63:0] R1_DATA_EXECUTE_3;
    wire signed [63:0] R2_DATA_EXECUTE_3;

    wire [63:0] REG_WRITE_DATA = REG_WRITEBACK_SELECTION == 3 ? RAM_READ_DATA_WRITEBACK_5 : REG_WRITE_DATA_WRITEBACK_5;

    RegFile regFile(R1, R2, RD, REG_WRITE_DATA, REG_WRITE_ENABLE, R1_DATA_EXECUTE_3, R2_DATA_EXECUTE_3);



    // == PIPELINING ==================================================    
    // -- 1. Stage: Fetch
    reg [9:0] PC = 0;
    assign INSTRUCTION_ADDR = PC >> 2;

    always @(posedge CLK) begin
        if (PC_ALU_SEL == 1) begin
            PC <= ALU_OUT[9:0];
        end
        else begin
            if (LOAD_STALL == 1 || CONTROL_HAZARD_STALL == 1)
                PC <= PC; 
            else
                PC <= PC + 4;
        end        

        // PIPELINE HAZARD DATA REGISTERS
        if (CONTROL_HAZARD_STALL == 1) begin
            R1_PIPELINE[DECODE]      <= 0;
            R2_PIPELINE[DECODE]      <= 0;
            RD_PIPELINE[DECODE]      <= 0;
            TYPE_PIPELINE[DECODE]    <= TYPE_IMMEDIATE;
        end
        else begin
            R1_PIPELINE[DECODE] <= INSTRUCTION[19:15];
            R2_PIPELINE[DECODE] <= INSTRUCTION[24:20];
            RD_PIPELINE[DECODE] <= INSTRUCTION[11:7];

            if (INSTRUCTION[6:0] == OP_R_TYPE || INSTRUCTION[6:0] == OP_R_TYPE_64) // R-Type
                TYPE_PIPELINE[DECODE] <= TYPE_REGISTER;
                
            else if (INSTRUCTION[6:0] == OP_I_TYPE_LOAD) // Load
                TYPE_PIPELINE[DECODE] <= TYPE_LOAD;

            else if (INSTRUCTION[6:0] == OP_S_TYPE) // Store
                TYPE_PIPELINE[DECODE] <= TYPE_STORE;

            else if (INSTRUCTION[6:0] == OP_I_TYPE_OTHER || INSTRUCTION[6:0] == OP_I_TYPE_64 || INSTRUCTION[6:0] == OP_I_TYPE_JUMP) // Immediate
                TYPE_PIPELINE[DECODE] <= TYPE_IMMEDIATE;

            else if (INSTRUCTION[6:0] == OP_B_TYPE[6:0]) // Branch
                TYPE_PIPELINE[DECODE] <= TYPE_BRANCH;
        end
    end


    // -- 2. Stage: Decode
    reg [9:0] PC_DECODE_2 = 0;
    reg [31:0] INSTRUCTION_DECODE_2 = 0;

    always @(posedge CLK) begin
        if (LOAD_STALL == 1) begin
            INSTRUCTION_DECODE_2 <= INSTRUCTION_DECODE_2;
            PC_DECODE_2 <= PC_DECODE_2;
        end
        else if (CONTROL_HAZARD_STALL == 1) begin
            INSTRUCTION_DECODE_2 <= 32'h00000013;
            PC_DECODE_2 <= PC_DECODE_2;
        end
        else begin
            INSTRUCTION_DECODE_2 <= INSTRUCTION;
            PC_DECODE_2 <= PC;
        end
        
        
        // Pipeline Type
        if (INSTRUCTION_DECODE_2[6:0] == OP_R_TYPE || INSTRUCTION_DECODE_2[6:0] == OP_R_TYPE_64) // R-Type
            TYPE_PIPELINE[EXECUTE] <= TYPE_REGISTER;
            
        else if (INSTRUCTION_DECODE_2[6:0] == OP_I_TYPE_LOAD) // Load
            TYPE_PIPELINE[EXECUTE] <= TYPE_LOAD;

        else if (INSTRUCTION_DECODE_2[6:0] == OP_S_TYPE) // Store
            TYPE_PIPELINE[EXECUTE] <= TYPE_STORE;

        else if (INSTRUCTION_DECODE_2[6:0] == OP_I_TYPE_OTHER || INSTRUCTION_DECODE_2[6:0] == OP_I_TYPE_64 || INSTRUCTION_DECODE_2[6:0] == OP_I_TYPE_JUMP) // Immediate
            TYPE_PIPELINE[EXECUTE] <= TYPE_IMMEDIATE;

        else if (INSTRUCTION_DECODE_2[6:0] == OP_B_TYPE[6:0]) // Branch
            TYPE_PIPELINE[EXECUTE] <= TYPE_BRANCH;
        
        R1_PIPELINE[EXECUTE] <= INSTRUCTION_DECODE_2[19:15];
        R2_PIPELINE[EXECUTE] <= INSTRUCTION_DECODE_2[24:20];
        RD_PIPELINE[EXECUTE] <= INSTRUCTION_DECODE_2[11:7];

        
        if (LOAD_STALL == 1) begin
            R1_PIPELINE[EXECUTE]      <= 0;
            R2_PIPELINE[EXECUTE]      <= 0;
            RD_PIPELINE[EXECUTE]      <= 0;
            TYPE_PIPELINE[EXECUTE]    <= TYPE_IMMEDIATE;
        end
    end


    // -- 3. Stage: Execute
    reg [9:0] PC_EXECUTE_3 = 0;
    reg [31:0] INSTRUCTION_EXECUTE_3 = 0;

    always @(posedge CLK) begin
        if (LOAD_STALL == 1 ) begin
            INSTRUCTION_EXECUTE_3 <= 32'h00000013; // NOP for Stall
            PC_EXECUTE_3 <= PC_EXECUTE_3;
        end
        else begin
            PC_EXECUTE_3 <= PC_DECODE_2;
            INSTRUCTION_EXECUTE_3 <= INSTRUCTION_DECODE_2;
        end

        if (INSTRUCTION_EXECUTE_3[6:0] == OP_R_TYPE || INSTRUCTION_EXECUTE_3[6:0] == OP_R_TYPE_64) // R-Type
            TYPE_PIPELINE[MEMORY] <= TYPE_REGISTER;
            
        else if (INSTRUCTION_EXECUTE_3[6:0] == OP_I_TYPE_LOAD) // Load
            TYPE_PIPELINE[MEMORY] <= TYPE_LOAD;

        else if (INSTRUCTION_EXECUTE_3[6:0] == OP_S_TYPE) // Store
            TYPE_PIPELINE[MEMORY] <= TYPE_STORE;

        else if (INSTRUCTION_EXECUTE_3[6:0] == OP_I_TYPE_OTHER || INSTRUCTION_EXECUTE_3[6:0] == OP_I_TYPE_64 || INSTRUCTION_EXECUTE_3[6:0] == OP_I_TYPE_JUMP) // Immediate
            TYPE_PIPELINE[MEMORY] <= TYPE_IMMEDIATE;

        else if (INSTRUCTION_EXECUTE_3[6:0] == OP_B_TYPE[6:0]) // Branch
            TYPE_PIPELINE[MEMORY] <= TYPE_BRANCH;
        
        R1_PIPELINE[MEMORY] <= INSTRUCTION_EXECUTE_3[19:15];
        R2_PIPELINE[MEMORY] <= INSTRUCTION_EXECUTE_3[24:20];
        RD_PIPELINE[MEMORY] <= INSTRUCTION_EXECUTE_3[11:7];
    end    


    // -- 4. Stage: Memory
    reg [9:0] PC_MEMORY_4 = 0;
    reg [31:0] INSTRUCTION_MEMORY_4 = 0;
    reg [63:0] ALU_OUT_MEMORY_4 = 0;

    always @(posedge CLK) begin
        INSTRUCTION_MEMORY_4 <= INSTRUCTION_EXECUTE_3;
        PC_MEMORY_4 <= PC_EXECUTE_3;

        ALU_OUT_MEMORY_4 <= ALU_OUT;
        RAM_WRITE_DATA <= R2_DATA;
        

        if (INSTRUCTION_MEMORY_4[6:0] == OP_R_TYPE || INSTRUCTION_MEMORY_4[6:0] == OP_R_TYPE_64) // R-Type
            TYPE_PIPELINE[WRITEBACK] <= TYPE_REGISTER;
            
        else if (INSTRUCTION_MEMORY_4[6:0] == OP_I_TYPE_LOAD) // Load
            TYPE_PIPELINE[WRITEBACK] <= TYPE_LOAD;

        else if (INSTRUCTION_MEMORY_4[6:0] == OP_S_TYPE) // Store
            TYPE_PIPELINE[WRITEBACK] <= TYPE_STORE;

        else if (INSTRUCTION_MEMORY_4[6:0] == OP_I_TYPE_OTHER || INSTRUCTION_MEMORY_4[6:0] == OP_I_TYPE_64 || INSTRUCTION_MEMORY_4[6:0] == OP_I_TYPE_JUMP) // Immediate
            TYPE_PIPELINE[WRITEBACK] <= TYPE_IMMEDIATE;

        else if (INSTRUCTION_MEMORY_4[6:0] == OP_B_TYPE[6:0]) // Branch
            TYPE_PIPELINE[WRITEBACK] <= TYPE_BRANCH;
        
        R1_PIPELINE[WRITEBACK] <= INSTRUCTION_MEMORY_4[19:15];
        R2_PIPELINE[WRITEBACK] <= INSTRUCTION_MEMORY_4[24:20];
        RD_PIPELINE[WRITEBACK] <= INSTRUCTION_MEMORY_4[11:7];
    end


    // -- 5. Stage: WriteBack
    reg [31:0] INSTRUCTION_WRITEBACK_5 = 0;
    reg [63:0] REG_WRITE_DATA_WRITEBACK_5 = 0;
    reg [63:0] RAM_READ_DATA_WRITEBACK_5 = 0;
    
    always @(posedge CLK) begin
        INSTRUCTION_WRITEBACK_5 <= INSTRUCTION_MEMORY_4;
        RAM_READ_DATA_WRITEBACK_5 <= RAM_READ_DATA;

        //REG_WRITE_DATA_WRITEBACK_5 <= ALU_OUT_MEMORY_4;
        case (REG_WRITEBACK_SELECTION)
            1: REG_WRITE_DATA_WRITEBACK_5 <= ALU_OUT_MEMORY_4;
            2: REG_WRITE_DATA_WRITEBACK_5 <= PC_MEMORY_4 + 4;
        endcase
    end






    // GTK WAVE trick to show Arrays. NOT NECESSARY:
    generate
        genvar idx;
        for(idx = 0; idx < 4; idx = idx+1) begin: PIPELINE
            wire [4:0] R1 = R1_PIPELINE[idx];
            wire [4:0] R2 = R2_PIPELINE[idx];
            wire [4:0] RD = RD_PIPELINE[idx];
            wire [2:0] TYPE = TYPE_PIPELINE[idx];
        end
    endgenerate
endmodule
