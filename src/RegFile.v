module RegFile(
    input [4:0]R1,
    input [4:0]R2,
    input [4:0]RD,
    input [63:0]RD_DATA,
    input WRITE_ENABLE,

    output [63:0]R1_DATA,
    output [63:0]R2_DATA
);
    reg [63:0] REGISTERS[31:0]; // 64 Bit length, 32 Registers

    integer i = 0;
    initial begin
        for (i = 0; i< 32 ; i = i + 1) begin
            REGISTERS[i] <= 0;
        end
    end

    assign R1_DATA = REGISTERS[R1];
    assign R2_DATA = REGISTERS[R2];

    always @(*) begin
        if (WRITE_ENABLE == 1 && RD != 0)
            REGISTERS[RD] <= RD_DATA;
    end
    

    // GTK WAVE trick to show Arrays. NOT NECESSARY:
    generate
        genvar idx;
        for(idx = 1; idx < 31; idx = idx+1) begin: REG_DATAS
            wire [63:0] R_DATA = REGISTERS[idx];
        end
    endgenerate
endmodule
